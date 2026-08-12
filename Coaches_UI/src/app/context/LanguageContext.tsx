import React, { createContext, useContext, useState } from "react";

export type Lang = "en" | "ar";

const t_en: Record<string, string> = {
  nav_home: "Home", nav_schedule: "Schedule", nav_members: "Members",
  nav_requests: "Requests", nav_chat: "Chat", nav_management: "Management",
  nav_time: "Time", nav_attendance: "Attendance", nav_more: "More",
  good_morning: "Good Morning", good_afternoon: "Good Afternoon",
  good_evening: "Good Evening", on_shift: "On Shift", off_shift: "Off Duty",
  on_break: "On Break", personal_training: "Coach Training",
  today_sessions: "PT Sessions", today_classes: "Classes",
  pending_requests: "Pending Requests", live_time: "Live",
  work_shifts: "Work Shifts", pt_sessions: "PT Sessions",
  all_members: "All Members", member_plan: "Plan", last_session: "Last Session",
  overview: "Overview", workouts: "Workouts", inbody: "InBody",
  diet_plan: "Diet Plan", assessment: "Assessment", sessions: "Sessions",
  add_exercise: "Add Exercise", exercise_name: "Exercise Name",
  muscle_group: "Muscle Group", weight_kg: "Weight (kg)", sets: "Sets",
  reps_per_set: "Reps / Set", save: "Save", cancel: "Cancel",
  delete: "Delete", edit: "Edit", add: "Add", confirm: "Confirm",
  accept: "Accept", reject: "Reject", set_schedule: "Set Schedule",
  reject_reason: "Rejection Reason", requested_plan: "Requested Plan",
  preferred_times: "Preferred Times", type_message: "Type a message...",
  send: "Send", conversations: "Conversations", start_break: "Start Break",
  end_break: "End Break", start_pt: "Start Coach PT", end_pt: "End Coach PT",
  session_history: "Session History", duration: "Duration",
  check_in: "Check In", check_out: "Check Out",
  hold_to_checkin: "Hold to Check In", confirmed: "Checked In",
  notifications: "Notifications", mark_all_read: "Mark All Read",
  management: "Management", shift_planner: "Shift Planner",
  inbody_schedule: "InBody Schedule", class_management: "Classes",
  salary_deductions: "Salary & Deductions", logout: "Log Out",
  sign_in: "Sign In", email: "Email", password: "Password",
  welcome_back: "Welcome Back", coach_portal: "Coach Portal",
  today: "Today", name: "Name", location: "Location", time: "Time",
  days: "Days", start_time: "Start Time", end_time: "End Time",
  classes: "Classes", capacity: "Capacity", instructor: "Instructor",
  base_salary: "Base Salary", amount: "Amount", reason: "Reason", date: "Date",
  deductions: "Deductions", add_deduction: "Add Deduction",
  body_fat: "Body Fat %", muscle_mass: "Muscle Mass (kg)", bmi: "BMI",
  hydration: "Hydration %", weight: "Weight (kg)", scan_date: "Scan Date",
  fitness_level: "Fitness Level", goals: "Goals",
  injuries: "Injuries / Notes", coach_remarks: "Coach Remarks",
  meal_name: "Meal Name", calories: "Calories", protein: "Protein (g)",
  carbs: "Carbs (g)", fat: "Fat (g)", add_meal: "Add Meal",
  subscription: "Subscription", attendance_history: "Attendance History",
  time_in: "Time In", time_out: "Time Out", no_data: "No data yet",
  search: "Search members...", filter: "Filter",
  login_subtitle: "Sign in to your coach account",
  shift_off: "Day Off", assign_shift: "Assign Shift",
  add_slot: "Add Slot", open_class: "Open", closed_class: "Closed",
  total_deductions: "Total Deductions", net_salary: "Net Salary",
  coach: "Coach", head_coach: "Head Coach", reschedule_alert: "Rescheduled",
  new_request: "New Request", session_reminder: "Session in 30 min",
  new_message: "New Message", type: "Type", member: "Member",
  personal_info: "Personal Info", age: "Age", phone: "Phone",
  join_date: "Join Date", plan_expiry: "Plan Expiry",
};

