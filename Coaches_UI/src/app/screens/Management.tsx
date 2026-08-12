import React, { useState } from "react";
import { useNavigate } from "react-router";
import { LayoutGrid, Calendar, Dumbbell, DollarSign, Plus, Trash2, ToggleLeft, ToggleRight } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { useAuth } from "../context/AuthContext";
import { BottomSheet } from "../components/BottomSheet";
import { toast } from "sonner";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

type Tab = "shifts" | "inbody" | "classes" | "salary";

export default function Management() {
  const { t } = useLang();
  const { allCoaches } = useAuth();
  const { coachShifts, inBodySlots, classes, deductions, updateCoachShift, addInBodySlot, toggleClass, updateClass, addDeduction } = useData();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>("shifts");
  const [sheetType, setSheetType] = useState<string | null>(null);
  const [editingShift, setEditingShift] = useState<{ coachId: string; day: string } | null>(null);
  const [shiftForm, setShiftForm] = useState({ startTime: "", endTime: "", isOff: false });
  const [dedForm, setDedForm] = useState({ coachId: "", amount: "", reason: "" });
  const [slotForm, setSlotForm] = useState({ date: "", time: "", supervisorId: "", memberName: "" });
  const [classForm, setClassForm] = useState({ name: "", instructor: "", instructorId: "", date: "", time: "", duration: "", location: "", capacity: "" });

  const coaches = allCoaches.filter(c => c.role !== "head_coach");

  const getShift = (coachId: string, day: string) =>
    coachShifts.find(s => s.coachId === coachId && s.day === day);

  const openShiftEditor = (coachId: string, day: string) => {
    const shift = getShift(coachId, day);
    setEditingShift({ coachId, day });
    setShiftForm({ startTime: shift?.startTime || "", endTime: shift?.endTime || "", isOff: shift?.isOff || false });
    setSheetType("shift");
  };

  const saveShift = () => {
    if (!editingShift) return;
    updateCoachShift(editingShift.coachId, editingShift.day, shiftForm);
    toast.success("Shift updated");
    setSheetType(null);
  };

  const saveSlot = () => {
    if (!slotForm.date || !slotForm.time) return;
    const supervisor = allCoaches.find(c => c.id === slotForm.supervisorId);
    addInBodySlot({
      id: `ibs_${Date.now()}`, date: slotForm.date, time: slotForm.time,
      supervisorId: slotForm.supervisorId, supervisorName: supervisor?.name || "",
      memberName: slotForm.memberName,
    });
    toast.success("InBody slot added");
    setSheetType(null);
    setSlotForm({ date: "", time: "", supervisorId: "", memberName: "" });
  };

  const saveDed = () => {
    if (!dedForm.coachId || !dedForm.amount) return;
    addDeduction({
      id: `d_${Date.now()}`, coachId: dedForm.coachId,
      amount: Number(dedForm.amount), reason: dedForm.reason, date: new Date().toISOString().split("T")[0],
    });
    toast.success("Deduction added");
    setSheetType(null);
    setDedForm({ coachId: "", amount: "", reason: "" });
  };

  const tabs: { key: Tab; icon: React.ElementType; label: string }[] = [
    { key: "shifts", icon: Calendar, label: t("shift_planner") },
    { key: "inbody", icon: Dumbbell, label: "InBody" },
    { key: "classes", icon: LayoutGrid, label: t("class_management") },
    { key: "salary", icon: DollarSign, label: "Salary" },
  ];

  return (
    <div className="pb-4">
      <div className="px-4 pt-4 mb-4">
        <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("management")}
        </h1>
        <p className="text-xs text-white/30 mt-0.5" style={{ fontFamily: "'JetBrains Mono', monospace" }}>Head Coach Access</p>
      </div>

      {/* Tab selector */}
      <div className="flex gap-1 px-4 mb-4 overflow-x-auto pb-1">
        {tabs.map(tb => {
          const Icon = tb.icon;
          return (
            <button key={tb.key} onClick={() => setTab(tb.key)}
              className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl shrink-0 font-black text-xs uppercase tracking-wide transition-all"
              style={{
                background: tab === tb.key ? "#dc143c" : "#141414",
                color: tab === tb.key ? "#fff" : "rgba(255,255,255,0.4)",
                border: `1px solid ${tab === tb.key ? "#dc143c" : "rgba(255,255,255,0.06)"}`,
                fontFamily: "'Barlow Condensed', sans-serif",
              }}>
              <Icon size={13} />
              {tb.label}
            </button>
          );
        })}
      </div>

      {/* SHIFT PLANNER */}
      {tab === "shifts" && (
        <div className="px-4 overflow-x-auto">
          <div style={{ minWidth: 480 }}>
            {/* Header row */}
            <div className="flex mb-1">
              <div className="w-24 shrink-0" />
              {DAYS.map(d => (
                <div key={d} className="flex-1 text-center">
                  <span className="text-[10px] font-black text-white/30 uppercase tracking-wider" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{d}</span>
                </div>
              ))}
            </div>
            {coaches.map(coach => (
              <div key={coach.id} className="flex items-center gap-0 mb-1">
                <div className="w-24 shrink-0 flex items-center gap-2 pr-2">
                  <div className="w-7 h-7 rounded-lg flex items-center justify-center text-[10px] font-black text-white"
                    style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                    {coach.avatar}
                  </div>
                  <span className="text-[10px] font-bold text-white/60 truncate" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
                    {coach.name.split(" ")[0]}
                  </span>
                </div>
                {DAYS.map(day => {
                  const shift = getShift(coach.id, day);
                  const isOff = !shift || shift.isOff;
                  return (
                    <button key={day} onClick={() => openShiftEditor(coach.id, day)}
                      className="flex-1 mx-0.5 h-12 rounded-lg flex flex-col items-center justify-center transition-all active:scale-95"
                      style={{
                        background: isOff ? "rgba(255,255,255,0.03)" : "rgba(220,20,60,0.1)",
                        border: `1px solid ${isOff ? "rgba(255,255,255,0.05)" : "rgba(220,20,60,0.25)"}`,
                      }}>
                      {isOff ? (
                        <span className="text-[9px] text-white/20 font-bold" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>OFF</span>
                      ) : (
                        <>
                          <span className="text-[8px] font-bold" style={{ color: "#dc143c", fontFamily: "'JetBrains Mono', monospace" }}>{shift?.startTime}</span>
                          <span className="text-[8px] font-bold" style={{ color: "rgba(220,20,60,0.6)", fontFamily: "'JetBrains Mono', monospace" }}>{shift?.endTime}</span>
                        </>
                      )}
                    </button>
                  );
                })}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* INBODY SCHEDULE */}
      {tab === "inbody" && (
        <div className="px-4 space-y-3">
          <button onClick={() => setSheetType("slot")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            <Plus size={16} />
            {t("add_slot")}
          </button>
          {inBodySlots.map(slot => (
            <div key={slot.id} className="rounded-2xl p-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
              <div className="flex items-start justify-between mb-2">
                <div>
                  <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{slot.date} · {slot.time}</p>
                  <p className="text-xs text-white/40 mt-0.5">Supervisor: {slot.supervisorName}</p>
                </div>
                {slot.memberName
                  ? <span className="text-[10px] font-black px-2 py-0.5 rounded" style={{ background: "rgba(34,197,94,0.12)", color: "#22c55e", fontFamily: "'Barlow Condensed', sans-serif" }}>BOOKED</span>
                  : <span className="text-[10px] font-black px-2 py-0.5 rounded" style={{ background: "rgba(245,158,11,0.12)", color: "#f59e0b", fontFamily: "'Barlow Condensed', sans-serif" }}>OPEN</span>
                }
              </div>
              {slot.memberName && (
                <p className="text-xs text-white/40" style={{ fontFamily: "'Inter', sans-serif" }}>Member: {slot.memberName}</p>
              )}
            </div>
          ))}
        </div>
      )}

      {/* CLASSES */}
      {tab === "classes" && (
        <div className="px-4 space-y-3">
          {classes.map(cls => (
            <div key={cls.id} className="rounded-2xl p-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
              <div className="flex items-start justify-between mb-2">
                <div>
                  <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>{cls.name}</p>
                  <p className="text-xs text-white/40 mt-0.5">{cls.date} · {cls.time} · {cls.location}</p>
                </div>
                <button onClick={() => toggleClass(cls.id)} className="p-1">
                  {cls.isOpen
                    ? <ToggleRight size={24} color="#22c55e" />
                    : <ToggleLeft size={24} color="#888" />
                  }
                </button>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex-1 h-1.5 rounded-full overflow-hidden" style={{ background: "rgba(255,255,255,0.08)" }}>
                  <div className="h-full rounded-full" style={{ width: `${(cls.enrolled / cls.capacity) * 100}%`, background: cls.enrolled >= cls.capacity ? "#dc143c" : "#22c55e" }} />
                </div>
                <span className="text-xs font-bold" style={{ fontFamily: "'JetBrains Mono', monospace", color: "rgba(255,255,255,0.4)" }}>
                  {cls.enrolled}/{cls.capacity}
                </span>
              </div>
              <p className="text-xs text-white/30 mt-1.5">{cls.instructor} · {cls.duration}min</p>
            </div>
          ))}
        </div>
      )}

      {/* SALARY & DEDUCTIONS */}
      {tab === "salary" && (
        <div className="px-4 space-y-4">
          <button onClick={() => setSheetType("deduction")} className="w-full py-3 rounded-xl font-black text-sm uppercase tracking-widest flex items-center justify-center gap-2 transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            <Plus size={16} />
            {t("add_deduction")}
          </button>
          {allCoaches.map(coach => {
            const coachDeds = deductions.filter(d => d.coachId === coach.id);
            const totalDed = coachDeds.reduce((a, d) => a + d.amount, 0);
            const net = coach.baseSalary - totalDed;
            return (
              <div key={coach.id} className="rounded-2xl p-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center text-sm font-black text-white"
                      style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                      {coach.avatar}
                    </div>
                    <div>
                      <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{coach.name}</p>
                      <p className="text-[10px] text-white/30" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{coach.specialty}</p>
                    </div>
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-2 mb-3">
                  {[
                    { l: "Base", v: `AED ${coach.baseSalary.toLocaleString()}`, c: "rgba(255,255,255,0.7)" },
                    { l: "Deductions", v: `-AED ${totalDed}`, c: "#dc143c" },
                    { l: "Net", v: `AED ${net.toLocaleString()}`, c: "#22c55e" },
                  ].map(({ l, v, c }) => (
                    <div key={l} className="rounded-xl p-2.5" style={{ background: "#1a1a1a" }}>
                      <p className="text-[9px] text-white/30 uppercase mb-0.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{l}</p>
                      <p className="text-sm font-black" style={{ color: c, fontFamily: "'JetBrains Mono', monospace", fontSize: 12 }}>{v}</p>
                    </div>
                  ))}
                </div>
                {coachDeds.length > 0 && (
                  <div className="space-y-1.5">
                    {coachDeds.map(d => (
                      <div key={d.id} className="flex items-center justify-between px-2.5 py-2 rounded-lg" style={{ background: "rgba(220,20,60,0.06)" }}>
                        <span className="text-xs text-white/40" style={{ fontFamily: "'Inter', sans-serif" }}>{d.reason}</span>
                        <span className="text-xs font-bold" style={{ color: "#dc143c", fontFamily: "'JetBrains Mono', monospace" }}>-{d.amount}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* Shift Edit Sheet */}
      <BottomSheet open={sheetType === "shift"} onClose={() => setSheetType(null)} title={t("assign_shift")} height="55vh">
        <div className="space-y-4">
          <div className="flex items-center gap-3 mb-2">
            <button onClick={() => setShiftForm(f => ({ ...f, isOff: !f.isOff }))}
              className="flex items-center gap-2 px-3 py-2 rounded-xl transition-all"
              style={{ background: shiftForm.isOff ? "rgba(136,136,136,0.12)" : "rgba(220,20,60,0.12)", border: "1px solid rgba(255,255,255,0.07)" }}>
              {shiftForm.isOff
                ? <ToggleLeft size={20} color="#888" />
                : <ToggleRight size={20} color="#dc143c" />
              }
              <span className="text-sm font-black" style={{ color: shiftForm.isOff ? "#888" : "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {shiftForm.isOff ? t("shift_off") : "Working"}
              </span>
            </button>
          </div>
          {!shiftForm.isOff && (
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Start Time</label>
                <input type="time" value={shiftForm.startTime} onChange={e => setShiftForm(f => ({ ...f, startTime: e.target.value }))}
                  className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
                  style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)" }} />
              </div>
              <div>
                <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>End Time</label>
                <input type="time" value={shiftForm.endTime} onChange={e => setShiftForm(f => ({ ...f, endTime: e.target.value }))}
                  className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
                  style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)" }} />
              </div>
            </div>
          )}
          <button onClick={saveShift} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>

      {/* InBody Slot Sheet */}
      <BottomSheet open={sheetType === "slot"} onClose={() => setSheetType(null)} title={t("add_slot")} height="70vh">
        <div className="space-y-3">
          <MgmtField label="Date" value={slotForm.date} onChange={v => setSlotForm(f => ({ ...f, date: v }))} type="date" />
          <MgmtField label="Time" value={slotForm.time} onChange={v => setSlotForm(f => ({ ...f, time: v }))} type="time" />
          <div>
            <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Supervisor</label>
            <select value={slotForm.supervisorId} onChange={e => setSlotForm(f => ({ ...f, supervisorId: e.target.value }))}
              className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
              style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)" }}>
              <option value="">Select coach...</option>
              {allCoaches.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <MgmtField label="Member Name (optional)" value={slotForm.memberName} onChange={v => setSlotForm(f => ({ ...f, memberName: v }))} />
          <button onClick={saveSlot} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>

      {/* Deduction Sheet */}
      <BottomSheet open={sheetType === "deduction"} onClose={() => setSheetType(null)} title={t("add_deduction")} height="65vh">
        <div className="space-y-3">
          <div>
            <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Coach</label>
            <select value={dedForm.coachId} onChange={e => setDedForm(f => ({ ...f, coachId: e.target.value }))}
              className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
              style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)" }}>
              <option value="">Select coach...</option>
              {allCoaches.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <MgmtField label={`Amount (AED) / ${t("amount")}`} value={dedForm.amount} onChange={v => setDedForm(f => ({ ...f, amount: v }))} type="number" />
          <div>
            <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Reason / السبب</label>
            <textarea value={dedForm.reason} onChange={e => setDedForm(f => ({ ...f, reason: e.target.value }))} rows={3}
              className="w-full px-4 py-3 rounded-xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c] resize-none"
              style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
              placeholder="Reason for deduction..." />
          </div>
          <button onClick={saveDed} className="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
            style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("save")}
          </button>
        </div>
      </BottomSheet>
    </div>
  );
}

function MgmtField({ label, value, onChange, type = "text" }: { label: string; value: string; onChange: (v: string) => void; type?: string }) {
  return (
    <div>
      <label className="block text-[10px] text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{label}</label>
      <input type={type} value={value} onChange={e => onChange(e.target.value)}
        className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
        style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }} />
    </div>
  );
}
