import React, { useState } from "react";
import { ChevronLeft, ChevronRight, Clock, MapPin, Users } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { BottomSheet } from "../components/BottomSheet";
import type { PTSession, GymClass, WorkShift } from "../context/DataContext";

// ─── helpers ────────────────────────────────────────────────────────────────

const DAYS_EN = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const DAYS_AR = ["إث", "ثل", "أر", "خم", "جم", "سب", "أح"];

const DAY_FULL_EN = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

// Use local date parts (not UTC) to avoid timezone-shift bugs in UTC+ regions
function localISO(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

/** Returns the Monday of the current week + offset weeks */
function getWeekDates(offset = 0) {
  const now = new Date();
  const dayOfWeek = now.getDay(); // 0=Sun … 6=Sat
  const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  const monday = new Date(now);
  monday.setDate(now.getDate() + diff + offset * 7);
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    return d;
  });
}

function toISO(d: Date) {
  return localISO(d);
}

/** Convert "HH:MM" to fractional hours from midnight */
function timeToH(t: string) {
  const [h, m] = t.split(":").map(Number);
  return h + m / 60;
}

// ─── Weekly mini-chart constants ─────────────────────────────────────────────
const CHART_START = 6;   // 6 am
const CHART_END   = 23;  // 11 pm
const CHART_SPAN  = CHART_END - CHART_START; // 17 hours

function pct(h: number) {
  return Math.max(0, Math.min(100, ((h - CHART_START) / CHART_SPAN) * 100));
}

// ─── Day-timeline constants ──────────────────────────────────────────────────
const TL_START  = 6;
const TL_END    = 23;
const TL_SPAN   = TL_END - TL_START;
const HOUR_H    = 64; // px per hour

function tlTop(time: string) {
  return (timeToH(time) - TL_START) * HOUR_H;
}
function tlHeight(duration: number) {
  return (duration / 60) * HOUR_H;
}

// ─── Sub-components ──────────────────────────────────────────────────────────

