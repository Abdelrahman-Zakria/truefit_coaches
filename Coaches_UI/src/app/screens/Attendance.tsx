import React, { useState, useRef } from "react";
import { Fingerprint, CheckCircle, Clock, MapPin } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import type { AttendanceEntry } from "../context/DataContext";

const MOCK_LOCATION = "True Fit Gym – Al Barsha, Dubai (25.1123, 55.1987)";

function AttendanceRow({ entry }: { entry: AttendanceEntry }) {
  const duration = entry.timeOut && entry.timeIn
    ? (() => {
      const [h1, m1] = entry.timeIn.split(":").map(Number);
      const [h2, m2] = (entry.timeOut || "").split(":").map(Number);
      const mins = (h2 * 60 + m2) - (h1 * 60 + m1);
      if (isNaN(mins) || mins < 0) return "—";
      return `${Math.floor(mins / 60)}h ${mins % 60}m`;
    })()
    : "In Progress";

  return (
    <div className="rounded-2xl p-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
      <div className="flex items-start justify-between mb-3">
        <div>
          <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{entry.date}</p>
          <div className="flex items-center gap-1 mt-0.5">
            <MapPin size={10} color="rgba(255,255,255,0.3)" />
            <p className="text-[10px] text-white/30 truncate max-w-[180px]" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{entry.location.split("(")[0].trim()}</p>
          </div>
        </div>
        <span className="text-xs font-black px-2 py-0.5 rounded" style={{
          background: entry.timeOut ? "rgba(136,136,136,0.12)" : "rgba(34,197,94,0.12)",
          color: entry.timeOut ? "#888" : "#22c55e",
          fontFamily: "'Barlow Condensed', sans-serif",
        }}>
          {entry.timeOut ? duration : "ACTIVE"}
        </span>
      </div>
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-1.5">
          <Clock size={12} color="#22c55e" />
          <span className="text-xs font-bold" style={{ color: "#22c55e", fontFamily: "'JetBrains Mono', monospace" }}>IN {entry.timeIn}</span>
        </div>
        {entry.timeOut && (
          <div className="flex items-center gap-1.5">
            <Clock size={12} color="#888" />
            <span className="text-xs font-bold" style={{ color: "#888", fontFamily: "'JetBrains Mono', monospace" }}>OUT {entry.timeOut}</span>
          </div>
        )}
      </div>
    </div>
  );
}

export default function Attendance() {
  const { t } = useLang();
  const { checkedIn, currentAttendance, attendance, checkIn, checkOut } = useData();
  const [holding, setHolding] = useState(false);
  const [progress, setProgress] = useState(0);
  const [confirmed, setConfirmed] = useState(false);
  const holdRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const startRef = useRef<number>(0);

  const startHold = () => {
    if (checkedIn) {
      checkOut();
      return;
    }
    setHolding(true);
    setProgress(0);
    startRef.current = Date.now();
    holdRef.current = setInterval(() => {
      const elapsed = Date.now() - startRef.current;
      const pct = Math.min((elapsed / 2000) * 100, 100);
      setProgress(pct);
      if (pct >= 100) {
        clearInterval(holdRef.current!);
        setHolding(false);
        setConfirmed(true);
        checkIn(MOCK_LOCATION);
        setTimeout(() => setConfirmed(false), 2000);
      }
    }, 50);
  };

  const cancelHold = () => {
    if (holdRef.current) clearInterval(holdRef.current);
    setHolding(false);
    setProgress(0);
  };

  const radius = 70;
  const circ = 2 * Math.PI * radius;
  const offset = circ - (progress / 100) * circ;

  const allHistory = [
    ...(currentAttendance ? [currentAttendance] : []),
    ...[...attendance].reverse(),
  ];

  return (
    <div className="pb-4 px-4 overflow-y-auto h-full">
      <div className="pt-4 mb-6">
        <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("attendance")}
        </h1>
      </div>

      {/* Fingerprint Scanner */}
      <div className="flex flex-col items-center py-8 mb-6">
        <div className="relative mb-6">
          {/* Progress ring */}
          <svg width={180} height={180} className="-rotate-90">
            <circle cx={90} cy={90} r={radius} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth={5} />
            {holding && (
              <circle cx={90} cy={90} r={radius} fill="none" stroke="#dc143c" strokeWidth={5}
                strokeDasharray={circ} strokeDashoffset={offset} strokeLinecap="round"
                style={{ transition: "stroke-dashoffset 0.05s linear" }}
              />
            )}
            {checkedIn && (
              <circle cx={90} cy={90} r={radius} fill="none" stroke="#22c55e" strokeWidth={5}
                strokeDasharray={circ} strokeDashoffset={0}
              />
            )}
          </svg>
          <button
            onMouseDown={startHold} onMouseUp={cancelHold} onMouseLeave={cancelHold}
            onTouchStart={startHold} onTouchEnd={cancelHold}
            className="absolute inset-0 flex flex-col items-center justify-center transition-all active:scale-95"
            style={{ borderRadius: "50%" }}
          >
            {confirmed ? (
              <CheckCircle size={48} color="#22c55e" />
            ) : (
              <Fingerprint
                size={56}
                color={checkedIn ? "#22c55e" : holding ? "#dc143c" : "rgba(255,255,255,0.3)"}
                style={{ filter: holding ? "drop-shadow(0 0 12px #dc143c)" : checkedIn ? "drop-shadow(0 0 12px #22c55e)" : "none" }}
              />
            )}
          </button>
        </div>

        {checkedIn ? (
          <div className="text-center">
            <p className="text-lg font-black text-white mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
              ✓ {t("confirmed")}
            </p>
            {currentAttendance && (
              <p className="text-xs text-white/40" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
                Since {currentAttendance.timeIn}
              </p>
            )}
            <p className="text-xs text-white/30 mt-1">Tap fingerprint to Check Out</p>
          </div>
        ) : (
          <div className="text-center">
            <p className="text-sm font-black text-white/50 uppercase tracking-widest" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
              {holding ? `Scanning... ${Math.round(progress)}%` : t("hold_to_checkin")}
            </p>
            <p className="text-xs text-white/20 mt-1">Hold for 2 seconds</p>
          </div>
        )}

        {currentAttendance && (
          <div className="mt-4 rounded-xl px-4 py-3 flex items-center gap-2" style={{ background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.2)" }}>
            <MapPin size={13} color="#22c55e" />
            <p className="text-xs text-white/50" style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 10 }}>
              {MOCK_LOCATION.split(" (")[0]}
            </p>
          </div>
        )}
      </div>

      {/* History */}
      <div>
        <p className="text-xs text-white/40 uppercase tracking-widest font-bold mb-3" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("attendance_history")}
        </p>
        {allHistory.length === 0
          ? <div className="text-center py-12 text-white/20 text-sm" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{t("no_data")}</div>
          : <div className="space-y-2">
            {allHistory.map(a => <AttendanceRow key={a.id} entry={a} />)}
          </div>
        }
      </div>
    </div>
  );
}