const t_ar: Record<string, string> = {
  nav_home: "الرئيسية", nav_schedule: "الجدول", nav_members: "الأعضاء",
  nav_requests: "الطلبات", nav_chat: "المحادثات", nav_management: "الإدارة",
  nav_time: "الوقت", nav_attendance: "الحضور", nav_more: "المزيد",
  good_morning: "صباح الخير", good_afternoon: "مساء الخير",
  good_evening: "مساء النور", on_shift: "في الوردية", off_shift: "خارج الدوام",
  on_break: "في استراحة", personal_training: "تدريب المدرب",
  today_sessions: "جلسات PT", today_classes: "الكلاسات",
  pending_requests: "طلبات معلقة", live_time: "الآن",
  work_shifts: "الوردية", pt_sessions: "جلسات التدريب",
  all_members: "جميع الأعضاء", member_plan: "الخطة", last_session: "آخر جلسة",
  overview: "نظرة عامة", workouts: "التمارين", inbody: "إن بودي",
  diet_plan: "الحمية", assessment: "التقييم", sessions: "الجلسات",
  add_exercise: "إضافة تمرين", exercise_name: "اسم التمرين",
  muscle_group: "المجموعة العضلية", weight_kg: "الوزن (كجم)", sets: "الجولات",
  reps_per_set: "تكرارات / جولة", save: "حفظ", cancel: "إلغاء",
  delete: "حذف", edit: "تعديل", add: "إضافة", confirm: "تأكيد",
  accept: "قبول", reject: "رفض", set_schedule: "تحديد الجدول",
  reject_reason: "سبب الرفض", requested_plan: "الخطة المطلوبة",
  preferred_times: "الأوقات المفضلة", type_message: "اكتب رسالة...",
  send: "إرسال", conversations: "المحادثات", start_break: "بدء الاستراحة",
  end_break: "إنهاء الاستراحة", start_pt: "بدء تدريب المدرب",
  end_pt: "إنهاء تدريب المدرب", session_history: "سجل الجلسات",
  duration: "المدة", check_in: "تسجيل الحضور", check_out: "تسجيل الانصراف",
  hold_to_checkin: "اضغط للحضور", confirmed: "تم التسجيل",
  notifications: "الإشعارات", mark_all_read: "تعليم الكل",
  management: "الإدارة", shift_planner: "مخطط الوردية",
  inbody_schedule: "جدول إن بودي", class_management: "الكلاسات",
  salary_deductions: "الرواتب والخصومات", logout: "تسجيل الخروج",
  sign_in: "دخول", email: "البريد الإلكتروني", password: "كلمة المرور",
  welcome_back: "أهلاً بعودتك", coach_portal: "بوابة المدرب",
  today: "اليوم", name: "الاسم", location: "الموقع", time: "الوقت",
  days: "الأيام", start_time: "وقت البداية", end_time: "وقت النهاية",
  classes: "الكلاسات", capacity: "السعة", instructor: "المدرب",
  base_salary: "الراتب الأساسي", amount: "المبلغ", reason: "السبب",
  date: "التاريخ", deductions: "الخصومات", add_deduction: "إضافة خصم",
  body_fat: "نسبة الدهون %", muscle_mass: "الكتلة العضلية (كجم)", bmi: "مؤشر الكتلة",
  hydration: "الترطيب %", weight: "الوزن (كجم)", scan_date: "تاريخ الفحص",
  fitness_level: "مستوى اللياقة", goals: "الأهداف",
  injuries: "الإصابات / ملاحظات", coach_remarks: "ملاحظات المدرب",
  meal_name: "اسم الوجبة", calories: "السعرات", protein: "بروتين (جم)",
  carbs: "كربوهيدرات (جم)", fat: "دهون (جم)", add_meal: "إضافة وجبة",
  subscription: "الاشتراك", attendance_history: "سجل الحضور",
  time_in: "وقت الدخول", time_out: "وقت الخروج", no_data: "لا توجد بيانات",
  search: "بحث عن عضو...", filter: "تصفية",
  login_subtitle: "سجّل دخولك كمدرب",
  shift_off: "إجازة", assign_shift: "تعيين وردية",
  add_slot: "إضافة موعد", open_class: "مفتوح", closed_class: "مغلق",
  total_deductions: "إجمالي الخصومات", net_salary: "صافي الراتب",
  coach: "مدرب", head_coach: "كبير المدربين", reschedule_alert: "إعادة جدولة",
  new_request: "طلب جديد", session_reminder: "جلسة خلال 30 دقيقة",
  new_message: "رسالة جديدة", type: "النوع", member: "العضو",
  personal_info: "المعلومات الشخصية", age: "العمر", phone: "الهاتف",
  join_date: "تاريخ الانضمام", plan_expiry: "انتهاء الخطة",
};

interface LangContextType {
  lang: Lang;
  toggleLang: () => void;
  t: (key: string) => string;
  dir: "ltr" | "rtl";
  isAr: boolean;
}

const LangContext = createContext<LangContextType | null>(null);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLang] = useState<Lang>("en");
  const toggleLang = () => setLang(prev => (prev === "en" ? "ar" : "en"));
  const t = (key: string): string => {
    const tbl = lang === "en" ? t_en : t_ar;
    return tbl[key] ?? key;
  };
  return (
    <LangContext.Provider value={{ lang, toggleLang, t, dir: lang === "ar" ? "rtl" : "ltr", isAr: lang === "ar" }}>
      {children}
    </LangContext.Provider>
  );
}

export function useLang() {
  const ctx = useContext(LangContext);
  if (!ctx) throw new Error("useLang must be used within LanguageProvider");
  return ctx;
}
