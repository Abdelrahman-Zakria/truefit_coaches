import React, { useState, useEffect } from "react";
import { Pause, Play, Clock } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import type { TimeEntry } from "../context/DataContext";

function ElapsedTimer({ startTime }: { startTime: string }) {
  const [elapsed, setElapsed] = useState(0);
  useEffect(() => {
    const update = () => setElapsed(Math.floor((Date.now() - new Date(startTime).getTime()) / 1000));
    update();
    const id = setInterval(update, 1000);
    return () => clearInterval(id);
  }, [startTime]);
  const m = Math.floor(elapsed / 60).toString().padStart(2, "0");
  const s = (elapsed % 60).toString().padStart(2, "0");
  return <span style={{ fontFamily: "'JetBrains Mono', monospace" }}>{m}:{s}</span>;
}

function ActionButton({
  active, onStart, onEnd, startLabel, endLabel, startIcon: StartIcon, endIcon: EndIcon, activeColor, disabled,
}: {
  active: boolean; onStart: () => void; onEnd: () => void;
  startLabel: string; endLabel: string;
  startIcon: React.ElementType; endIcon: React.ElementType;
  activeColor: string; disabled?: boolean;
}) {
  return (
    <button
      onClick={active ? onEnd : onStart}
      disabled={disabled}
      className="flex-1 rounded-2xl p-5 flex flex-col items-center gap-3 transition-all active:scale-95 disabled:opacity-30"
      style={{
        background: active ? `${activeColor}20` : "#141414",
        border: `2px solid ${active ? activeColor : "rgba(255,255,255,0.06)"}`,
      }}
    >
      {active
        ? <EndIcon size={32} color={activeColor} />
        : <StartIcon size={32} color="rgba(255,255,255,0.4)" />
      }
      <span className="text-base font-black uppercase tracking-wide text-center"
        style={{ color: active ? activeColor : "rgba(255,255,255,0.6)", fontFamily: "'Barlow Condensed', sans-serif" }}>
        {active ? endLabel : startLabel}
      </span>
    </button>
  );
}

function HistoryItem({ entry }: { entry: TimeEntry }) {
  const isBreak = entry.type === "break";
  const color = isBreak ? "#f59e0b" : "#3b82f6";
  const label = isBreak ? "Break" : "Coach PT";
  const startTime = new Date(entry.startTime).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  const endTime = entry.endTime ? new Date(entry.endTime).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) : "—";
  return (
    <div className="rounded-2xl p-4 flex items-center gap-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
      <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
        style={{ background: `${color}15` }}>
        <Clock size={18} color={color} />
      </div>
      <div className="flex-1">
        <div className="flex items-center gap-2">
          <span className="text-xs font-black px-2 py-0.5 rounded" style={{ background: `${color}18`, color, fontFamily: "'Barlow Condensed', sans-serif" }}>
            {label}
          </span>
          {entry.duration !== undefined && (
            <span className="text-xs font-bold" style={{ color: "rgba(255,255,255,0.4)", fontFamily: "'JetBrains Mono', monospace" }}>
              {entry.duration}min
            </span>
          )}
        </div>
        <p className="text-xs text-white/30 mt-1" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
          {startTime} → {endTime}
        </p>
      </div>
    </div>
  );
}

export default function TimeTracking() {
  const { t } = useLang();
  const { activeBreak, activeTraining, timeEntries, startBreak, endBreak, startPersonalTraining, endPersonalTraining } = useData();

  return (
    <div className="pb-4 px-4 overflow-y-auto h-full">
      <div className="pt-4 mb-6">
        <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("time_tracking")}
        </h1>
        <p className="text-xs text-white/30 mt-0.5" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
          {new Date().toLocaleDateString("en-AE", { weekday: "long", month: "long", day: "numeric" })}
        </p>
      </div>

      {/* Active Status */}
      {(activeBreak || activeTraining) && (
        <div className="rounded-2xl p-4 mb-4 flex items-center gap-3"
          style={{
            background: activeBreak ? "rgba(245,158,11,0.08)" : "rgba(59,130,246,0.08)",
            border: `1px solid ${activeBreak ? "rgba(245,158,11,0.3)" : "rgba(59,130,246,0.3)"}`,
          }}>
          <div className="w-2 h-2 rounded-full animate-pulse" style={{ background: activeBreak ? "#f59e0b" : "#3b82f6" }} />
          <div>
            <p className="text-xs font-black uppercase tracking-widest" style={{ color: activeBreak ? "#f59e0b" : "#3b82f6", fontFamily: "'Barlow Condensed', sans-serif" }}>
              {activeBreak ? "Break in progress" : "Coach training in progress"}
            </p>
            <p className="text-2xl font-black text-white mt-0.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
              <ElapsedTimer startTime={(activeBreak || activeTraining)!.startTime} />
            </p>
          </div>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex gap-3 mb-6">
        <ActionButton
          active={!!activeBreak} onStart={startBreak} onEnd={endBreak}
          startLabel={t("start_break")} endLabel={t("end_break")}
          startIcon={Pause} endIcon={Pause}
          activeColor="#f59e0b"
          disabled={!!activeTraining}
        />
        <ActionButton
          active={!!activeTraining} onStart={startPersonalTraining} onEnd={endPersonalTraining}
          startLabel={t("start_pt")} endLabel={t("end_pt")}
          startIcon={Play} endIcon={Play}
          activeColor="#3b82f6"
          disabled={!!activeBreak}
        />
      </div>

      {/* History */}
      <div>
        <p className="text-xs text-white/40 uppercase tracking-widest font-bold mb-3" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("session_history")}
        </p>
        {timeEntries.length === 0
          ? <div className="text-center py-12 text-white/20 text-sm" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{t("no_data")}</div>
          : <div className="space-y-2">
            {[...timeEntries].reverse().map(e => <HistoryItem key={e.id} entry={e} />)}
          </div>
        }
      </div>
    </div>
  );
}
