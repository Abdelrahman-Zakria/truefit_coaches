import React, { createContext, useContext, useState } from "react";

export type CoachRole = "coach" | "head_coach";

export interface Coach {
  id: string;
  name: string;
  nameAr: string;
  email: string;
  role: CoachRole;
  avatar: string;
  specialty: string;
  joinDate: string;
  baseSalary: number;
}

const MOCK_COACHES: Coach[] = [
  {
    id: "c1",
    name: "Ahmed Hassan",
    nameAr: "أحمد حسن",
    email: "coach@truefit.com",
    role: "coach",
    avatar: "AH",
    specialty: "Strength & Conditioning",
    joinDate: "2023-03-15",
    baseSalary: 8500,
  },
  {
    id: "c2",
    name: "Sarah Al-Rashid",
    nameAr: "سارة الراشد",
    email: "head@truefit.com",
    role: "head_coach",
    avatar: "SR",
    specialty: "Performance & Management",
    joinDate: "2021-09-01",
    baseSalary: 14000,
  },
  {
    id: "c3",
    name: "Khalid Mahmoud",
    nameAr: "خالد محمود",
    email: "khalid@truefit.com",
    role: "coach",
    avatar: "KM",
    specialty: "HIIT & Cardio",
    joinDate: "2022-06-10",
    baseSalary: 7800,
  },
  {
    id: "c4",
    name: "Lina Farhat",
    nameAr: "لينا فرحات",
    email: "lina@truefit.com",
    role: "coach",
    avatar: "LF",
    specialty: "Yoga & Flexibility",
    joinDate: "2023-01-20",
    baseSalary: 7200,
  },
];

interface AuthContextType {
  currentCoach: Coach | null;
  login: (email: string, password: string) => boolean;
  logout: () => void;
  allCoaches: Coach[];
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [currentCoach, setCurrentCoach] = useState<Coach | null>(null);

  const login = (email: string, _password: string): boolean => {
    const found = MOCK_COACHES.find(c => c.email === email);
    if (found) {
      setCurrentCoach(found);
      return true;
    }
    return false;
  };

  const logout = () => setCurrentCoach(null);

  return (
    <AuthContext.Provider value={{ currentCoach, login, logout, allCoaches: MOCK_COACHES }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
