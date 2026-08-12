import React, { useState } from "react";
import { useNavigate } from "react-router";
import { Search } from "lucide-react";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import { ProgressRing } from "../components/ProgressRing";
import type { Member } from "../context/DataContext";

function MemberCard({ member, onClick }: { member: Member; onClick: () => void }) {
  const { isAr } = useLang();
  const name = isAr ? member.nameAr : member.name;
  const daysSince = Math.floor((Date.now() - new Date(member.lastSession).getTime()) / 86400000);
  const sessionLabel = daysSince === 0 ? "Today" : daysSince === 1 ? "Yesterday" : `${daysSince}d ago`;

  return (
    <button onClick={onClick} className="w-full rounded-2xl p-4 flex items-center gap-4 transition-all active:scale-[0.98] text-left"
      style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.06)" }}>
      <div className="w-12 h-12 rounded-xl flex items-center justify-center text-sm font-black text-white shrink-0"
        style={{ background: "rgba(220,20,60,0.15)", fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15 }}>
        {member.initials}
      </div>
      <div className="flex-1 min-w-0">
        <p className="font-bold text-white truncate" style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: 16 }}>{name}</p>
        <div className="flex items-center gap-2 mt-0.5">
          <span className="text-[10px] font-bold px-2 py-0.5 rounded" style={{ background: "rgba(220,20,60,0.12)", color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}>
            {member.plan}
          </span>
          <span className="text-xs text-white/30" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{sessionLabel}</span>
        </div>
      </div>
      <ProgressRing progress={member.progress} size={44} strokeWidth={3} label={`${member.progress}%`} />
    </button>
  );
}

export default function Members() {
  const { t } = useLang();
  const { members } = useData();
  const navigate = useNavigate();
  const [search, setSearch] = useState("");
  const [planFilter, setPlanFilter] = useState<string>("all");

  const plans = ["all", ...Array.from(new Set(members.map(m => m.plan)))];
  const filtered = members.filter(m => {
    const matchSearch = m.name.toLowerCase().includes(search.toLowerCase()) || m.nameAr.includes(search);
    const matchPlan = planFilter === "all" || m.plan === planFilter;
    return matchSearch && matchPlan;
  });

  return (
    <div className="pb-4 px-4 overflow-y-auto h-full">
      <div className="pt-4 pb-3">
        <h1 className="text-2xl font-black text-white uppercase tracking-wide mb-4" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>
          {t("all_members")}
        </h1>

        {/* Search */}
        <div className="relative mb-3">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-white/25" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder={t("search")}
            className="w-full pl-10 pr-4 py-3 rounded-xl text-sm text-white placeholder-white/20 outline-none focus:ring-1 focus:ring-[#dc143c]"
            style={{ background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.07)", fontFamily: "'Inter', sans-serif" }}
          />
        </div>

        {/* Plan filter */}
        <div className="flex gap-2 overflow-x-auto pb-1">
          {plans.map(p => (
            <button
              key={p}
              onClick={() => setPlanFilter(p)}
              className="px-3 py-1.5 rounded-xl text-xs font-black uppercase tracking-wide whitespace-nowrap transition-all shrink-0"
              style={{
                background: planFilter === p ? "#dc143c" : "#1a1a1a",
                color: planFilter === p ? "#fff" : "rgba(255,255,255,0.4)",
                border: `1px solid ${planFilter === p ? "#dc143c" : "rgba(255,255,255,0.06)"}`,
                fontFamily: "'Barlow Condensed', sans-serif",
              }}
            >
              {p === "all" ? "All Plans" : p}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-2">
        {filtered.length === 0
          ? <div className="text-center py-12 text-white/20 text-sm" style={{ fontFamily: "'JetBrains Mono', monospace" }}>{t("no_data")}</div>
          : filtered.map(m => (
            <MemberCard key={m.id} member={m} onClick={() => navigate(`/members/${m.id}`)} />
          ))
        }
      </div>
    </div>
  );
}