/** Compact weekly overview strip – shows shift bar + PT dots + class diamonds */
function WeekStrip({
  dates, selectedDate, onSelect,
  sessions, classes, shifts, days,
}: {
  dates: Date[]; selectedDate: string; onSelect: (d: string) => void;
  sessions: PTSession[]; classes: GymClass[]; shifts: WorkShift[];
  days: string[];
}) {
  const today = toISO(new Date());

  return (
    <div className="flex gap-1">
      {dates.map((date, i) => {
        const ds = toISO(date);
        const isSel  = ds === selectedDate;
        const isToday = ds === today;
        const dayShift  = shifts.find(s => s.date === ds);
        const daySessions = sessions.filter(s => s.date === ds);
        const dayClasses  = classes.filter(c => c.date === ds);
        const isOff = !dayShift;

        // shift bar boundaries in %
        const shiftLeft  = dayShift ? pct(timeToH(dayShift.startTime)) : 0;
        const shiftRight = dayShift ? pct(timeToH(dayShift.endTime))   : 0;
        const shiftW     = shiftRight - shiftLeft;

        return (
          <button
            key={ds}
            onClick={() => onSelect(ds)}
            className="flex-1 flex flex-col items-center gap-1 rounded-xl py-2 px-0.5 transition-all"
            style={{
              background: isSel ? "#1a1a1a" : "transparent",
              border: isSel ? "1px solid rgba(220,20,60,0.5)" : "1px solid transparent",
            }}
          >
            {/* Day label */}
            <span
              className="text-[10px] font-black uppercase tracking-wider"
              style={{
                color: isSel ? "#dc143c" : isToday ? "#dc143c" : "rgba(255,255,255,0.35)",
                fontFamily: "'Barlow Condensed', sans-serif",
              }}
            >
              {days[i]}
            </span>

            {/* Date number */}
            <span
              className="text-base font-black leading-none"
              style={{
                color: isSel ? "#fff" : isToday ? "#dc143c" : "rgba(255,255,255,0.7)",
                fontFamily: "'Barlow Condensed', sans-serif",
              }}
            >
              {date.getDate()}
            </span>

            {/* Mini timeline bar – 6px tall strip */}
            <div className="relative w-full rounded-full overflow-hidden" style={{ height: 5, background: "rgba(255,255,255,0.06)" }}>
              {dayShift && (
                <div
                  className="absolute h-full rounded-full"
                  style={{
                    left: `${shiftLeft}%`,
                    width: `${shiftW}%`,
                    background: dayShift.status === "completed" ? "rgba(34,197,94,0.4)" : "rgba(34,197,94,0.7)",
                  }}
                />
              )}
            </div>

            {/* Session/class dot row */}
            <div className="flex items-center gap-0.5 justify-center min-h-[10px]">
              {daySessions.slice(0, 4).map((_, idx) => (
                <span key={idx} className="w-1.5 h-1.5 rounded-full" style={{ background: "#dc143c" }} />
              ))}
              {daySessions.length > 4 && (
                <span className="text-[8px] font-black" style={{ color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>+{daySessions.length - 4}</span>
              )}
              {dayClasses.slice(0, 3).map((_, idx) => (
                <span key={`c${idx}`} className="w-1.5 h-1.5 rounded-sm rotate-45" style={{ background: "#60a5fa" }} />
              ))}
              {isOff && (
                <span className="text-[9px]" style={{ color: "rgba(255,255,255,0.2)", fontFamily: "'Barlow Condensed', sans-serif" }}>—</span>
              )}
            </div>
          </button>
        );
      })}
    </div>
  );
}

/** Legend row */
function Legend() {
  return (
    <div className="flex items-center gap-4 px-1">
      <div className="flex items-center gap-1.5">
        <div className="w-2 h-2 rounded-full" style={{ background: "rgba(34,197,94,0.7)" }} />
        <span className="text-[10px] text-white/30 font-bold uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Shift</span>
      </div>
      <div className="flex items-center gap-1.5">
        <div className="w-2 h-2 rounded-full" style={{ background: "#dc143c" }} />
        <span className="text-[10px] text-white/30 font-bold uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>PT</span>
      </div>
      <div className="flex items-center gap-1.5">
        <div className="w-2 h-2 rounded-sm rotate-45" style={{ background: "#60a5fa" }} />
        <span className="text-[10px] text-white/30 font-bold uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Class</span>
      </div>
    </div>
  );
}

/** Day summary stat pills */
function DaySummary({ sessions, classes, shift }: { sessions: PTSession[]; classes: GymClass[]; shift?: WorkShift }) {
  return (
    <div className="flex items-center gap-2 flex-wrap">
      {shift ? (
        <span className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-black"
          style={{ background: "rgba(34,197,94,0.1)", color: "#22c55e", border: "1px solid rgba(34,197,94,0.2)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          <Clock size={11} />
          {shift.startTime}–{shift.endTime}
        </span>
      ) : (
        <span className="px-2.5 py-1.5 rounded-lg text-xs font-black" style={{ background: "rgba(255,255,255,0.04)", color: "rgba(255,255,255,0.25)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          Day Off
        </span>
      )}
      {sessions.length > 0 && (
        <span className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-black"
          style={{ background: "rgba(220,20,60,0.1)", color: "#dc143c", border: "1px solid rgba(220,20,60,0.2)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          {sessions.length} PT
        </span>
      )}
      {classes.length > 0 && (
        <span className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-black"
          style={{ background: "rgba(96,165,250,0.1)", color: "#60a5fa", border: "1px solid rgba(96,165,250,0.2)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          <Users size={11} />
          {classes.length} Classes
        </span>
      )}
    </div>
  );
}

/** Vertical day timeline with sessions + classes + shift block */
function DayTimeline({
  sessions, classes, shift, onSelectEvent, isToday,
}: {
  sessions: PTSession[];
  classes: GymClass[];
  shift?: WorkShift;
  onSelectEvent: (e: PTSession | GymClass) => void;
  isToday: boolean;
}) {
  const totalH = TL_SPAN * HOUR_H;
  const hours = Array.from({ length: TL_SPAN + 1 }, (_, i) => TL_START + i);

  return (
    <div className="relative flex" style={{ minHeight: totalH + 32 }}>
      {/* Time axis */}
      <div className="shrink-0 w-12 relative" style={{ height: totalH }}>
        {hours.map(h => (
          <div
            key={h}
            className="absolute w-full flex items-center justify-end pr-2"
            style={{ top: (h - TL_START) * HOUR_H - 8 }}
          >
            <span className="text-[9px] font-bold" style={{ color: "rgba(255,255,255,0.2)", fontFamily: "'JetBrains Mono', monospace" }}>
              {h === 12 ? "12p" : h > 12 ? `${h - 12}p` : `${h}a`}
            </span>
          </div>
        ))}
      </div>

      {/* Vertical grid lines + events column */}
      <div className="flex-1 relative ml-2" style={{ height: totalH }}>
        {/* Hour grid lines */}
        {hours.map(h => (
          <div
            key={h}
            className="absolute w-full"
            style={{
              top: (h - TL_START) * HOUR_H,
              height: 1,
              background: h % 2 === 0 ? "rgba(255,255,255,0.05)" : "rgba(255,255,255,0.02)",
            }}
          />
        ))}

        {/* Shift background band */}
        {shift && (
          <div
            className="absolute left-0 right-0 rounded-xl"
            style={{
              top: tlTop(shift.startTime),
              height: tlHeight((timeToH(shift.endTime) - timeToH(shift.startTime)) * 60),
              background: "rgba(34,197,94,0.04)",
              borderLeft: "2px solid rgba(34,197,94,0.2)",
            }}
          />
        )}

        {/* PT Session blocks */}
        {sessions.map(s => {
          const top    = tlTop(s.time);
          const height = Math.max(tlHeight(s.duration), 36);
          return (
            <button
              key={s.id}
              onClick={() => onSelectEvent(s)}
              className="absolute left-0 right-1 rounded-xl px-3 py-2 text-left transition-all active:scale-[0.98] overflow-hidden"
              style={{
                top, height,
                background: s.startingSoon ? "rgba(220,20,60,0.25)" : s.status === "completed" ? "rgba(255,255,255,0.05)" : "rgba(220,20,60,0.15)",
                border: s.startingSoon ? "1px solid rgba(220,20,60,0.6)" : s.status === "completed" ? "1px solid rgba(255,255,255,0.08)" : "1px solid rgba(220,20,60,0.3)",
              }}
            >
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-black px-1.5 py-0.5 rounded"
                  style={{ background: s.status === "completed" ? "rgba(255,255,255,0.1)" : "rgba(220,20,60,0.3)", color: s.status === "completed" ? "rgba(255,255,255,0.4)" : "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
                  PT
                </span>
                {s.startingSoon && <span className="w-1.5 h-1.5 rounded-full animate-ping" style={{ background: "#dc143c" }} />}
              </div>
              <p className="text-xs font-black text-white mt-0.5 truncate" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 13 }}>
                {s.memberName}
              </p>
              {height > 46 && (
                <p className="text-[10px] truncate" style={{ color: "rgba(255,255,255,0.4)", fontFamily: "'JetBrains Mono', monospace" }}>
                  {s.time} · {s.location.split("–")[0].trim()}
                </p>
              )}
            </button>
          );
        })}

        {/* Class blocks */}
        {classes.map(c => {
          const top    = tlTop(c.time);
          const height = Math.max(tlHeight(c.duration), 36);
          return (
            <button
              key={c.id}
              onClick={() => onSelectEvent(c)}
              className="absolute rounded-xl px-3 py-2 text-left transition-all active:scale-[0.98] overflow-hidden"
              style={{
                top, height,
                left: "40%", right: 1,
                background: "rgba(96,165,250,0.12)",
                border: "1px solid rgba(96,165,250,0.3)",
              }}
            >
              <span className="text-[10px] font-black px-1.5 py-0.5 rounded"
                style={{ background: "rgba(96,165,250,0.2)", color: "#60a5fa", fontFamily: "'Barlow Condensed', sans-serif" }}>
                CLASS
              </span>
              <p className="text-xs font-black text-white mt-0.5 truncate" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 12 }}>
                {c.name}
              </p>
              {height > 46 && (
                <p className="text-[10px]" style={{ color: "rgba(255,255,255,0.4)", fontFamily: "'JetBrains Mono', monospace" }}>
                  {c.time} · {c.location}
                </p>
              )}
            </button>
          );
        })}

        {/* Current time indicator — only rendered for today */}
        {isToday && (() => {
          const now = new Date();
          const nowH = now.getHours() + now.getMinutes() / 60;
          if (nowH < TL_START || nowH > TL_END) return null;
          return (
            <div className="absolute left-0 right-0 flex items-center gap-1.5 pointer-events-none z-10" style={{ top: (nowH - TL_START) * HOUR_H }}>
              <div className="w-2 h-2 rounded-full shrink-0" style={{ background: "#dc143c", boxShadow: "0 0 8px #dc143c" }} />
              <div className="flex-1 h-px" style={{ background: "#dc143c", opacity: 0.7 }} />
              <span className="text-[9px] font-black shrink-0 pr-1" style={{ color: "#dc143c", fontFamily: "'JetBrains Mono', monospace" }}>
                {now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              </span>
            </div>
          );
        })()}
      </div>
    </div>
  );
}

// ─── Event detail sheet content ───────────────────────────────────────────────

function PTDetail({ s }: { s: PTSession }) {
  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs text-white/30 uppercase tracking-widest mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>PT Session</p>
        <p className="text-3xl font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{s.memberName}</p>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <DetailPill icon={Clock}  label="Time"     value={s.time} />
        <DetailPill icon={Clock}  label="Duration" value={`${s.duration} min`} />
        <DetailPill icon={MapPin} label="Location" value={s.location} />
        <DetailPill icon={Clock}  label="Status"   value={s.status} />
      </div>
      {s.startingSoon && (
        <div className="rounded-xl p-3 text-sm font-black text-center"
          style={{ background: "rgba(220,20,60,0.12)", color: "#dc143c", border: "1px solid rgba(220,20,60,0.3)" }}>
          ⚡ Starting within 30 minutes!
        </div>
      )}
    </div>
  );
}

function ClassDetail({ c }: { c: GymClass }) {
  const fillPct = Math.round((c.enrolled / c.capacity) * 100);
  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs text-white/30 uppercase tracking-widest mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Group Class</p>
        <p className="text-3xl font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{c.name}</p>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <DetailPill icon={Clock}  label="Time"       value={c.time} />
        <DetailPill icon={Clock}  label="Duration"   value={`${c.duration} min`} />
        <DetailPill icon={MapPin} label="Location"   value={c.location} />
        <DetailPill icon={Users}  label="Instructor" value={c.instructor} />
      </div>
      <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
        <div className="flex justify-between items-center mb-2">
          <span className="text-xs text-white/40 uppercase tracking-wide font-bold" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Capacity</span>
          <span className="text-sm font-black" style={{ fontFamily: "'JetBrains Mono', monospace", color: fillPct >= 100 ? "#dc143c" : "#22c55e" }}>
            {c.enrolled} / {c.capacity}
          </span>
        </div>
        <div className="h-2 rounded-full overflow-hidden" style={{ background: "rgba(255,255,255,0.06)" }}>
          <div className="h-full rounded-full transition-all" style={{ width: `${fillPct}%`, background: fillPct >= 100 ? "#dc143c" : "#22c55e" }} />
        </div>
      </div>
      <div className="flex items-center justify-between">
        <span className="text-sm font-bold" style={{ color: c.isOpen ? "#22c55e" : "#888", fontFamily: "'Barlow Condensed', sans-serif" }}>
          {c.isOpen ? "● Open" : "● Closed"}
        </span>
      </div>
    </div>
  );
}

function DetailPill({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: string }) {
  return (
    <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
      <div className="flex items-center gap-1.5 mb-1">
        <Icon size={11} color="#dc143c" />
        <span className="text-[10px] text-white/35 uppercase tracking-widest" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>{label}</span>
      </div>
      <p className="text-sm font-bold text-white capitalize" style={{ fontFamily: "'Inter', sans-serif" }}>{value}</p>
    </div>
  );
}

// ─── Main screen ──────────────────────────────────────────────────────────────

type FilterTab = "all" | "pt" | "classes" | "shifts";

export default function Schedule() {
  const { isAr } = useLang();
  const { sessions, shifts, classes } = useData();
  const [weekOffset, setWeekOffset]   = useState(0);
  const [selectedDay, setSelectedDay] = useState(toISO(new Date()));
  const [filter, setFilter]           = useState<FilterTab>("all");
  const [detail, setDetail]           = useState<PTSession | GymClass | null>(null);

  const weekDates = getWeekDates(weekOffset);
  const days      = isAr ? DAYS_AR : DAYS_EN;

  const dayShift    = shifts.find(s => s.date === selectedDay);
  const daySessions = sessions.filter(s => s.date === selectedDay);
  const dayClasses  = classes.filter(c => c.date === selectedDay);

  const showSessions = (filter === "all" || filter === "pt")    ? daySessions : [];
  const showClasses  = (filter === "all" || filter === "classes") ? dayClasses  : [];
  const showShift    = (filter === "all" || filter === "shifts")  ? dayShift    : undefined;

  const dayIdx = weekDates.findIndex(d => toISO(d) === selectedDay);
  const dayLabel = dayIdx >= 0
    ? `${DAY_FULL_EN[dayIdx]}, ${weekDates[dayIdx].toLocaleDateString("en-AE", { month: "short", day: "numeric" })}`
    : selectedDay;

  const filters: { key: FilterTab; label: string }[] = [
    { key: "all",     label: "All" },
    { key: "pt",      label: "PT" },
    { key: "classes", label: "Classes" },
    { key: "shifts",  label: "Shifts" },
  ];

  return (
    <div className="pb-4 flex flex-col h-full">
      {/* ── Week navigator ── */}
      <div className="px-4 pt-4 shrink-0">
        <div className="flex items-center justify-between mb-3">
          <button onClick={() => setWeekOffset(v => v - 1)} className="p-2 -ml-2 rounded-full hover:bg-white/5 transition-colors">
            <ChevronLeft size={20} color="rgba(255,255,255,0.5)" />
          </button>
          <span className="text-xs font-black text-white/30 uppercase tracking-widest" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
            {weekDates[0].toLocaleDateString("en-AE", { month: "short", day: "numeric" })}
            &nbsp;–&nbsp;
            {weekDates[6].toLocaleDateString("en-AE", { month: "short", day: "numeric", year: "numeric" })}
          </span>
          <button onClick={() => setWeekOffset(v => v + 1)} className="p-2 -mr-2 rounded-full hover:bg-white/5 transition-colors">
            <ChevronRight size={20} color="rgba(255,255,255,0.5)" />
          </button>
        </div>

        {/* ── Weekly overview strip ── */}
        <WeekStrip
          dates={weekDates} selectedDate={selectedDay} onSelect={setSelectedDay}
          sessions={sessions} classes={classes} shifts={shifts} days={days}
        />

        {/* Legend */}
        <div className="mt-2 mb-3">
          <Legend />
        </div>
      </div>

      {/* ── Day header ── */}
      <div className="px-4 pt-1 pb-3 shrink-0" style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
        <h2 className="text-xl font-black text-white mb-2" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {dayLabel}
        </h2>
        <DaySummary sessions={daySessions} classes={dayClasses} shift={dayShift} />
      </div>

      {/* ── Filter tabs ── */}
      <div className="flex gap-1 px-4 py-3 shrink-0">
        {filters.map(f => (
          <button
            key={f.key}
            onClick={() => setFilter(f.key)}
            className="flex-1 py-2 rounded-xl text-xs font-black uppercase tracking-wide transition-all"
            style={{
              background: filter === f.key ? "#dc143c" : "#141414",
              color:      filter === f.key ? "#fff"    : "rgba(255,255,255,0.4)",
              border:     `1px solid ${filter === f.key ? "#dc143c" : "rgba(255,255,255,0.06)"}`,
              fontFamily: "'Barlow Condensed', sans-serif",
            }}
          >
            {f.label}
          </button>
        ))}
      </div>

      {/* ── Timeline ── */}
      <div className="flex-1 overflow-y-auto px-4 pb-4">
        {showSessions.length === 0 && showClasses.length === 0 && !showShift ? (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <div className="text-4xl" style={{ opacity: 0.15 }}>📋</div>
            <p className="text-sm text-white/20" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
              {filter === "shifts" ? "Day off" : "Nothing scheduled"}
            </p>
          </div>
        ) : (
          <DayTimeline
            sessions={showSessions}
            classes={showClasses}
            shift={showShift}
            onSelectEvent={e => setDetail(e)}
            isToday={selectedDay === toISO(new Date())}
          />
        )}
      </div>

      {/* ── Detail bottom sheet ── */}
      <BottomSheet
        open={!!detail}
        onClose={() => setDetail(null)}
        title={detail && "memberName" in detail ? "PT Session" : "Class Details"}
        height="55vh"
      >
        {detail && "memberName" in detail && <PTDetail s={detail as PTSession} />}
        {detail && "name" in detail && <ClassDetail c={detail as GymClass} />}
      </BottomSheet>
    </div>
  );
}
