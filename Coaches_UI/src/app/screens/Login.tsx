import React, { useState } from "react";
import { useNavigate } from "react-router";
import { Eye, EyeOff } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { useLang } from "../context/LanguageContext";
import logoImg from "../../imports/logo-only.jpeg";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

export default function Login() {
  const { login } = useAuth();
  const { t, lang, toggleLang, dir } = useLang();
  const navigate = useNavigate();
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [showPw, setShowPw]     = useState(false);
  const [error, setError]       = useState("");
  const [loading, setLoading]   = useState(false);
  const [focused, setFocused]   = useState<"email" | "password" | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    await new Promise(r => setTimeout(r, 700));
    const ok = login(email, password);
    setLoading(false);
    if (ok) {
      navigate("/home");
    } else {
      setError(lang === "en"
        ? "Invalid credentials"
        : "بيانات غير صحيحة");
    }
  };

  return (
    <div className="fixed inset-0 flex items-start justify-center" style={{ background: "#050505" }}>
    <div
      dir={dir}
      className="flex flex-col overflow-hidden relative"
      style={{ width: "100%", maxWidth: 430, minHeight: "100dvh", background: "#0a0a0a" }}
    >
      {/* ── Background glow ── */}
      <div
        className="absolute inset-0 pointer-events-none overflow-hidden"
        style={{
          background: "radial-gradient(ellipse 100% 45% at 50% 0%, rgba(220,20,60,0.18) 0%, transparent 70%)",
        }}
      />

      {/* ── Lang toggle — top right, below status bar ── */}
      <div className="absolute top-0 right-0 z-10" style={{ paddingTop: "calc(env(safe-area-inset-top) + 14px)", paddingRight: 20 }}>
        <button
          onClick={toggleLang}
          className="text-[11px] font-black px-3 py-1.5 rounded-full transition-all active:scale-95"
          style={{
            fontFamily: "'JetBrains Mono', monospace",
            background: "rgba(255,255,255,0.06)",
            border: "1px solid rgba(255,255,255,0.1)",
            color: "rgba(255,255,255,0.45)",
          }}
        >
          {lang === "en" ? "عربي" : "EN"}
        </button>
      </div>

      {/* ── Hero section ── */}
      <div className="flex flex-col items-center justify-center flex-1 px-8" style={{ paddingTop: "env(safe-area-inset-top)" }}>
        {/* Logo */}
        <div className="relative mb-6">
          <div
            className="absolute inset-0 rounded-full blur-2xl"
            style={{ background: "rgba(220,20,60,0.35)", transform: "scale(1.6)" }}
          />
          <div
            className="relative w-20 h-20 rounded-2xl flex items-center justify-center overflow-hidden"
            style={{ background: "#141414", border: "1px solid rgba(255,255,255,0.08)" }}
          >
            <ImageWithFallback
              src={logoImg}
              alt="True Fit"
              className="w-full h-full object-contain"
            />
          </div>
        </div>

        {/* Brand name */}
        <h1
          className="text-5xl font-black text-white uppercase tracking-widest text-center leading-none mb-1"
          style={{ fontFamily: "'Barlow Condensed', sans-serif", letterSpacing: "0.15em" }}
        >
          TRUE FIT
        </h1>
        <p
          className="text-xs uppercase tracking-[0.25em] text-center mb-2"
          style={{ color: "#dc143c", fontFamily: "'Barlow Condensed', sans-serif" }}
        >
          {t("coach_portal")}
        </p>
        <p
          className="text-xs text-center"
          style={{ color: "rgba(255,255,255,0.25)", fontFamily: "'Inter', sans-serif" }}
        >
          {t("login_subtitle")}
        </p>
      </div>

      {/* ── Form card ── */}
      <div
        className="shrink-0 px-5 pt-6 pb-0"
        style={{
          paddingBottom: "calc(env(safe-area-inset-bottom) + 32px)",
          background: "linear-gradient(to bottom, transparent, #0e0e0e 20%)",
        }}
      >
        <form onSubmit={handleLogin} className="space-y-3">
          {/* Email */}
          <div>
            <label
              className="block text-[10px] font-black uppercase tracking-[0.15em] mb-1.5"
              style={{ color: "rgba(255,255,255,0.35)", fontFamily: "'Barlow Condensed', sans-serif" }}
            >
              {t("email")}
            </label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              onFocus={() => setFocused("email")}
              onBlur={() => setFocused(null)}
              placeholder={lang === "en" ? "your@email.com" : "بريدك@example.com"}
              autoCapitalize="none"
              autoCorrect="off"
              className="w-full px-4 text-white placeholder-white/20 text-base outline-none transition-all"
              style={{
                height: 54,
                background: "#181818",
                border: `1.5px solid ${focused === "email" ? "#dc143c" : "rgba(255,255,255,0.07)"}`,
                borderRadius: 14,
                fontFamily: "'Inter', sans-serif",
                fontSize: 15,
              }}
              required
            />
          </div>

          {/* Password */}
          <div>
            <label
              className="block text-[10px] font-black uppercase tracking-[0.15em] mb-1.5"
              style={{ color: "rgba(255,255,255,0.35)", fontFamily: "'Barlow Condensed', sans-serif" }}
            >
              {t("password")}
            </label>
            <div className="relative">
              <input
                type={showPw ? "text" : "password"}
                value={password}
                onChange={e => setPassword(e.target.value)}
                onFocus={() => setFocused("password")}
                onBlur={() => setFocused(null)}
                placeholder="••••••••"
                className="w-full px-4 text-white placeholder-white/20 text-base outline-none transition-all"
                style={{
                  height: 54,
                  paddingRight: 52,
                  background: "#181818",
                  border: `1.5px solid ${focused === "password" ? "#dc143c" : "rgba(255,255,255,0.07)"}`,
                  borderRadius: 14,
                  fontFamily: "'Inter', sans-serif",
                  fontSize: 15,
                }}
                required
              />
              <button
                type="button"
                onClick={() => setShowPw(v => !v)}
                className="absolute right-0 top-0 bottom-0 flex items-center justify-center transition-colors active:scale-95"
                style={{ width: 52, color: "rgba(255,255,255,0.3)" }}
              >
                {showPw ? <EyeOff size={19} /> : <Eye size={19} />}
              </button>
            </div>
          </div>

          {/* Error */}
          {error && (
            <div
              className="flex items-center gap-2 px-4 py-3 rounded-xl text-sm"
              style={{
                background: "rgba(220,20,60,0.1)",
                border: "1px solid rgba(220,20,60,0.25)",
                color: "#ff6b6b",
                fontFamily: "'Inter', sans-serif",
              }}
            >
              <span className="w-1.5 h-1.5 rounded-full shrink-0" style={{ background: "#dc143c" }} />
              {error}
            </div>
          )}

          {/* CTA */}
          <button
            type="submit"
            disabled={loading}
            className="w-full text-white font-black text-xl uppercase tracking-widest transition-all active:scale-[0.97] disabled:opacity-60"
            style={{
              height: 58,
              borderRadius: 16,
              background: loading
                ? "rgba(220,20,60,0.6)"
                : "linear-gradient(135deg, #dc143c 0%, #a50e2b 100%)",
              fontFamily: "'Barlow Condensed', sans-serif",
              letterSpacing: "0.12em",
              marginTop: 8,
              boxShadow: loading ? "none" : "0 8px 32px rgba(220,20,60,0.35)",
            }}
          >
            {loading ? (
              <span className="flex items-center justify-center gap-2.5">
                <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin inline-block" />
                {lang === "en" ? "Signing in…" : "جاري الدخول…"}
              </span>
            ) : t("sign_in")}
          </button>
        </form>

        {/* Demo hint */}
        <div className="mt-5 flex flex-col items-center gap-0.5">
          <p
            className="text-[10px]"
            style={{ color: "rgba(255,255,255,0.15)", fontFamily: "'JetBrains Mono', monospace" }}
          >
            coach@truefit.com · head@truefit.com
          </p>
          <p className="text-[10px]" style={{ color: "rgba(255,255,255,0.08)", fontFamily: "'JetBrains Mono', monospace" }}>
            any password
          </p>
        </div>
      </div>
    </div>
    </div>
  );
}
