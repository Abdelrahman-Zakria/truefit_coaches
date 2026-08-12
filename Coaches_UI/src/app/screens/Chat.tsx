import React, { useState, useRef, useEffect } from "react";
import { useParams, useNavigate } from "react-router";
import { Send, ChevronLeft } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { useAuth } from "../context/AuthContext";

function formatTime(ts: string) {
  const d = new Date(ts);
  return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function formatDate(ts: string) {
  return new Date(ts).toLocaleDateString("en-AE", { month: "short", day: "numeric" });
}

export default function Chat() {
  const { memberId } = useParams();
  const navigate = useNavigate();
  const { t, isAr } = useLang();
  const { members, messages, sendMessage } = useData();
  const { currentCoach } = useAuth();
  const [text, setText] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  const member = memberId ? members.find(m => m.id === memberId) : null;
  const memberMessages = memberId ? (messages[memberId] || []) : [];

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [memberMessages]);

  const handleSend = () => {
    if (!text.trim() || !memberId) return;
    sendMessage(memberId, text.trim());
    setText("");
  };

  // Conversation list
  if (!memberId) {
    return (
      <div className="pb-4">
        <div className="px-4 pt-4 mb-4">
          <h1 className="text-2xl font-black text-white uppercase tracking-wide" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
            {t("conversations")}
          </h1>
        </div>
        <div className="space-y-px">
          {members.map(m => {
            const memberMsgs = messages[m.id] || [];
            const last = memberMsgs[memberMsgs.length - 1];
            const name = isAr ? m.nameAr : m.name;
            return (
              <button
                key={m.id}
                onClick={() => navigate(`/chat/${m.id}`)}
                className="w-full flex items-center gap-4 px-4 py-4 text-left transition-all hover:bg-white/5"
                style={{ borderBottom: "1px solid rgba(255,255,255,0.04)" }}
              >
                <div className="w-12 h-12 rounded-2xl flex items-center justify-center text-sm font-black text-white shrink-0"
                  style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif" }}>
                  {m.initials}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{name}</p>
                    {last && <span className="text-[10px] text-white/25" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{formatDate(last.timestamp)}</span>}
                  </div>
                  {last && (
                    <p className="text-xs text-white/35 truncate mt-0.5" style={{ fontFamily: "'Inter', sans-serif" }}>
                      {last.isCoach ? "You: " : ""}{last.text}
                    </p>
                  )}
                </div>
              </button>
            );
          })}
        </div>
      </div>
    );
  }

  // Chat detail
  if (!member) return null;
  const name = isAr ? member.nameAr : member.name;

  return (
    <div className="flex flex-col h-full">
      {/* Chat header */}
      <div className="shrink-0 flex items-center gap-3 px-4 py-3" style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
        <button onClick={() => navigate("/chat")} className="p-2 -ml-2 rounded-full hover:bg-white/5 transition-colors">
          <ChevronLeft size={20} color="rgba(255,255,255,0.6)" />
        </button>
        <div className="w-9 h-9 rounded-xl flex items-center justify-center text-sm font-black text-white"
          style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif" }}>
          {member.initials}
        </div>
        <div>
          <p className="font-black text-white" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>{name}</p>
          <p className="text-[10px] text-white/30">{member.plan}</p>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {memberMessages.map(msg => (
          <div key={msg.id} className={`flex ${msg.isCoach ? "justify-end" : "justify-start"}`}>
            <div
              className="max-w-[78%] px-4 py-2.5 rounded-2xl"
              style={{
                background: msg.isCoach ? "#dc143c" : "#1a1a1a",
                borderRadius: msg.isCoach ? "20px 20px 4px 20px" : "20px 20px 20px 4px",
              }}
            >
              <p className="text-sm text-white" style={{ fontFamily: "'Inter', sans-serif" }}>{msg.text}</p>
              <p className="text-[10px] mt-1 text-right" style={{ color: msg.isCoach ? "rgba(255,255,255,0.5)" : "rgba(255,255,255,0.3)", fontFamily: "'JetBrains Mono', monospace" }}>
                {formatTime(msg.timestamp)}
              </p>
            </div>
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="shrink-0 px-4 py-3 flex items-center gap-3" style={{ borderTop: "1px solid rgba(255,255,255,0.05)", background: "#0a0a0a", paddingBottom: "calc(env(safe-area-inset-bottom) + 4px)" }}>
        <input
          value={text}
          onChange={e => setText(e.target.value)}
          onKeyDown={e => e.key === "Enter" && handleSend()}
          placeholder={t("type_message")}
          className="flex-1 px-4 py-3 rounded-2xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c]"
          style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
        />
        <button
          onClick={handleSend}
          disabled={!text.trim()}
          className="w-10 h-10 rounded-xl flex items-center justify-center transition-all active:scale-90 disabled:opacity-30"
          style={{ background: "#dc143c" }}
        >
          <Send size={16} color="#fff" />
        </button>
      </div>
    </div>
  );
}
