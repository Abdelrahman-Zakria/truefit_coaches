import { RouterProvider } from "react-router";
import { router } from "./routes";
import { AuthProvider } from "./context/AuthContext";
import { LanguageProvider } from "./context/LanguageContext";
import { DataProvider } from "./context/DataContext";
import { Toaster } from "sonner";

export default function App() {
  return (
    <LanguageProvider>
      <AuthProvider>
        <DataProvider>
          <div style={{ background: "#0a0a0a", minHeight: "100dvh" }}>
            <RouterProvider router={router} />
          </div>
          <Toaster
            position="top-center"
            toastOptions={{
              style: { background: "#1a1a1a", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", fontFamily: "'Barlow Condensed', sans-serif", fontSize: 15, fontWeight: 700 },
            }}
          />
        </DataProvider>
      </AuthProvider>
    </LanguageProvider>
  );
}
