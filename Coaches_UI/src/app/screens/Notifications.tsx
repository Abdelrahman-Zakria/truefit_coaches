import React from "react";
import { useNavigate } from "react-router";
import { Bell, RefreshCw, Inbox, AlertCircle, Clock, MessageCircle, ChevronLeft } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import type { Notification } from "../context/DataContext";

const iconMap: Record<Notification["type"], React.ElementType> = {
  reschedule: RefreshCw, request: Inbox, reminder: Clock, message: MessageCircle,
};
const colorMap: Record<Notification["type"], string> = {
  reschedule: "#f59e0b", request: "#3b82f6", reminder: "#dc143c", message: "#22c55e",
};

function timeSince(ts: string) {
  const d = new Date(ts);
  const diff = (Date.now() - d.getTime()) / 1000;
  if (diff < 3600) return `${Math.round(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.round(diff / 3600)}h ago`;
  return `${Math.round(diff / 86400)}d ago`;
}

export default function Notifications() {
  const { t, isAr } = useLang();
  const navigate = useNavigate();
  const { notifications, markAllRead } = useData();

  const unread = notifications.filter(n => !n.read).length;

  return (
    <div className="pb-4 overflow-y-auto h-full">
      <div className="flex items-center justify-between px-4 pt-4 mb-4">
        <div className="flex items-center gap-2">
          <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-white/5 transition-colors">
            <ChevronLeft size={20} color="rgba(255,255,255,0.6)" />
          </button>
          <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("notifications")}
          </h1>
          {unread > 0 && (
            <span className="w-5 h-5 rounded-full text-[10px] font-black flex items-center justify-center" style={{ background: "#dc143c", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif" }}>
              {unread}
            </span>
          )}
        </div>
        {unread > 0 && (
          <button onClick={markAllRead} className="text-xs font-bold uppercase tracking-wide" style={{ color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("mark_all_read")}
          </button>
        )}
      </div>

      {notifications.length === 0
        ? (
          <div className="flex flex-col items-center justify-center py-20 gap-3">
            <Bell size={40} color="rgba(255,255,255,0.1)" />
            <p className="text-sm text-white/20" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{t("no_data")}</p>
          </div>
        )
        : (
          <div className="space-y-px">
            {notifications.map(n => {
              const Icon = iconMap[n.type];
              const color = colorMap[n.type];
              const title = isAr ? n.titleAr : n.title;
              const body = isAr ? n.bodyAr : n.body;
              return (
                <div
                  key={n.id}
                  className="flex items-start gap-4 px-4 py-4 transition-all"
                  style={{
                    background: n.read ? "transparent" : "rgba(220,20,60,0.03)",
                    borderBottom: "1px solid rgba(255,255,255,0.04)",
                    borderLeft: n.read ? "3px solid transparent" : `3px solid ${color}`,
                  }}
                >
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center shrink-0 mt-0.5" style={{ background: `${color}15` }}>
                    <Icon size={16} color={color} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                      <p className="font-black text-white text-sm" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{title}</p>
                      <span className="text-[10px] text-white/25 shrink-0 mt-0.5" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
                        {timeSince(n.timestamp)}
                      </span>
                    </div>
                    <p className="text-xs text-white/40 mt-0.5" style={{ fontFamily: "'Inter', sans-serif" }}>{body}</p>
                  </div>
                  {!n.read && <span className="w-2 h-2 rounded-full shrink-0 mt-2" style={{ background: "#dc143c" }} />}
                </div>
              );
            })}
          </div>
        )
      }
    </div>
  );
}
