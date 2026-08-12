import React, { useEffect } from "react";
import { Outlet, useNavigate, useLocation, Link } from "react-router";
import { Home, Calendar, Users, Inbox, MessageCircle, Bell, LayoutGrid } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { useLang } from "../context/LanguageContext";
import { useData } from "../context/DataContext";
import logoImg from "../../imports/logo-only.jpeg";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

function NavItem({
  to, icon: Icon, label, active,
}: {
  to: string; icon: React.ElementType; label: string; active: boolean;
}) {
  return (
    <Link
      to={to}
      className="flex flex-col items-center justify-center gap-0.5 flex-1 py-2 transition-all active:scale-90"
      style={{ color: active ? "#dc143c" : "rgba(255,255,255,0.28)", minHeight: 52 }}
    >
      <div className="relative flex items-center justify-center w-10 h-7">
        {active && (
          <span
            className="absolute inset-0 rounded-xl"
            style={{ background: "rgba(220,20,60,0.12)" }}
          />
        )}
        <Icon size={20} strokeWidth={active ? 2.5 : 1.8} />
      </div>
      <span
        className="text-[9px] font-black uppercase"
        style={{
          fontFamily: "'Barlow Condensed', sans-serif",
          letterSpacing: "0.07em",
          color: active ? "#dc143c" : "rgba(255,255,255,0.28)",
        }}
      >
        {label}
      </span>
    </Link>
  );
}

export default function Root() {
  const { currentCoach, logout } = useAuth();
  const { t, lang, toggleLang, dir } = useLang();
  const { unreadCount, shiftStatus } = useData();
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    if (!currentCoach) navigate("/login", { replace: true });
  }, [currentCoach, navigate]);

  if (!currentCoach) return null;

  const isHeadCoach = currentCoach.role === "head_coach";
  const path = location.pathname;

  const statusColors: Record<string, string> = {
    on_shift: "#22c55e",
    off: "#555",
    break: "#f59e0b",
    training: "#3b82f6",
  };
  const statusLabels: Record<string, string> = {
    on_shift: t("on_shift"), off: t("off_shift"), break: t("on_break"), training: t("personal_training"),
  };

  return (
    // Outer shell: centers the "phone" in a browser, fills screen on actual mobile
    <div className="flex items-start justify-center" style={{ background: "#050505", height: "100dvh" }}>
      <div
        dir={dir}
        className="flex flex-col"
        style={{
          width: "100%",
          maxWidth: 430,
          height: "100dvh",
          background: "#0a0a0a",
        }}
      >
        {/* ── App Bar ── */}
        <div
          className="shrink-0 flex items-center justify-between px-4"
          style={{
            paddingTop: "calc(env(safe-area-inset-top) + 10px)",
            paddingBottom: 12,
            background: "#0a0a0a",
            borderBottom: "1px solid rgba(255,255,255,0.05)",
          }}
        >
          {/* Left: logo + status */}
          <div className="flex items-center gap-2.5">
            <div
              className="w-8 h-8 rounded-xl overflow-hidden shrink-0 flex items-center justify-center"
              style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.07)" }}
            >
              <ImageWithFallback src={logoImg} alt="True Fit" className="w-full h-full object-contain" />
            </div>
            <div>
              <div
                className="text-sm font-black text-white uppercase"
                style={{ fontFamily: "'Barlow Condensed', sans-serif", letterSpacing: "0.08em", lineHeight: 1.1 }}
              >
                True Fit
              </div>
              <div className="flex items-center gap-1.5 mt-0.5">
                <span
                  className="w-1.5 h-1.5 rounded-full shrink-0"
                  style={{ background: statusColors[shiftStatus] }}
                />
                <span
                  className="text-[10px] font-semibold"
                  style={{ color: statusColors[shiftStatus], fontFamily: "'Barlow Condensed', sans-serif" }}
                >
                  {statusLabels[shiftStatus]}
                </span>
              </div>
            </div>
          </div>

          {/* Right: lang + bell + avatar */}
          <div className="flex items-center gap-2">
            <button
              onClick={toggleLang}
              className="text-[10px] font-black px-2.5 py-1.5 rounded-lg transition-all active:scale-90"
              style={{
                fontFamily: "'JetBrains Mono', monospace",
                background: "rgba(255,255,255,0.05)",
                border: "1px solid rgba(255,255,255,0.08)",
                color: "rgba(255,255,255,0.35)",
              }}
            >
              {lang === "en" ? "عر" : "EN"}
            </button>

            <button
              onClick={() => navigate("/notifications")}
              className="relative w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90"
              style={{ background: "rgba(255,255,255,0.04)" }}
            >
              <Bell size={19} color="rgba(255,255,255,0.6)" />
              {unreadCount > 0 && (
                <span
                  className="absolute top-0.5 right-0.5 w-4 h-4 rounded-full text-[9px] font-black flex items-center justify-center text-white"
                  style={{ background: "#dc143c" }}
                >
                  {unreadCount}
                </span>
              )}
            </button>

            <button
              onClick={() => { logout(); navigate("/login"); }}
              className="w-9 h-9 rounded-full flex items-center justify-center font-black text-white transition-all active:scale-90"
              style={{
                background: "rgba(220,20,60,0.12)",
                border: "1px solid rgba(220,20,60,0.25)",
                fontFamily: "'Barlow Condensed', sans-serif",
                fontSize: 13,
              }}
            >
              {currentCoach.avatar}
            </button>
          </div>
        </div>

        {/* ── Scrollable content — overflow-hidden so each screen owns its scroll ── */}
        <div className="flex-1 overflow-hidden flex flex-col min-h-0">
          <Outlet />
        </div>

        {/* ── Bottom Nav — hidden inside chat conversations ── */}
        <div
          className="shrink-0 flex items-stretch px-1"
          style={{
            display: path.startsWith("/chat/") ? "none" : "flex",
            paddingBottom: "env(safe-area-inset-bottom)",
            background: "#0d0d0d",
            borderTop: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <NavItem to="/home"     icon={Home}         label={t("nav_home")}       active={path === "/home" || path === "/"} />
          <NavItem to="/schedule" icon={Calendar}     label={t("nav_schedule")}   active={path === "/schedule"} />
          <NavItem to="/members"  icon={Users}         label={t("nav_members")}    active={path.startsWith("/members")} />
          <NavItem to="/requests" icon={Inbox}         label={t("nav_requests")}   active={path === "/requests"} />
          <NavItem to="/chat"     icon={MessageCircle} label={t("nav_chat")}       active={path.startsWith("/chat")} />
          {isHeadCoach && (
            <NavItem to="/management" icon={LayoutGrid} label={t("nav_management")} active={path === "/management"} />
          )}
        </div>
      </div>
    </div>
  );
}
