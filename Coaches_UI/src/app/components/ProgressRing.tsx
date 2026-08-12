interface ProgressRingProps {
  progress: number;
  size?: number;
  strokeWidth?: number;
  color?: string;
  trackColor?: string;
  label?: string;
}

export function ProgressRing({
  progress,
  size = 48,
  strokeWidth = 4,
  color = "#dc143c",
  trackColor = "rgba(255,255,255,0.08)",
  label,
}: ProgressRingProps) {
  const r = (size - strokeWidth) / 2;
  const circ = 2 * Math.PI * r;
  const offset = circ - (progress / 100) * circ;

  return (
    <div className="relative inline-flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={trackColor} strokeWidth={strokeWidth} />
        <circle
          cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color}
          strokeWidth={strokeWidth} strokeDasharray={circ} strokeDashoffset={offset}
          strokeLinecap="round" style={{ transition: "stroke-dashoffset 0.4s ease" }}
        />
      </svg>
      {label !== undefined && (
        <span className="absolute text-[10px] font-bold text-white" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
          {label}
        </span>
      )}
    </div>
  );
}
