import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { Dumbbell, CalendarDays, Inbox, Play, Pause, Fingerprint, ChevronRight, Zap, Clock } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";

function localToday(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

function LiveClock() {
  const [now, setNow] = useState(new Date());
  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(id);
  }, []);
  const hh = now.getHours().toString().padStart(2, "0");
  const mm = now.getMinutes().toString().padStart(2, "0");
  const ss = now.getSeconds().toString().padStart(2, "0");
  const dateStr = now.toLocaleDateString("en-AE", { weekday: "long", month: "long", day: "numeric" });
  return (
    <div className="flex flex-col items-center pt-5 pb-4">
      <div
        className="text-7xl font-black text-white tracking-tighter leading-none"
        style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
      >
        {hh}:{mm}
        <span style={{ color: "#dc143c", fontSize: "0.55em", verticalAlign: "middle", marginLeft: 2 }}>:{ss}</span>
      </div>
      <p
        className="text-[11px] text-white/30 mt-2 tracking-widest uppercase"
        style={{ fontFamily: "'JetBrains Mono', monospace" }}
      >
        {dateStr}
      </p>
    </div>
  );
}

function StatPill({
  icon: Icon, value, label, sub, color, onClick,
}: {
  icon: React.ElementType; value: number | string; label: string; sub?: string;
  color?: string; onClick?: () => void;
}) {
  const accent = color || "#dc143c";
  return (
    <button
      onClick={onClick}
      className="flex-1 rounded-2xl p-4 flex flex-col gap-1 transition-all active:scale-[0.96] text-left"
      style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}
    >
      <div
        className="w-8 h-8 rounded-xl flex items-center justify-center mb-1"
        style={{ background: `${accent}18` }}
      >
        <Icon size={15} color={accent} />
      </div>
      <div
        className="text-4xl font-black text-white leading-none"
        style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
      >
        {value}
      </div>
      <div
        className="text-[10px] font-black text-white/35 uppercase tracking-wide leading-tight"
        style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
      >
        {label}
      </div>
      {sub && (
        <div className="text-[9px] mt-0.5" style={{ color: accent, fontFamily: "'JetBrains Mono', monospace" }}>
          {sub}
        </div>
      )}
    </button>
  );
}

function QuickActionButton({
  icon: Icon, label, active, color, onClick, disabled,
}: {
  icon: React.ElementType; label: string; active: boolean;
  color: string; onClick: () => void; disabled?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="flex-1 flex items-center justify-center gap-2.5 rounded-2xl transition-all active:scale-[0.96] disabled:opacity-30"
      style={{
        height: 52,
        background: active ? `${color}18` : "rgba(255,255,255,0.04)",
        border: `1.5px solid ${active ? color : "rgba(255,255,255,0.07)"}`,
      }}
    >
      <Icon size={17} color={active ? color : "rgba(255,255,255,0.4)"} />
      <span
        className="text-sm font-black uppercase tracking-wide"
        style={{
          color: active ? color : "rgba(255,255,255,0.45)",
          fontFamily: "'Barlow Condensed', sans-serif",
          letterSpacing: "0.06em",
        }}
      >
        {label}
      </span>
    </button>
  );
}

function SessionRow({
  session,
}: {
  session: { memberName: string; time: string; duration: number; location: string; startingSoon?: boolean };
}) {
  return (
    <div
      className="flex items-center gap-3 py-3.5 px-4 rounded-2xl"
      style={{
        background: session.startingSoon ? "rgba(220,20,60,0.07)" : "#141414",
        border: `1px solid ${session.startingSoon ? "rgba(220,20,60,0.3)" : "rgba(255,255,255,0.05)"}`,
      }}
    >
      <div
        className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
        style={{ background: session.startingSoon ? "rgba(220,20,60,0.15)" : "rgba(255,255,255,0.05)" }}
      >
        <Dumbbell size={17} color={session.startingSoon ? "#dc143c" : "rgba(255,255,255,0.35)"} />
      </div>
      <div className="flex-1 min-w-0">
        <p
          className="font-black text-white truncate"
          style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}
        >
          {session.memberName}
        </p>
        <p className="text-xs text-white/35 mt-0.5">
          <span style={{ fontFamily: "'JetBrains Mono', monospace" }}>{session.time}</span>
          {" · "}{session.duration}min · {session.location.split("–")[0].trim()}
        </p>
      </div>
      {session.startingSoon ? (
        <span
          className="text-[10px] font-black px-2.5 py-1 rounded-lg shrink-0"
          style={{ background: "rgba(220,20,60,0.2)", color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}
        >
          SOON
        </span>
      ) : (
        <ChevronRight size={14} color="rgba(255,255,255,0.15)" />
      )}
    </div>
  );
}

