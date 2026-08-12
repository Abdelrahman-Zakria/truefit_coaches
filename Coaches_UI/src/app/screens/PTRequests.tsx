import React, { useState } from "react";
import { CheckCircle, XCircle } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { BottomSheet } from "../components/BottomSheet";
import { toast } from "sonner";
import type { PTRequest } from "../context/DataContext";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

function StatusBadge({ status }: { status: PTRequest["status"] }) {
  const styles = {
    pending: { bg: "rgba(245,158,11,0.12)", color: "#f59e0b", label: "PENDING" },
    accepted: { bg: "rgba(34,197,94,0.12)", color: "#22c55e", label: "ACCEPTED" },
    rejected: { bg: "rgba(136,136,136,0.12)", color: "#888", label: "REJECTED" },
  };
  const s = styles[status];
  return (
    <span className="text-[10px] font-black px-2 py-0.5 rounded" style={{ background: s.bg, color: s.color, fontFamily: "'Barlow Condensed', sans-serif" }}>
      {s.label}
    </span>
  );
}

export default function PTRequests() {
  const { t, isAr } = useLang();
  const { requests, acceptRequest, rejectRequest } = useData();
  const [selected, setSelected] = useState<PTRequest | null>(null);
  const [action, setAction] = useState<"accept" | "reject" | null>(null);
  const [selectedDays, setSelectedDays] = useState<string[]>([]);
  const [scheduleTime, setScheduleTime] = useState("");
  const [rejectReason, setRejectReason] = useState("");

  const pending = requests.filter(r => r.status === "pending");
  const handled = requests.filter(r => r.status !== "pending");

  const openAccept = (req: PTRequest) => {
    setSelected(req);
    setAction("accept");
    setSelectedDays([]);
    setScheduleTime("");
  };

  const openReject = (req: PTRequest) => {
    setSelected(req);
    setAction("reject");
    setRejectReason("");
  };

  const handleAccept = () => {
    if (!selected || selectedDays.length === 0 || !scheduleTime) return;
    acceptRequest(selected.id, selectedDays.join(", "), scheduleTime);
    toast.success(`${isAr ? "تم قبول طلب" : "Request accepted for"} ${isAr ? selected.memberNameAr : selected.memberName}`);
    setSelected(null);
    setAction(null);
  };

  const handleReject = () => {
    if (!selected) return;
    rejectRequest(selected.id, rejectReason);
    toast.error(`${isAr ? "تم رفض طلب" : "Request rejected for"} ${isAr ? selected.memberNameAr : selected.memberName}`);
    setSelected(null);
    setAction(null);
  };

  const toggleDay = (d: string) =>
    setSelectedDays(prev => prev.includes(d) ? prev.filter(x => x !== d) : [...prev, d]);

  return (
    <div className="pb-4 px-4 overflow-y-auto h-full">
      <div className="pt-4 mb-4">
        <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("pt_requests")}
        </h1>
        {pending.length > 0 && (
          <p className="text-xs text-white/30 mt-1" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
            {pending.length} pending
          </p>
        )}
      </div>

      {/* Pending */}
      {pending.length > 0 && (
        <div className="mb-6 space-y-3">
          <p className="text-xs text-white/40 uppercase tracking-widest font-bold" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
            Inbox
          </p>
          {pending.map(req => (
            <RequestCard key={req.id} req={req} isAr={isAr} onAccept={() => openAccept(req)} onReject={() => openReject(req)} />
          ))}
        </div>
      )}

      {/* Handled */}
      {handled.length > 0 && (
        <div className="space-y-3">
          <p className="text-xs text-white/40 uppercase tracking-widest font-bold" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
            Handled
          </p>
          {handled.map(req => (
            <div key={req.id} className="rounded-2xl p-4" style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
              <div className="flex items-start justify-between mb-2">
                <div>
                  <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>
                    {isAr ? req.memberNameAr : req.memberName}
                  </p>
                  <p className="text-xs text-white/40">{req.requestedPlan}</p>
                </div>
                <StatusBadge status={req.status} />
              </div>
              {req.status === "accepted" && (
                <p className="text-xs text-white/30 mt-2" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
                  {req.scheduledDays} · {req.scheduledTime}
                </p>
              )}
              {req.status === "rejected" && req.reason && (
                <p className="text-xs mt-2" style={{ color: "#888", fontFamily: "'Inter', sans-serif" }}>
                  Reason: {req.reason}
                </p>
              )}
            </div>
          ))}
        </div>
      )}

      {requests.length === 0 && (
        <div className="text-center py-16 text-white/20 text-sm" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
          {t("no_data")}
        </div>
      )}

      {/* Accept Sheet */}
      <BottomSheet open={action === "accept"} onClose={() => { setAction(null); setSelected(null); }} title={t("set_schedule")} height="70vh">
        {selected && (
          <div className="space-y-4">
            <div className="rounded-xl p-3" style={{ background: "#1a1a1a" }}>
              <p className="text-xs text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Member</p>
              <p className="text-lg font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
                {isAr ? selected.memberNameAr : selected.memberName}
              </p>
              <p className="text-xs text-white/40 mt-0.5">{selected.requestedPlan}</p>
            </div>
            <div>
              <p className="text-xs text-white/40 uppercase tracking-widest mb-2" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("days")} / الأيام
              </p>
              <div className="flex gap-2 flex-wrap">
                {DAYS.map(d => (
                  <button
                    key={d}
                    onClick={() => toggleDay(d)}
                    className="px-3 py-2 rounded-xl text-sm font-black transition-all"
                    style={{
                      background: selectedDays.includes(d) ? "#dc143c" : "#1a1a1a",
                      color: selectedDays.includes(d) ? "#fff" : "rgba(255,255,255,0.4)",
                      fontFamily: "'Barlow Condensed', sans-serif",
                      border: `1px solid ${selectedDays.includes(d) ? "#dc143c" : "rgba(255,255,255,0.07)"}`,
                    }}
                  >
                    {d}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="block text-xs text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("start_time")} / الوقت
              </label>
              <input
                type="time" value={scheduleTime} onChange={e => setScheduleTime(e.target.value)}
                className="w-full px-4 py-3 rounded-xl text-sm text-white outline-none focus:ring-1 focus:ring-[#dc143c]"
                style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)" }}
              />
            </div>
            <div className="grid grid-cols-2 gap-3 pt-2">
              <button onClick={() => { setAction(null); setSelected(null); }} className="py-3.5 rounded-xl font-black text-sm uppercase tracking-widest"
                style={{ background: "#1a1a1a", color: "rgba(255,255,255,0.5)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("cancel")}
              </button>
              <button onClick={handleAccept} className="py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
                style={{ background: "#22c55e", color: "#000", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("accept")}
              </button>
            </div>
          </div>
        )}
      </BottomSheet>

      {/* Reject Sheet */}
      <BottomSheet open={action === "reject"} onClose={() => { setAction(null); setSelected(null); }} title={t("reject")} height="50vh">
        {selected && (
          <div className="space-y-4">
            <p className="text-sm text-white/60" style={{ fontFamily: "'Inter', sans-serif" }}>
              Rejecting request from <span className="text-white font-bold">{isAr ? selected.memberNameAr : selected.memberName}</span>
            </p>
            <div>
              <label className="block text-xs text-white/40 uppercase tracking-widest mb-1.5" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("reject_reason")} / السبب
              </label>
              <textarea
                value={rejectReason} onChange={e => setRejectReason(e.target.value)}
                rows={3} placeholder="Reason for rejection..."
                className="w-full px-4 py-3 rounded-xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c] resize-none"
                style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <button onClick={() => { setAction(null); setSelected(null); }} className="py-3.5 rounded-xl font-black text-sm uppercase tracking-widest"
                style={{ background: "#1a1a1a", color: "rgba(255,255,255,0.5)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("cancel")}
              </button>
              <button onClick={handleReject} className="py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all active:scale-95"
                style={{ background: "rgba(220,20,60,0.8)", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
                {t("reject")}
              </button>
            </div>
          </div>
        )}
      </BottomSheet>
    </div>
  );
}

function RequestCard({ req, isAr, onAccept, onReject }: {
  req: PTRequest; isAr: boolean; onAccept: () => void; onReject: () => void;
}) {
  return (
    <div className="rounded-2xl p-4 space-y-3" style={{ background: "#141414", border: "1px solid rgba(245,158,11,0.2)" }}>
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-xl flex items-center justify-center text-sm font-black text-white"
            style={{ background: "rgba(245,158,11,0.12)", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {req.memberInitials}
          </div>
          <div>
            <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>
              {isAr ? req.memberNameAr : req.memberName}
            </p>
            <p className="text-xs text-white/40" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{req.requestDate}</p>
          </div>
        </div>
        <StatusBadge status={req.status} />
      </div>
      <div className="grid grid-cols-2 gap-2">
        <div className="rounded-xl p-2.5" style={{ background: "#1a1a1a" }}>
          <p className="text-[10px] text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Plan</p>
          <p className="text-xs font-bold text-white" style={{ fontFamily: "'Inter', sans-serif" }}>{req.requestedPlan}</p>
        </div>
        <div className="rounded-xl p-2.5" style={{ background: "#1a1a1a" }}>
          <p className="text-[10px] text-white/40 uppercase mb-1" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Preferred</p>
          <p className="text-xs font-bold text-white" style={{ fontFamily: "'Inter', sans-serif" }}>{req.preferredTimes}</p>
        </div>
      </div>
      <div className="flex gap-2 pt-1">
        <button onClick={onAccept} className="flex-1 py-3 rounded-xl flex items-center justify-center gap-2 font-black text-sm uppercase transition-all active:scale-95"
          style={{ background: "rgba(34,197,94,0.12)", color: "#22c55e", border: "1px solid rgba(34,197,94,0.3)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          <CheckCircle size={15} />
          Accept
        </button>
        <button onClick={onReject} className="flex-1 py-3 rounded-xl flex items-center justify-center gap-2 font-black text-sm uppercase transition-all active:scale-95"
          style={{ background: "rgba(220,20,60,0.08)", color: "#dc143c", border: "1px solid rgba(220,20,60,0.2)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          <XCircle size={15} />
          Reject
        </button>
      </div>
    </div>
  );
}
