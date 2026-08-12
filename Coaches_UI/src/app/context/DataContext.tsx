import React, { createContext, useContext, useState } from "react";

export interface Exercise {
  id: string;
  name: string;
  muscleGroup: string;
  weight: number;
  sets: number;
  repsPerSet: number;
}

export interface InBodyScan {
  id: string;
  date: string;
  weight: number;
  bodyFat: number;
  muscleMass: number;
  bmi: number;
  hydration: number;
}

export interface Meal {
  id: string;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface Assessment {
  id: string;
  date: string;
  fitnessLevel: string;
  goals: string;
  injuries: string;
  coachRemarks: string;
}

export interface PastSession {
  id: string;
  date: string;
  type: string;
  duration: number;
  notes: string;
}

export interface Member {
  id: string;
  name: string;
  nameAr: string;
  initials: string;
  age: number;
  phone: string;
  email: string;
  plan: string;
  joinDate: string;
  planExpiry: string;
  lastSession: string;
  progress: number;
  exercises: Exercise[];
  inBodyScans: InBodyScan[];
  meals: Meal[];
  assessments: Assessment[];
  pastSessions: PastSession[];
}

export interface PTSession {
  id: string;
  memberId: string;
  memberName: string;
  date: string;
  time: string;
  duration: number;
  location: string;
  type: "PT" | "Class";
  status: "upcoming" | "completed" | "cancelled";
  startingSoon?: boolean;
}

export interface WorkShift {
  id: string;
  coachId: string;
  date: string;
  startTime: string;
  endTime: string;
  status: "scheduled" | "completed" | "off";
}

export interface GymClass {
  id: string;
  name: string;
  instructor: string;
  instructorId: string;
  date: string;
  time: string;
  duration: number;
  location: string;
  capacity: number;
  enrolled: number;
  isOpen: boolean;
}

export interface PTRequest {
  id: string;
  memberName: string;
  memberNameAr: string;
  memberInitials: string;
  requestedPlan: string;
  preferredTimes: string;
  status: "pending" | "accepted" | "rejected";
  reason?: string;
  scheduledDays?: string;
  scheduledTime?: string;
  requestDate: string;
}

export interface ChatMessage {
  id: string;
  senderId: string;
  text: string;
  timestamp: string;
  isCoach: boolean;
}

export interface Notification {
  id: string;
  type: "reschedule" | "request" | "reminder" | "message";
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  timestamp: string;
  read: boolean;
}

export interface TimeEntry {
  id: string;
  type: "break" | "personal_training";
  startTime: string;
  endTime?: string;
  duration?: number;
}

export interface AttendanceEntry {
  id: string;
  date: string;
  timeIn: string;
  timeOut?: string;
  duration?: number;
  location: string;
}

export interface CoachShift {
  coachId: string;
  day: string;
  startTime: string;
  endTime: string;
  isOff: boolean;
}

export interface InBodySlot {
  id: string;
  date: string;
  time: string;
  supervisorId: string;
  supervisorName: string;
  memberName?: string;
}

export interface Deduction {
  id: string;
  coachId: string;
  amount: number;
  reason: string;
  date: string;
}

const INITIAL_MEMBERS: Member[] = [
  {
    id: "m1", name: "Omar Al-Farsi", nameAr: "عمر الفارسي", initials: "OA",
    age: 28, phone: "+971 50 123 4567", email: "omar@email.com",
    plan: "Premium PT", joinDate: "2024-01-15", planExpiry: "2025-01-15",
    lastSession: "2025-07-13", progress: 72,
    exercises: [
      { id: "e1", name: "Bench Press", muscleGroup: "Chest", weight: 80, sets: 4, repsPerSet: 10 },
      { id: "e2", name: "Squat", muscleGroup: "Legs", weight: 100, sets: 4, repsPerSet: 8 },
      { id: "e3", name: "Pull-up", muscleGroup: "Back", weight: 0, sets: 3, repsPerSet: 12 },
    ],
    inBodyScans: [
      { id: "ib1", date: "2025-06-15", weight: 82.4, bodyFat: 18.2, muscleMass: 38.1, bmi: 24.6, hydration: 61.2 },
      { id: "ib2", date: "2025-07-10", weight: 80.8, bodyFat: 16.9, muscleMass: 39.4, bmi: 24.1, hydration: 62.8 },
    ],
    meals: [
      { id: "ml1", name: "Breakfast", calories: 520, protein: 35, carbs: 60, fat: 12 },
      { id: "ml2", name: "Pre-Workout", calories: 320, protein: 28, carbs: 40, fat: 5 },
      { id: "ml3", name: "Dinner", calories: 680, protein: 48, carbs: 65, fat: 20 },
    ],
    assessments: [
      { id: "as1", date: "2025-01-20", fitnessLevel: "Intermediate", goals: "Muscle gain & fat loss", injuries: "Mild right shoulder strain", coachRemarks: "Good form on compound lifts, needs shoulder mobility work." },
    ],
    pastSessions: [
      { id: "ps1", date: "2025-07-13", type: "PT", duration: 60, notes: "Upper body strength focus" },
      { id: "ps2", date: "2025-07-10", type: "PT", duration: 60, notes: "Lower body and core" },
      { id: "ps3", date: "2025-07-07", type: "PT", duration: 45, notes: "Active recovery" },
    ],
  },
  {
    id: "m2", name: "Layla Mohammed", nameAr: "ليلى محمد", initials: "LM",
    age: 25, phone: "+971 55 987 6543", email: "layla@email.com",
    plan: "Elite PT", joinDate: "2023-09-01", planExpiry: "2025-09-01",
    lastSession: "2025-07-14", progress: 88,
    exercises: [
      { id: "e4", name: "Deadlift", muscleGroup: "Back / Legs", weight: 60, sets: 3, repsPerSet: 8 },
      { id: "e5", name: "Hip Thrust", muscleGroup: "Glutes", weight: 80, sets: 4, repsPerSet: 12 },
      { id: "e6", name: "Lat Pulldown", muscleGroup: "Back", weight: 45, sets: 3, repsPerSet: 10 },
    ],
    inBodyScans: [
      { id: "ib3", date: "2025-06-20", weight: 58.5, bodyFat: 22.1, muscleMass: 28.4, bmi: 21.8, hydration: 59.4 },
      { id: "ib4", date: "2025-07-12", weight: 57.9, bodyFat: 21.0, muscleMass: 29.1, bmi: 21.6, hydration: 60.2 },
    ],
    meals: [
      { id: "ml4", name: "Breakfast", calories: 400, protein: 30, carbs: 45, fat: 10 },
      { id: "ml5", name: "Lunch", calories: 550, protein: 40, carbs: 55, fat: 14 },
      { id: "ml6", name: "Post-Workout Shake", calories: 280, protein: 30, carbs: 30, fat: 4 },
    ],
    assessments: [
      { id: "as2", date: "2023-09-05", fitnessLevel: "Beginner", goals: "Toning and endurance", injuries: "None", coachRemarks: "Very dedicated, fast learner." },
      { id: "as3", date: "2025-03-01", fitnessLevel: "Intermediate-Advanced", goals: "Compete in fitness show", injuries: "None", coachRemarks: "Excellent progress. Ready for competition prep phase." },
    ],
    pastSessions: [
      { id: "ps4", date: "2025-07-14", type: "PT", duration: 60, notes: "Glute & posterior chain" },
      { id: "ps5", date: "2025-07-12", type: "PT", duration: 60, notes: "Full body strength" },
    ],
  },
  {
    id: "m3", name: "Khaled Ibrahim", nameAr: "خالد إبراهيم", initials: "KI",
    age: 35, phone: "+971 54 321 9876", email: "khaled@email.com",
    plan: "Basic PT", joinDate: "2024-11-01", planExpiry: "2025-11-01",
    lastSession: "2025-07-07", progress: 45,
    exercises: [
      { id: "e7", name: "Treadmill Run", muscleGroup: "Cardio", weight: 0, sets: 1, repsPerSet: 30 },
      { id: "e8", name: "Leg Press", muscleGroup: "Legs", weight: 120, sets: 3, repsPerSet: 12 },
    ],
    inBodyScans: [
      { id: "ib5", date: "2025-07-01", weight: 94.2, bodyFat: 28.5, muscleMass: 36.8, bmi: 29.1, hydration: 57.3 },
    ],
    meals: [
      { id: "ml7", name: "Breakfast", calories: 450, protein: 25, carbs: 55, fat: 15 },
      { id: "ml8", name: "Dinner", calories: 600, protein: 38, carbs: 60, fat: 18 },
    ],
    assessments: [
      { id: "as4", date: "2024-11-05", fitnessLevel: "Beginner", goals: "Weight loss", injuries: "Lower back pain history", coachRemarks: "Avoid heavy spinal loading. Focus on core stability first." },
    ],
    pastSessions: [
      { id: "ps6", date: "2025-07-07", type: "PT", duration: 45, notes: "Cardio & light resistance" },
      { id: "ps7", date: "2025-06-30", type: "PT", duration: 45, notes: "Core stability work" },
    ],
  },
  {
    id: "m4", name: "Nour Khalid", nameAr: "نور خالد", initials: "NK",
    age: 22, phone: "+971 56 444 5555", email: "nour@email.com",
    plan: "Premium PT", joinDate: "2024-05-20", planExpiry: "2025-05-20",
    lastSession: "2025-07-11", progress: 63,
    exercises: [
      { id: "e9", name: "Overhead Press", muscleGroup: "Shoulders", weight: 30, sets: 4, repsPerSet: 10 },
      { id: "e10", name: "Romanian Deadlift", muscleGroup: "Hamstrings", weight: 50, sets: 3, repsPerSet: 10 },
    ],
    inBodyScans: [
      { id: "ib6", date: "2025-07-05", weight: 62.0, bodyFat: 24.8, muscleMass: 27.5, bmi: 22.9, hydration: 58.7 },
    ],
    meals: [
      { id: "ml9", name: "Breakfast", calories: 380, protein: 28, carbs: 42, fat: 9 },
      { id: "ml10", name: "Lunch", calories: 480, protein: 36, carbs: 50, fat: 12 },
    ],
    assessments: [
      { id: "as5", date: "2024-05-25", fitnessLevel: "Beginner", goals: "Lean muscle & confidence", injuries: "None", coachRemarks: "Shy but highly coachable. Great potential." },
    ],
    pastSessions: [
      { id: "ps8", date: "2025-07-11", type: "PT", duration: 60, notes: "Arms & shoulders" },
    ],
  },
  {
    id: "m5", name: "Reem Salah", nameAr: "ريم صلاح", initials: "RS",
    age: 30, phone: "+971 50 777 8888", email: "reem@email.com",
    plan: "Elite PT", joinDate: "2023-03-10", planExpiry: "2026-03-10",
    lastSession: "2025-07-15", progress: 91,
    exercises: [
      { id: "e11", name: "Power Clean", muscleGroup: "Full Body", weight: 45, sets: 5, repsPerSet: 5 },
      { id: "e12", name: "Front Squat", muscleGroup: "Legs", weight: 55, sets: 4, repsPerSet: 6 },
      { id: "e13", name: "Box Jump", muscleGroup: "Plyometrics", weight: 0, sets: 4, repsPerSet: 8 },
    ],
    inBodyScans: [
      { id: "ib7", date: "2025-06-28", weight: 65.5, bodyFat: 19.8, muscleMass: 32.1, bmi: 23.4, hydration: 63.1 },
      { id: "ib8", date: "2025-07-14", weight: 65.1, bodyFat: 19.2, muscleMass: 32.6, bmi: 23.3, hydration: 63.8 },
    ],
    meals: [
      { id: "ml11", name: "Pre-workout", calories: 350, protein: 30, carbs: 42, fat: 6 },
      { id: "ml12", name: "Post-workout", calories: 450, protein: 40, carbs: 48, fat: 8 },
      { id: "ml13", name: "Dinner", calories: 620, protein: 45, carbs: 58, fat: 18 },
    ],
    assessments: [
      { id: "as6", date: "2023-03-15", fitnessLevel: "Intermediate", goals: "Athletic performance", injuries: "None", coachRemarks: "Natural athlete. High pain threshold and coachability." },
      { id: "as7", date: "2025-01-10", fitnessLevel: "Advanced", goals: "CrossFit competition prep", injuries: "None", coachRemarks: "Outstanding. One of the best members in the gym." },
    ],
    pastSessions: [
      { id: "ps9", date: "2025-07-15", type: "PT", duration: 75, notes: "Olympic lifting session" },
      { id: "ps10", date: "2025-07-13", type: "PT", duration: 60, notes: "HIIT conditioning" },
      { id: "ps11", date: "2025-07-11", type: "PT", duration: 60, notes: "Strength testing" },
    ],
  },
];

// Use LOCAL date parts (not UTC) to avoid timezone-shift bugs in UTC+ regions
function _localISO(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
// Offset relative to TODAY (negative = past, positive = future)
function _rel(offset: number): string {
  const d = new Date();
  d.setDate(d.getDate() + offset);
  return _localISO(d);
}
const D_TODAY   = _rel(0);
const D_MINUS2  = _rel(-2);  // 2 days ago
const D_MINUS1  = _rel(-1);  // yesterday
const D_PLUS1   = _rel(1);   // tomorrow
const D_PLUS2   = _rel(2);   // day after tomorrow
const D_PLUS3   = _rel(3);   // 3 days from now

const INITIAL_SESSIONS: PTSession[] = [
  // 2 days ago — completed
  { id: "s_m_1", memberId: "m1", memberName: "Omar Al-Farsi",  date: D_MINUS2, time: "07:00", duration: 60, location: "Floor A – Zone 1", type: "PT", status: "completed" },
  { id: "s_m_2", memberId: "m2", memberName: "Layla Mohammed", date: D_MINUS2, time: "09:00", duration: 60, location: "Floor B – Zone 2", type: "PT", status: "completed" },
  { id: "s_m_3", memberId: "m5", memberName: "Reem Salah",     date: D_MINUS2, time: "11:00", duration: 75, location: "Olympic Platform",  type: "PT", status: "completed" },
  // yesterday — completed
  { id: "s_t_1", memberId: "m2", memberName: "Layla Mohammed", date: D_MINUS1, time: "07:30", duration: 60, location: "Floor B – Zone 2", type: "PT", status: "completed" },
  { id: "s_t_2", memberId: "m4", memberName: "Nour Khalid",    date: D_MINUS1, time: "10:00", duration: 60, location: "Floor A – Zone 3", type: "PT", status: "completed" },
  // TODAY
  { id: "s1",    memberId: "m2", memberName: "Layla Mohammed",  date: D_TODAY, time: "07:00", duration: 60, location: "Floor B – Zone 2",  type: "PT", status: "upcoming", startingSoon: true },
  { id: "s2",    memberId: "m5", memberName: "Reem Salah",      date: D_TODAY, time: "09:30", duration: 75, location: "Olympic Platform",   type: "PT", status: "upcoming" },
  { id: "s3",    memberId: "m1", memberName: "Omar Al-Farsi",   date: D_TODAY, time: "11:00", duration: 60, location: "Floor A – Zone 1",  type: "PT", status: "upcoming" },
  // tomorrow
  { id: "s4",    memberId: "m3", memberName: "Khaled Ibrahim",  date: D_PLUS1, time: "15:00", duration: 45, location: "Cardio Zone",        type: "PT", status: "upcoming" },
  { id: "s5",    memberId: "m4", memberName: "Nour Khalid",     date: D_PLUS1, time: "17:00", duration: 60, location: "Floor A – Zone 3",  type: "PT", status: "upcoming" },
  { id: "s_th3", memberId: "m2", memberName: "Layla Mohammed",  date: D_PLUS1, time: "19:00", duration: 60, location: "Floor B – Zone 2",  type: "PT", status: "upcoming" },
  // +2 days
  { id: "s_f1",  memberId: "m5", memberName: "Reem Salah",      date: D_PLUS2, time: "15:00", duration: 75, location: "Olympic Platform",   type: "PT", status: "upcoming" },
  { id: "s_f2",  memberId: "m1", memberName: "Omar Al-Farsi",   date: D_PLUS2, time: "17:30", duration: 60, location: "Floor A – Zone 1",  type: "PT", status: "upcoming" },
  // +3 days
  { id: "s_sa1", memberId: "m5", memberName: "Reem Salah",      date: D_PLUS3, time: "07:00", duration: 75, location: "Olympic Platform",   type: "PT", status: "upcoming" },
  { id: "s_sa2", memberId: "m1", memberName: "Omar Al-Farsi",   date: D_PLUS3, time: "09:00", duration: 60, location: "Floor A – Zone 1",  type: "PT", status: "upcoming" },
  { id: "s_sa3", memberId: "m2", memberName: "Layla Mohammed",  date: D_PLUS3, time: "11:00", duration: 60, location: "Floor B – Zone 2",  type: "PT", status: "upcoming" },
];

const INITIAL_SHIFTS: WorkShift[] = [
  { id: "sh1", coachId: "c1", date: D_MINUS2, startTime: "06:00", endTime: "14:00", status: "completed" },
  { id: "sh2", coachId: "c1", date: D_MINUS1, startTime: "06:00", endTime: "14:00", status: "completed" },
  { id: "sh3", coachId: "c1", date: D_TODAY,  startTime: "06:00", endTime: "14:00", status: "scheduled" },
  { id: "sh4", coachId: "c1", date: D_PLUS1,  startTime: "14:00", endTime: "22:00", status: "scheduled" },
  { id: "sh5", coachId: "c1", date: D_PLUS2,  startTime: "14:00", endTime: "22:00", status: "scheduled" },
  { id: "sh6", coachId: "c1", date: D_PLUS3,  startTime: "06:00", endTime: "14:00", status: "scheduled" },
];

const INITIAL_CLASSES: GymClass[] = [
  // 2 days ago
  { id: "cl_m1",  name: "Morning HIIT",        instructor: "Ahmed Hassan",   instructorId: "c1", date: D_MINUS2, time: "08:00", duration: 45, location: "Studio A",    capacity: 20, enrolled: 20, isOpen: false },
  // yesterday
  { id: "cl_t1",  name: "Strength Circuit",    instructor: "Khalid Mahmoud", instructorId: "c3", date: D_MINUS1, time: "07:00", duration: 60, location: "Floor C",     capacity: 12, enrolled: 9,  isOpen: true },
  { id: "cl_t2",  name: "Stretch & Mobility",  instructor: "Lina Farhat",    instructorId: "c4", date: D_MINUS1, time: "10:00", duration: 60, location: "Studio B",    capacity: 15, enrolled: 15, isOpen: false },
  // TODAY
  { id: "cl1",    name: "HIIT Blast",          instructor: "Ahmed Hassan",   instructorId: "c1", date: D_TODAY,  time: "08:00", duration: 45, location: "Studio A",    capacity: 20, enrolled: 18, isOpen: true },
  { id: "cl_w2",  name: "Core Conditioning",   instructor: "Ahmed Hassan",   instructorId: "c1", date: D_TODAY,  time: "10:00", duration: 45, location: "Studio A",    capacity: 20, enrolled: 11, isOpen: true },
  // tomorrow
  { id: "cl_th1", name: "Yoga Flow",           instructor: "Lina Farhat",    instructorId: "c4", date: D_PLUS1,  time: "16:00", duration: 60, location: "Studio B",    capacity: 15, enrolled: 8,  isOpen: true },
  { id: "cl2",    name: "Core Power",          instructor: "Ahmed Hassan",   instructorId: "c1", date: D_PLUS1,  time: "18:30", duration: 45, location: "Studio A",    capacity: 20, enrolled: 12, isOpen: true },
  // +2 days
  { id: "cl5",    name: "Boxing Fundamentals", instructor: "Ahmed Hassan",   instructorId: "c1", date: D_PLUS2,  time: "17:00", duration: 60, location: "Boxing Ring", capacity: 16, enrolled: 7,  isOpen: true },
  { id: "cl_f2",  name: "Kettlebell Power",    instructor: "Khalid Mahmoud", instructorId: "c3", date: D_PLUS2,  time: "19:00", duration: 45, location: "Floor C",     capacity: 14, enrolled: 10, isOpen: true },
  // +3 days
  { id: "cl_sa1", name: "HIIT Blast",          instructor: "Ahmed Hassan",   instructorId: "c1", date: D_PLUS3,  time: "09:00", duration: 45, location: "Studio A",    capacity: 20, enrolled: 16, isOpen: true },
];

const INITIAL_REQUESTS: PTRequest[] = [
  { id: "r1", memberName: "Faisal Al-Dosari", memberNameAr: "فيصل الدوسري", memberInitials: "FD", requestedPlan: "Premium PT (3x/week)", preferredTimes: "Mornings 7–10am", status: "pending", requestDate: "2025-07-14" },
  { id: "r2", memberName: "Dana Nasser", memberNameAr: "دانا ناصر", memberInitials: "DN", requestedPlan: "Elite PT (5x/week)", preferredTimes: "Evenings 6–9pm", status: "pending", requestDate: "2025-07-13" },
  { id: "r3", memberName: "Tariq Salem", memberNameAr: "طارق سالم", memberInitials: "TS", requestedPlan: "Basic PT (2x/week)", preferredTimes: "Weekends, any time", status: "pending", requestDate: "2025-07-12" },
];

const INITIAL_MESSAGES: Record<string, ChatMessage[]> = {
  m1: [
    { id: "msg1", senderId: "m1", text: "Coach, can we move tomorrow's session to 8am?", timestamp: "2025-07-14T09:15:00", isCoach: false },
    { id: "msg2", senderId: "c1", text: "Sure Omar, 8am works. See you tomorrow!", timestamp: "2025-07-14T09:22:00", isCoach: true },
    { id: "msg3", senderId: "m1", text: "Perfect, thanks!", timestamp: "2025-07-14T09:24:00", isCoach: false },
  ],
  m2: [
    { id: "msg4", senderId: "c1", text: "Great session today Layla! Keep up the intensity.", timestamp: "2025-07-14T11:00:00", isCoach: true },
    { id: "msg5", senderId: "m2", text: "Thank you coach! Feeling stronger every day 💪", timestamp: "2025-07-14T11:05:00", isCoach: false },
  ],
  m3: [
    { id: "msg6", senderId: "m3", text: "Is it okay to skip the session this Thursday?", timestamp: "2025-07-13T16:30:00", isCoach: false },
    { id: "msg7", senderId: "c1", text: "No problem Khaled, just let me know ahead of time. We can reschedule to Saturday.", timestamp: "2025-07-13T16:45:00", isCoach: true },
  ],
  m4: [
    { id: "msg8", senderId: "m4", text: "Coach can you send me this week's workout plan?", timestamp: "2025-07-12T08:00:00", isCoach: false },
    { id: "msg9", senderId: "c1", text: "Check the app Nour, I've updated your exercises in your profile!", timestamp: "2025-07-12T08:10:00", isCoach: true },
    { id: "msg10", senderId: "m4", text: "Found it, شكراً!", timestamp: "2025-07-12T08:15:00", isCoach: false },
  ],
  m5: [
    { id: "msg11", senderId: "m5", text: "Ready for tomorrow's Olympic lifting session!", timestamp: "2025-07-14T20:00:00", isCoach: false },
    { id: "msg12", senderId: "c1", text: "Let's go Reem! We're going for a new PR tomorrow.", timestamp: "2025-07-14T20:05:00", isCoach: true },
  ],
};

const INITIAL_NOTIFICATIONS: Notification[] = [
  { id: "n1", type: "reschedule", title: "Session Rescheduled", titleAr: "إعادة جدولة", body: "Omar Al-Farsi moved his 7am session to 8am", bodyAr: "عمر الفارسي غيّر موعده من 7 صباحاً إلى 8 صباحاً", timestamp: "2025-07-14T09:15:00", read: false },
  { id: "n2", type: "request", title: "New PT Request", titleAr: "طلب تدريب جديد", body: "Faisal Al-Dosari submitted a PT subscription request", bodyAr: "فيصل الدوسري قدّم طلب اشتراك للتدريب الشخصي", timestamp: "2025-07-14T08:00:00", read: false },
  { id: "n3", type: "reminder", title: "Session in 30 min", titleAr: "جلسة خلال 30 دقيقة", body: "PT with Layla Mohammed at 07:00 – Floor B Zone 2", bodyAr: "جلسة مع ليلى محمد الساعة 7:00 – الطابق B", timestamp: "2025-07-15T06:30:00", read: false },
  { id: "n4", type: "message", title: "New Message", titleAr: "رسالة جديدة", body: "Reem Salah: Ready for tomorrow's session!", bodyAr: "ريم صلاح: جاهزة لجلسة الغد!", timestamp: "2025-07-14T20:00:00", read: true },
];

const INITIAL_COACH_SHIFTS: CoachShift[] = [
  { coachId: "c1", day: "Mon", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c1", day: "Tue", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c1", day: "Wed", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c1", day: "Thu", startTime: "14:00", endTime: "22:00", isOff: false },
  { coachId: "c1", day: "Fri", startTime: "14:00", endTime: "22:00", isOff: false },
  { coachId: "c1", day: "Sat", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c1", day: "Sun", startTime: "", endTime: "", isOff: true },
  { coachId: "c3", day: "Mon", startTime: "14:00", endTime: "22:00", isOff: false },
  { coachId: "c3", day: "Tue", startTime: "14:00", endTime: "22:00", isOff: false },
  { coachId: "c3", day: "Wed", startTime: "", endTime: "", isOff: true },
  { coachId: "c3", day: "Thu", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c3", day: "Fri", startTime: "06:00", endTime: "14:00", isOff: false },
  { coachId: "c3", day: "Sat", startTime: "14:00", endTime: "22:00", isOff: false },
  { coachId: "c3", day: "Sun", startTime: "", endTime: "", isOff: true },
  { coachId: "c4", day: "Mon", startTime: "09:00", endTime: "17:00", isOff: false },
  { coachId: "c4", day: "Tue", startTime: "09:00", endTime: "17:00", isOff: false },
  { coachId: "c4", day: "Wed", startTime: "09:00", endTime: "17:00", isOff: false },
  { coachId: "c4", day: "Thu", startTime: "", endTime: "", isOff: true },
  { coachId: "c4", day: "Fri", startTime: "09:00", endTime: "17:00", isOff: false },
  { coachId: "c4", day: "Sat", startTime: "", endTime: "", isOff: true },
  { coachId: "c4", day: "Sun", startTime: "", endTime: "", isOff: true },
];

const INITIAL_INBODY_SLOTS: InBodySlot[] = [
  { id: "ibs1", date: "2025-07-15", time: "08:00", supervisorId: "c1", supervisorName: "Ahmed Hassan", memberName: "Omar Al-Farsi" },
  { id: "ibs2", date: "2025-07-15", time: "09:00", supervisorId: "c1", supervisorName: "Ahmed Hassan", memberName: "" },
  { id: "ibs3", date: "2025-07-17", time: "10:00", supervisorId: "c4", supervisorName: "Lina Farhat", memberName: "Nour Khalid" },
  { id: "ibs4", date: "2025-07-18", time: "11:00", supervisorId: "c3", supervisorName: "Khalid Mahmoud", memberName: "" },
];

const INITIAL_DEDUCTIONS: Deduction[] = [
  { id: "d1", coachId: "c1", amount: 200, reason: "Late arrival – 3 occurrences", date: "2025-07-01" },
  { id: "d2", coachId: "c3", amount: 300, reason: "Missed class without notice", date: "2025-07-05" },
  { id: "d3", coachId: "c4", amount: 150, reason: "Admin document delay", date: "2025-07-08" },
];

interface DataContextType {
  members: Member[];
  sessions: PTSession[];
  shifts: WorkShift[];
  classes: GymClass[];
  requests: PTRequest[];
  messages: Record<string, ChatMessage[]>;
  notifications: Notification[];
  timeEntries: TimeEntry[];
  attendance: AttendanceEntry[];
  coachShifts: CoachShift[];
  inBodySlots: InBodySlot[];
  deductions: Deduction[];
  shiftStatus: "on_shift" | "off" | "break" | "training";
  activeBreak: TimeEntry | null;
  activeTraining: TimeEntry | null;
  checkedIn: boolean;
  currentAttendance: AttendanceEntry | null;
  unreadCount: number;
  // mutations
  updateMember: (id: string, updates: Partial<Member>) => void;
  addExercise: (memberId: string, ex: Exercise) => void;
  removeExercise: (memberId: string, exId: string) => void;
  addInBodyScan: (memberId: string, scan: InBodyScan) => void;
  addMeal: (memberId: string, meal: Meal) => void;
  removeMeal: (memberId: string, mealId: string) => void;
  addAssessment: (memberId: string, assessment: Assessment) => void;
  acceptRequest: (id: string, days: string, time: string) => void;
  rejectRequest: (id: string, reason: string) => void;
  sendMessage: (memberId: string, text: string) => void;
  startBreak: () => void;
  endBreak: () => void;
  startPersonalTraining: () => void;
  endPersonalTraining: () => void;
  checkIn: (location: string) => void;
  checkOut: () => void;
  markAllRead: () => void;
  updateCoachShift: (coachId: string, day: string, shift: Partial<CoachShift>) => void;
  addInBodySlot: (slot: InBodySlot) => void;
  toggleClass: (id: string) => void;
  updateClass: (id: string, updates: Partial<GymClass>) => void;
  addClass: (cls: GymClass) => void;
  addDeduction: (d: Deduction) => void;
}

const DataContext = createContext<DataContextType | null>(null);

export function DataProvider({ children }: { children: React.ReactNode }) {
  const [members, setMembers] = useState<Member[]>(INITIAL_MEMBERS);
  const [sessions] = useState<PTSession[]>(INITIAL_SESSIONS);
  const [shifts] = useState<WorkShift[]>(INITIAL_SHIFTS);
  const [classes, setClasses] = useState<GymClass[]>(INITIAL_CLASSES);
  const [requests, setRequests] = useState<PTRequest[]>(INITIAL_REQUESTS);
  const [messages, setMessages] = useState(INITIAL_MESSAGES);
  const [notifications, setNotifications] = useState<Notification[]>(INITIAL_NOTIFICATIONS);
  const [timeEntries, setTimeEntries] = useState<TimeEntry[]>([]);
  const [attendance, setAttendance] = useState<AttendanceEntry[]>([]);
  const [coachShifts, setCoachShifts] = useState<CoachShift[]>(INITIAL_COACH_SHIFTS);
  const [inBodySlots, setInBodySlots] = useState<InBodySlot[]>(INITIAL_INBODY_SLOTS);
  const [deductions, setDeductions] = useState<Deduction[]>(INITIAL_DEDUCTIONS);
  const [shiftStatus, setShiftStatus] = useState<"on_shift" | "off" | "break" | "training">("on_shift");
  const [activeBreak, setActiveBreak] = useState<TimeEntry | null>(null);
  const [activeTraining, setActiveTraining] = useState<TimeEntry | null>(null);
  const [checkedIn, setCheckedIn] = useState(false);
  const [currentAttendance, setCurrentAttendance] = useState<AttendanceEntry | null>(null);

  const unreadCount = notifications.filter(n => !n.read).length;

  const updateMember = (id: string, updates: Partial<Member>) =>
    setMembers(prev => prev.map(m => m.id === id ? { ...m, ...updates } : m));

  const addExercise = (memberId: string, ex: Exercise) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, exercises: [...m.exercises, ex] } : m));

  const removeExercise = (memberId: string, exId: string) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, exercises: m.exercises.filter(e => e.id !== exId) } : m));

  const addInBodyScan = (memberId: string, scan: InBodyScan) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, inBodyScans: [...m.inBodyScans, scan] } : m));

  const addMeal = (memberId: string, meal: Meal) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, meals: [...m.meals, meal] } : m));

  const removeMeal = (memberId: string, mealId: string) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, meals: m.meals.filter(ml => ml.id !== mealId) } : m));

  const addAssessment = (memberId: string, assessment: Assessment) =>
    setMembers(prev => prev.map(m => m.id === memberId ? { ...m, assessments: [assessment, ...m.assessments] } : m));

  const acceptRequest = (id: string, days: string, time: string) =>
    setRequests(prev => prev.map(r => r.id === id ? { ...r, status: "accepted", scheduledDays: days, scheduledTime: time } : r));

  const rejectRequest = (id: string, reason: string) =>
    setRequests(prev => prev.map(r => r.id === id ? { ...r, status: "rejected", reason } : r));

  const sendMessage = (memberId: string, text: string) => {
    const newMsg: ChatMessage = {
      id: `msg_${Date.now()}`, senderId: "coach", text,
      timestamp: new Date().toISOString(), isCoach: true,
    };
    setMessages(prev => ({ ...prev, [memberId]: [...(prev[memberId] || []), newMsg] }));
  };

  const startBreak = () => {
    const entry: TimeEntry = { id: `te_${Date.now()}`, type: "break", startTime: new Date().toISOString() };
    setActiveBreak(entry);
    setShiftStatus("break");
  };

  const endBreak = () => {
    if (!activeBreak) return;
    const end = new Date();
    const start = new Date(activeBreak.startTime);
    const duration = Math.round((end.getTime() - start.getTime()) / 60000);
    const completed: TimeEntry = { ...activeBreak, endTime: end.toISOString(), duration };
    setTimeEntries(prev => [...prev, completed]);
    setActiveBreak(null);
    setShiftStatus("on_shift");
  };

  const startPersonalTraining = () => {
    const entry: TimeEntry = { id: `te_${Date.now()}`, type: "personal_training", startTime: new Date().toISOString() };
    setActiveTraining(entry);
    setShiftStatus("training");
  };

  const endPersonalTraining = () => {
    if (!activeTraining) return;
    const end = new Date();
    const start = new Date(activeTraining.startTime);
    const duration = Math.round((end.getTime() - start.getTime()) / 60000);
    const completed: TimeEntry = { ...activeTraining, endTime: end.toISOString(), duration };
    setTimeEntries(prev => [...prev, completed]);
    setActiveTraining(null);
    setShiftStatus("on_shift");
  };

  const checkIn = (location: string) => {
    const entry: AttendanceEntry = {
      id: `att_${Date.now()}`, date: new Date().toLocaleDateString(),
      timeIn: new Date().toLocaleTimeString(), location,
    };
    setCurrentAttendance(entry);
    setCheckedIn(true);
  };

  const checkOut = () => {
    if (!currentAttendance) return;
    const timeOut = new Date().toLocaleTimeString();
    const completed: AttendanceEntry = { ...currentAttendance, timeOut };
    setAttendance(prev => [...prev, completed]);
    setCurrentAttendance(null);
    setCheckedIn(false);
  };

  const markAllRead = () =>
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));

  const updateCoachShift = (coachId: string, day: string, shift: Partial<CoachShift>) =>
    setCoachShifts(prev => prev.map(s => s.coachId === coachId && s.day === day ? { ...s, ...shift } : s));

  const addInBodySlot = (slot: InBodySlot) =>
    setInBodySlots(prev => [...prev, slot]);

  const toggleClass = (id: string) =>
    setClasses(prev => prev.map(c => c.id === id ? { ...c, isOpen: !c.isOpen } : c));

  const updateClass = (id: string, updates: Partial<GymClass>) =>
    setClasses(prev => prev.map(c => c.id === id ? { ...c, ...updates } : c));

  const addClass = (cls: GymClass) => setClasses(prev => [...prev, cls]);

  const addDeduction = (d: Deduction) => setDeductions(prev => [...prev, d]);

  return (
    <DataContext.Provider value={{
      members, sessions, shifts, classes, requests, messages, notifications,
      timeEntries, attendance, coachShifts, inBodySlots, deductions,
      shiftStatus, activeBreak, activeTraining, checkedIn, currentAttendance, unreadCount,
      updateMember, addExercise, removeExercise, addInBodyScan, addMeal, removeMeal,
      addAssessment, acceptRequest, rejectRequest, sendMessage,
      startBreak, endBreak, startPersonalTraining, endPersonalTraining,
      checkIn, checkOut, markAllRead, updateCoachShift, addInBodySlot,
      toggleClass, updateClass, addClass, addDeduction,
    }}>
      {children}
    </DataContext.Provider>
  );
}

export function useData() {
  const ctx = useContext(DataContext);
  if (!ctx) throw new Error("useData must be used within DataProvider");
  return ctx;
}
