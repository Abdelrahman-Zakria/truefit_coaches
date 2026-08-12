import React, { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ChevronLeft, Plus, Trash2 } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { BottomSheet } from "../components/BottomSheet";
import { ProgressRing } from "../components/ProgressRing";
import type { Exercise, InBodyScan, Meal, Assessment } from "../context/DataContext";
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip } from "recharts";

const TABS = ["overview", "workouts", "inbody", "diet_plan", "assessment", "sessions"] as const;
type Tab = typeof TABS[number];

function Field({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
      <p className="text-[10px] text-white/40 uppercase tracking-widest mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{label}</p>
      <p className="text-sm font-medium text-white" style={{ fontFamily: "'Inter', sans-serif" }}>{value}</p>
    </div>
  );
}

function InBodyCard({ scan }: { scan: InBodyScan }) {
  return (
    <div className="rounded-2xl p-4 space-y-3" style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.06)" }}>
      <div className="flex items-center justify-between">
        <span className="text-xs font-bold text-white/40" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{scan.date}</span>
        <span className="text-xs px-2 py-0.5 rounded font-bold" style={{ background: "rgba(220,20,60,0.12)", color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>InBody</span>
      </div>
      <div className="grid grid-cols-3 gap-2">
        {[
          { l: "Weight", v: `${scan.weight} kg` },
          { l: "Body Fat", v: `${scan.bodyFat}%` },
          { l: "Muscle", v: `${scan.muscleMass} kg` },
          { l: "BMI", v: scan.bmi.toString() },
          { l: "Hydration", v: `${scan.hydration}%` },
        ].map(({ l, v }) => (
          <div key={l} className="text-center">
            <p className="text-lg font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{v}</p>
            <p className="text-[10px] text-white/40 uppercase" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{l}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function MemberProfile() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { t, isAr } = useLang();
  const { members, addExercise, removeExercise, addInBodyScan, addMeal, removeMeal, addAssessment } = useData();
  const member = members.find(m => m.id === id);
  const [tab, setTab] = useState<Tab>("overview");
  const [sheetType, setSheetType] = useState<string | null>(null);

  // Form states
  const [exForm, setExForm] = useState({ name: "", muscleGroup: "", weight: "", sets: "", repsPerSet: "" });
  const [ibForm, setIbForm] = useState({ date: "", weight: "", bodyFat: "", muscleMass: "", bmi: "", hydration: "" });
  const [mealForm, setMealForm] = useState({ name: "", calories: "", protein: "", carbs: "", fat: "" });
  const [assessForm, setAssessForm] = useState({ fitnessLevel: "", goals: "", injuries: "", coachRemarks: "" });

  if (!member) {
    return (
      <div className="flex items-center justify-center h-full text-white/40 p-8 text-center" style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 13 }}>
        Member not found
      </div>
    );
  }

  const name = isAr ? member.nameAr : member.name;

  const handleAddExercise = () => {
    if (!exForm.name) return;
    addExercise(member.id, {
      id: `ex_${Date.now()}`, name: exForm.name, muscleGroup: exForm.muscleGroup,
      weight: Number(exForm.weight), sets: Number(exForm.sets), repsPerSet: Number(exForm.repsPerSet),
    });
    setExForm({ name: "", muscleGroup: "", weight: "", sets: "", repsPerSet: "" });
    setSheetType(null);
  };

  const handleAddInBody = () => {
    if (!ibForm.date) return;
    addInBodyScan(member.id, {
      id: `ib_${Date.now()}`, date: ibForm.date, weight: Number(ibForm.weight),
      bodyFat: Number(ibForm.bodyFat), muscleMass: Number(ibForm.muscleMass),
      bmi: Number(ibForm.bmi), hydration: Number(ibForm.hydration),
    });
    setIbForm({ date: "", weight: "", bodyFat: "", muscleMass: "", bmi: "", hydration: "" });
    setSheetType(null);
  };

  const handleAddMeal = () => {
    if (!mealForm.name) return;
    addMeal(member.id, {
      id: `ml_${Date.now()}`, name: mealForm.name, calories: Number(mealForm.calories),
      protein: Number(mealForm.protein), carbs: Number(mealForm.carbs), fat: Number(mealForm.fat),
    });
    setMealForm({ name: "", calories: "", protein: "", carbs: "", fat: "" });
    setSheetType(null);
  };

  const handleAddAssessment = () => {
    if (!assessForm.fitnessLevel) return;
    addAssessment(member.id, {
      id: `as_${Date.now()}`, date: new Date().toISOString().split("T")[0],
      fitnessLevel: assessForm.fitnessLevel, goals: assessForm.goals,
      injuries: assessForm.injuries, coachRemarks: assessForm.coachRemarks,
    });
    setAssessForm({ fitnessLevel: "", goals: "", injuries: "", coachRemarks: "" });
    setSheetType(null);
  };

  const inBodyChartData = member.inBodyScans.map(s => ({
    date: s.date.slice(5), weight: s.weight, bodyFat: s.bodyFat, muscle: s.muscleMass,
  }));

  const latestInBody = member.inBodyScans[member.inBodyScans.length - 1];

  const tabLabels: Record<Tab, string> = {
    overview: t("overview"), workouts: t("workouts"), inbody: t("inbody"),
    diet_plan: t("diet_plan"), assessment: t("assessment"), sessions: t("sessions"),
  };

  return (
    <div className="pb-4 flex flex-col h-full">
      {/* Header */}
      <div className="shrink-0 px-4 pt-4 pb-3" style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
        <button onClick={() => navigate("/members")} className="flex items-center gap-1 text-white/40 mb-3 hover:text-white transition-colors">
          <ChevronLeft size={16} />
          <span className="text-sm" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{t("all_members")}</span>
        </button>
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center text-xl font-black text-white"
            style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {member.initials}
          </div>
          <div className="flex-1 min-w-0">
            <h1 className="text-2xl font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{name}</h1>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-[10px] font-bold px-2 py-0.5 rounded" style={{ background: "rgba(220,20,60,0.12)", color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {member.plan}
              </span>
              <span className="text-xs text-white/30" style={{ fontFamily: "'JetBrains Mono', monospace" }}>Age {member.age}</span>
            </div>
          </div>
          <ProgressRing progress={member.progress} size={52} strokeWidth={4} label={`${member.progress}%`} />
        </div>

        {/* Tab bar */}
        <div className="flex gap-1 mt-4 overflow-x-auto pb-1">
          {TABS.map(tb => (
            <button
              key={tb}
              onClick={() => setTab(tb)}
              className="px-3 py-2 rounded-xl text-xs font-black uppercase tracking-wide whitespace-nowrap shrink-0 transition-all"
              style={{
                background: tab === tb ? "#dc143c" : "#141414",
                color: tab === tb ? "#fff" : "rgba(255,255,255,0.4)",
                fontFamily: "'Barlow Condensed', sans-serif",
                border: `1px solid ${tab === tb ? "#dc143c" : "rgba(255,255,255,0.06)"}`,
              }}
            >
              {tabLabels[tb]}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">

        {/* OVERVIEW */}
        {tab === "overview" && (
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Field label={t("phone")} value={member.phone} />
              <Field label={t("email")} value={member.email} />
              <Field label={t("join_date")} value={member.joinDate} />
              <Field label={t("plan_expiry")} value={member.planExpiry} />
              <Field label={t("member_plan")} value={member.plan} />
              <Field label={t("last_session")} value={member.lastSession} />
            </div>
            {latestInBody && (
              <div>
                <p className="text-xs text-white/40 uppercase tracking-widest mb-2" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Latest InBody</p>
                <div className="grid grid-cols-3 gap-2">
                  {[
                    { l: "Weight", v: `${latestInBody.weight}kg` },
                    { l: "Body Fat", v: `${latestInBody.bodyFat}%` },
                    { l: "Muscle", v: `${latestInBody.muscleMass}kg` },
                  ].map(({ l, v }) => (
                    <div key={l} className="rounded-xl p-3 text-center" style={{ background: "#1a1a1a" }}>
                      <p className="text-xl font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{v}</p>
                      <p className="text-[10px] text-white/40 uppercase" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{l}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* WORKOUTS */}
        {tab === "workouts" && (
          <div className="space-y-3">
            <button onClick={() => setSheetType("exercise")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
              style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
              <Plus size={16} />
              {t("add_exercise")}
            </button>
            {member.exercises.map(ex => (
              <div key={ex.id} className="rounded-2xl p-4 flex items-center gap-3" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                <div className="flex-1">
                  <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>{ex.name}</p>
                  <p className="text-xs text-white/40">{ex.muscleGroup}</p>
                  <div className="flex items-center gap-3 mt-2">
                    <span className="text-xs font-bold text-white/60" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{ex.weight > 0 ? `${ex.weight}kg` : "BW"}</span>
                    <span className="text-xs font-bold" style={{ color: "#dc143c", fontFamily: "'JetBrains Mono', monospace" }}>{ex.sets}×{ex.repsPerSet}</span>
                  </div>
                </div>
                <button onClick={() => removeExercise(member.id, ex.id)} className="p-2 rounded-lg hover:bg-white/5 transition-colors">
                  <Trash2 size={16} color="rgba(255,255,255,0.25)" />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* INBODY */}
        {tab === "inbody" && (
          <div className="space-y-3">
            <button onClick={() => setSheetType("inbody")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
              style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
              <Plus size={16} />
              New Scan
            </button>
            {inBodyChartData.length >= 2 && (
              <div className="rounded-2xl p-4" style={{ background: "#141414" }}>
                <p className="text-xs text-white/40 uppercase tracking-widest mb-3" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Weight Trend</p>
                <ResponsiveContainer width="100%" height={120}>
                  <AreaChart data={inBodyChartData}>
                    <defs>
                      <linearGradient id="wg" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#dc143c" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#dc143c" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="date" tick={{ fill: "rgba(255,255,255,0.3)", fontSize: 10 }} axisLine={false} tickLine={false} />
                    <YAxis hide domain={["auto", "auto"]} />
                    <Tooltip contentStyle={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", borderRadius: 8, fontSize: 12 }} />
                    <Area type="monotone" dataKey="weight" stroke="#dc143c" fill="url(#wg)" strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            )}
            {[...member.inBodyScans].reverse().map(s => <InBodyCard key={s.id} scan={s} />)}
          </div>
        )}

        {/* DIET PLAN */}
        {tab === "diet_plan" && (
          <div className="space-y-3">
            <button onClick={() => setSheetType("meal")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
              style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
              <Plus size={16} />
              {t("add_meal")}
            </button>
            {member.meals.length > 0 && (
              <div className="rounded-2xl p-3" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                <p className="text-xs text-white/40 uppercase tracking-widest mb-2" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Daily Totals</p>
                <div className="grid grid-cols-4 gap-2">
                  {[
                    { l: "kcal", v: member.meals.reduce((a, m) => a + m.calories, 0) },
                    { l: "protein", v: `${member.meals.reduce((a, m) => a + m.protein, 0)}g` },
                    { l: "carbs", v: `${member.meals.reduce((a, m) => a + m.carbs, 0)}g` },
                    { l: "fat", v: `${member.meals.reduce((a, m) => a + m.fat, 0)}g` },
                  ].map(({ l, v }) => (
                    <div key={l} className="text-center">
                      <p className="text-xl font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{v}</p>
                      <p className="text-[10px] text-white/30 uppercase" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{l}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
            {member.meals.map(meal => (
              <div key={meal.id} className="rounded-2xl p-4 flex items-center gap-3" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                <div className="flex-1">
                  <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>{meal.name}</p>
                  <div className="flex gap-3 mt-1">
                    <span className="text-xs font-bold text-[#dc143c]" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{meal.calories} kcal</span>
                    <span className="text-xs text-white/30" style={{ fontFamily: "'JetBrains Mono', monospace" }}>P:{meal.protein} C:{meal.carbs} F:{meal.fat}</span>
                  </div>
                </div>
                <button onClick={() => removeMeal(member.id, meal.id)} className="p-2 rounded-lg hover:bg-white/5 transition-colors">
                  <Trash2 size={16} color="rgba(255,255,255,0.25)" />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* ASSESSMENT */}
        {tab === "assessment" && (
          <div className="space-y-3">
            <button onClick={() => setSheetType("assessment")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
              style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
              <Plus size={16} />
              New Assessment
            </button>
            {member.assessments.map(a => (
              <div key={a.id} className="rounded-2xl p-4 space-y-3" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-white/40" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{a.date}</span>
                  <span className="text-xs font-black px-2 py-0.5 rounded" style={{ background: "rgba(220,20,60,0.12)", color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
                    {a.fitnessLevel}
                  </span>
                </div>
                <div className="grid grid-cols-1 gap-2">
                  <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
                    <p className="text-[10px] text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Goals</p>
                    <p className="text-sm text-white" style={{ fontFamily: "'Inter', sans-serif" }}>{a.goals}</p>
                  </div>
                  {a.injuries && (
                    <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
                      <p className="text-[10px] text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Injuries / Notes</p>
                      <p className="text-sm" style={{ color: "#f59e0b", fontFamily: "'Inter', sans-serif" }}>{a.injuries}</p>
                    </div>
                  )}
                  {a.coachRemarks && (
                    <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
                      <p className="text-[10px] text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Coach Remarks</p>
                      <p className="text-sm text-white/70" style={{ fontFamily: "'Inter', sans-serif" }}>{a.coachRemarks}</p>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* SESSIONS HISTORY */}
        {tab === "sessions" && (
          <div className="space-y-3">
            {member.pastSessions.length === 0
              ? <div className="text-center py-12 text-white/20 text-sm" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{t("no_data")}</div>
              : member.pastSessions.map(s => (
                <div key={s.id} className="rounded-2xl p-4 flex items-center gap-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xs font-black text-[#dc143c]"
                    style={{ background: "rgba(220,20,60,0.1)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                    PT
                  </div>
                  <div className="flex-1">
                    <p className="font-bold text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{s.notes}</p>
                    <p className="text-xs text-white/40">{s.date} · {s.duration}min</p>
                  </div>
                </div>
              ))
            }
          </div>
        )}
      </div>

      {/* Exercise Sheet */}
      <BottomSheet open={sheetType === "exercise"} onClose={() => setSheetType(null)} title={t("add_exercise")} height="75vh">
        <div className="space-y-3">
          <FormField label={`${t("exercise_name")} / اسم التمرين`} value={exForm.name} onChange={v => setExForm(f => ({ ...f, name: v }))} placeholder="e.g. Bench Press" />
          <FormField label={`${t("muscle_group")} / المجموعة`} value={exForm.muscleGroup} onChange={v => setExForm(f => ({ ...f, muscleGroup: v }))} placeholder="e.g. Chest" />
          <FormField label={`${t("weight_kg")} / الوزن`} value={exForm.weight} onChange={v => setExForm(f => ({ ...f, weight: v }))} placeholder="0 for bodyweight" type="number" />
          <div className="grid grid-cols-2 gap-3">
            <FormField label={`${t("sets")} / الجولات`} value={exForm.sets} onChange={v => setExForm(f => ({ ...f, sets: v }))} placeholder="4" type="number" />
            <FormField label={`${t("reps_per_set")} / تكرارات`} value={exForm.repsPerSet} onChange={v => setExForm(f => ({ ...f, repsPerSet: v }))} placeholder="10" type="number" />
          </div>
          <button onClick={handleAddExercise} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>

      {/* InBody Sheet */}
      <BottomSheet open={sheetType === "inbody"} onClose={() => setSheetType(null)} title="New InBody Scan" height="80vh">
        <div className="space-y-3">
          <FormField label={`${t("scan_date")} / التاريخ`} value={ibForm.date} onChange={v => setIbForm(f => ({ ...f, date: v }))} placeholder="YYYY-MM-DD" type="date" />
          <FormField label={`${t("weight")} / الوزن`} value={ibForm.weight} onChange={v => setIbForm(f => ({ ...f, weight: v }))} placeholder="80.5" type="number" />
          <div className="grid grid-cols-2 gap-3">
            <FormField label={`${t("body_fat")} / الدهون`} value={ibForm.bodyFat} onChange={v => setIbForm(f => ({ ...f, bodyFat: v }))} placeholder="18.0" type="number" />
            <FormField label={`${t("muscle_mass")} / عضلات`} value={ibForm.muscleMass} onChange={v => setIbForm(f => ({ ...f, muscleMass: v }))} placeholder="38.5" type="number" />
            <FormField label={`${t("bmi")} / الكتلة`} value={ibForm.bmi} onChange={v => setIbForm(f => ({ ...f, bmi: v }))} placeholder="24.1" type="number" />
            <FormField label={`${t("hydration")} / الترطيب`} value={ibForm.hydration} onChange={v => setIbForm(f => ({ ...f, hydration: v }))} placeholder="62.0" type="number" />
          </div>
          <button onClick={handleAddInBody} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>

      {/* Meal Sheet */}
      <BottomSheet open={sheetType === "meal"} onClose={() => setSheetType(null)} title={t("add_meal")} height="75vh">
        <div className="space-y-3">
          <FormField label={`${t("meal_name")} / الوجبة`} value={mealForm.name} onChange={v => setMealForm(f => ({ ...f, name: v }))} placeholder="e.g. Breakfast" />
          <FormField label={`${t("calories")} / سعرات`} value={mealForm.calories} onChange={v => setMealForm(f => ({ ...f, calories: v }))} placeholder="500" type="number" />
          <div className="grid grid-cols-3 gap-2">
            <FormField label={`${t("protein")}`} value={mealForm.protein} onChange={v => setMealForm(f => ({ ...f, protein: v }))} placeholder="40g" type="number" />
            <FormField label={`${t("carbs")}`} value={mealForm.carbs} onChange={v => setMealForm(f => ({ ...f, carbs: v }))} placeholder="50g" type="number" />
            <FormField label={`${t("fat")}`} value={mealForm.fat} onChange={v => setMealForm(f => ({ ...f, fat: v }))} placeholder="15g" type="number" />
          </div>
          <button onClick={handleAddMeal} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>

      {/* Assessment Sheet */}
      <BottomSheet open={sheetType === "assessment"} onClose={() => setSheetType(null)} title="New Assessment" height="85vh">
        <div className="space-y-3">
          <FormField label={`${t("fitness_level")} / المستوى`} value={assessForm.fitnessLevel} onChange={v => setAssessForm(f => ({ ...f, fitnessLevel: v }))} placeholder="Beginner / Intermediate / Advanced" />
          <TextareaField label={`${t("goals")} / الأهداف`} value={assessForm.goals} onChange={v => setAssessForm(f => ({ ...f, goals: v }))} placeholder="Member goals..." />
          <TextareaField label={`${t("injuries")} / الإصابات`} value={assessForm.injuries} onChange={v => setAssessForm(f => ({ ...f, injuries: v }))} placeholder="Any injuries or limitations..." />
          <TextareaField label={`${t("coach_remarks")} / ملاحظات`} value={assessForm.coachRemarks} onChange={v => setAssessForm(f => ({ ...f, coachRemarks: v }))} placeholder="Coach observations..." />
          <button onClick={handleAddAssessment} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>
    </div>
  );
}

function FormField({ label, value, onChange, placeholder, type = "text" }: {
  label: string; value: string; onChange: (v: string) => void; placeholder?: string; type?: string;
}) {
  return (
    <div>
      <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{label}</label>
      <input
        type={type} value={value} onChange={e => onChange(e.target.value)} placeholder={placeholder}
        className="w-full px-4 py-3 rounded-xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c]"
        style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
      />
    </div>
  );
}

function TextareaField({ label, value, onChange, placeholder }: {
  label: string; value: string; onChange: (v: string) => void; placeholder?: string;
}) {
  return (
    <div>
      <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{label}</label>
      <textarea
        value={value} onChange={e => onChange(e.target.value)} placeholder={placeholder} rows={3}
        className="w-full px-4 py-3 rounded-xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c] resize-none"
        style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
      />
    </div>
  );
}