function SectionHeader({ label, action, onAction }: { label: React.ReactNode; action?: string; onAction?: () => void }) {
  return (
    <div className="flex items-center justify-between mb-3">
      <h2
        className="text-base font-black text-white uppercase"
        style={{ fontFamily: "'Barlow Condensed', sans-serif", letterSpacing: "0.06em" }}
      >
        {label}
      </h2>
      {action && (
        <button
          onClick={onAction}
          className="text-xs font-black"
          style={{ color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif", letterSpacing: "0.05em" }}
        >
          {action}
        </button>
      )}
    </div>
  );
}

export default function Home() {
  const { currentCoach } = useAuth();
  const { t, isAr } = useLang();
  const {
    sessions, requests, classes, shiftStatus,
    startBreak, endBreak, startPersonalTraining, endPersonalTraining,
    activeBreak, activeTraining, checkedIn,
  } = useData();
  const navigate = useNavigate();

  // Local timezone safe
  const today = localToday();
  const todaySessions  = sessions.filter(s => s.date === today && s.status === "upcoming");
  const todayClasses   = classes.filter(c => c.date === today);
  const pendingCount   = requests.filter(r => r.status === "pending").length;
  const startingSoon   = todaySessions.filter(s => s.startingSoon).length;

  const hour = new Date().getHours();
  const greeting = hour < 12 ? t("good_morning") : hour < 17 ? t("good_afternoon") : t("good_evening");
  const coachName = isAr ? currentCoach?.nameAr : currentCoach?.name;

  const shiftBadgeColors: Record<string, { bg: string; text: string }> = {
    on_shift: { bg: "rgba(34,197,94,0.12)",  text: "#22c55e" },
    off:      { bg: "rgba(100,100,100,0.12)", text: "#666" },
    break:    { bg: "rgba(245,158,11,0.12)", text: "#f59e0b" },
    training: { bg: "rgba(59,130,246,0.12)", text: "#3b82f6" },
  };
  const shiftLabels: Record<string, string> = {
    on_shift: "ON SHIFT", off: "OFF DUTY", break: "ON BREAK", training: "TRAINING",
  };
  const sc = shiftBadgeColors[shiftStatus] || shiftBadgeColors.on_shift;

  return (
    <div className="flex flex-col pb-6 px-4 gap-5 overflow-y-auto h-full">

      {/* ── Greeting row ── */}
      <div className="flex items-center justify-between pt-5">
        <div>
          <p className="text-xs text-white/35" style={{ fontFamily: "'Inter', sans-serif" }}>{greeting}</p>
          <h1
            className="text-2xl font-black text-white leading-tight mt-0.5"
            style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
          >
            {coachName}
          </h1>
        </div>
        <span
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11px] font-black uppercase tracking-wide"
          style={{ background: sc.bg, color: sc.text, fontFamily: "'Barlow Condensed', sans-serif" }}
        >
          <span className="w-1.5 h-1.5 rounded-full animate-pulse" style={{ background: sc.text }} />
          {shiftLabels[shiftStatus]}
        </span>
      </div>

      {/* ── Clock card ── */}
      <div
        className="rounded-3xl overflow-hidden"
        style={{ background: "#111", border: "1px solid rgba(255,255,255,0.05)" }}
      >
        <LiveClock />

        {/* Quick actions — stacked full-width rows */}
        <div className="flex gap-2.5 px-4 pb-4">
          <QuickActionButton
            icon={Pause}
            label={activeBreak ? t("end_break") : t("start_break")}
            active={!!activeBreak}
            color="#f59e0b"
            onClick={() => navigate("/time")}
            disabled={!!activeTraining}
          />
          <QuickActionButton
            icon={Fingerprint}
            label={checkedIn ? t("check_out") : t("check_in")}
            active={checkedIn}
            color={checkedIn ? "#22c55e" : "#dc143c"}
            onClick={() => navigate("/attendance")}
          />
        </div>
      </div>

      {/* ── Today at a glance ── */}
      <div>
        <SectionHeader label="Today" />
        <div className="flex gap-2.5">
          <StatPill
            icon={Dumbbell}
            value={todaySessions.length}
            label="PT Sessions"
            sub={startingSoon > 0 ? `${startingSoon} starting soon` : undefined}
            color="#dc143c"
            onClick={() => navigate("/schedule")}
          />
          <StatPill
            icon={CalendarDays}
            value={todayClasses.length}
            label="Classes"
            color="#60a5fa"
            onClick={() => navigate("/schedule")}
          />
          <StatPill
            icon={Inbox}
            value={pendingCount}
            label="Requests"
            color="#f59e0b"
            onClick={() => navigate("/requests")}
          />
        </div>
      </div>

      {/* ── Upcoming sessions ── */}
      {todaySessions.length > 0 && (
        <div>
          <SectionHeader
            label={
              <><Zap size={14} className="inline mr-1" style={{ color: "#dc143c", verticalAlign: "-2px" }} />PT Sessions</>
            }
            action="SEE ALL"
            onAction={() => navigate("/schedule")}
          />
          <div className="flex flex-col gap-2">
            {todaySessions.slice(0, 3).map(s => (
              <SessionRow key={s.id} session={s} />
            ))}
          </div>
        </div>
      )}

      {/* ── Time Tracking ── */}
      <div>
        <SectionHeader
          label={
            <><Clock size={13} className="inline mr-1" style={{ color: "#dc143c", verticalAlign: "-2px" }} />{t("time_tracking")}</>
          }
          action="OPEN"
          onAction={() => navigate("/time")}
        />
        <div className="flex gap-2.5">
          <button
            onClick={activeBreak ? endBreak : startBreak}
            disabled={!!activeTraining}
            className="flex-1 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all active:scale-[0.96] disabled:opacity-30"
            style={{
              background: activeBreak ? "rgba(245,158,11,0.1)" : "#141414",
              border: `1px solid ${activeBreak ? "rgba(245,158,11,0.35)" : "rgba(255,255,255,0.06)"}`,
            }}
          >
            <Pause size={20} color={activeBreak ? "#f59e0b" : "rgba(255,255,255,0.35)"} />
            <span
              className="text-sm font-black text-center uppercase"
              style={{ color: activeBreak ? "#f59e0b" : "rgba(255,255,255,0.4)", fontFamily: "'Barlow Condensed', sans-serif" }}
            >
              {activeBreak ? t("end_break") : t("start_break")}
            </span>
          </button>
          <button
            onClick={activeTraining ? endPersonalTraining : startPersonalTraining}
            disabled={!!activeBreak}
            className="flex-1 rounded-2xl p-4 flex flex-col items-center gap-2 transition-all active:scale-[0.96] disabled:opacity-30"
            style={{
              background: activeTraining ? "rgba(59,130,246,0.1)" : "#141414",
              border: `1px solid ${activeTraining ? "rgba(59,130,246,0.35)" : "rgba(255,255,255,0.06)"}`,
            }}
          >
            <Play size={20} color={activeTraining ? "#3b82f6" : "rgba(255,255,255,0.35)"} />
            <span
              className="text-sm font-black text-center uppercase"
              style={{ color: activeTraining ? "#3b82f6" : "rgba(255,255,255,0.4)", fontFamily: "'Barlow Condensed', sans-serif" }}
            >
              {activeTraining ? t("end_pt") : t("start_pt")}
            </span>
          </button>
        </div>
      </div>
    </div>
  );
}
