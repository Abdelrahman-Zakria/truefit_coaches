import React, { useEffect } from "react";
import { X } from "lucide-react";

interface BottomSheetProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  height?: string;
}

export function BottomSheet({ open, onClose, title, children, height = "85vh" }: BottomSheetProps) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-end">
      <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={onClose} />
      <div
        className="relative rounded-t-3xl flex flex-col overflow-hidden animate-in slide-in-from-bottom duration-300"
        style={{ height, background: "#141414", borderTop: "1px solid rgba(255,255,255,0.08)" }}
      >
        <div className="flex items-center justify-between px-5 py-4 border-b border-white/5 shrink-0">
          <div className="w-10 h-1 bg-white/20 rounded-full mx-auto absolute left-1/2 -translate-x-1/2 top-3" />
          {title && (
            <h3 className="font-bold text-white text-lg" style={{ fontFamily: "'Barlow Condensed', sans-serif", letterSpacing: "0.03em" }}>
              {title}
            </h3>
          )}
          <button onClick={onClose} className="ml-auto p-2 rounded-full hover:bg-white/10 transition-colors text-white/60 hover:text-white">
            <X size={18} />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto px-5 py-4">
          {children}
        </div>
      </div>
    </div>
  );
}
