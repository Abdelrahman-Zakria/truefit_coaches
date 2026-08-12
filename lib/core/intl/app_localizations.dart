import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'nav_home': 'Home', 'nav_schedule': 'Schedule', 'nav_members': 'Members',
      'nav_requests': 'Requests', 'nav_chat': 'Chat', 'nav_management': 'Management',
      'nav_time': 'Time', 'nav_attendance': 'Attendance', 'nav_more': 'More', 'nav_profile': 'Profile',
      'good_morning': 'Good Morning', 'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening', 'on_shift': 'On Shift', 'off_shift': 'Off Duty',
      'on_break': 'On Break', 'personal_training': 'Coach Training',
      'today_sessions': 'PT Sessions', 'today_classes': 'Classes',
      'pending_requests': 'Pending Requests', 'live_time': 'Live',
      'work_shifts': 'Work Shifts', 'pt_sessions': 'PT Sessions',
      'see_all': 'See All',
      'all_members': 'All Members', 'member_plan': 'Plan', 'last_session': 'Last Session',
      'overview': 'Overview', 'workouts': 'Workouts', 'inbody': 'InBody',
      'diet_plan': 'Diet Plan', 'assessment': 'Assessment', 'sessions': 'Sessions',
      'add_exercise': 'Add Exercise', 'exercise_name': 'Exercise Name',
      'muscle_group': 'Muscle Group', 'weight_kg': 'Weight (kg)', 'sets': 'Sets',
      'reps_per_set': 'Reps / Set', 'save': 'Save', 'cancel': 'Cancel',
      'delete': 'Delete', 'edit': 'Edit', 'add': 'Add', 'confirm': 'Confirm',
      'accept': 'Accept', 'reject': 'Reject', 'set_schedule': 'Set Schedule',
      'reject_reason': 'Rejection Reason', 'requested_plan': 'Requested Plan',
      'preferred_times': 'Preferred Times', 'type_message': 'Type a message...',
      'send': 'Send', 'conversations': 'Conversations', 'start_break': 'Start Break',
      'end_break': 'End Break', 'start_pt': 'Start Coach PT', 'end_pt': 'End Coach PT',
      'session_history': 'Session History', 'duration': 'Duration',
      'check_in': 'Check In', 'check_out': 'Check Out',
      'hold_to_checkin': 'Hold to Check In', 'confirmed': 'Checked In',
      'notifications': 'Notifications', 'mark_all_read': 'Mark All Read',
      'management': 'Management', 'shift_planner': 'Shift Planner',
      'inbody_schedule': 'InBody Schedule', 'class_management': 'Classes',
      'salary_deductions': 'Salary & Deductions', 'logout': 'Log Out',
      'sign_in': 'Sign In', 'email': 'Email', 'password': 'Password',
      'welcome_back': 'Welcome Back', 'coach_portal': 'Coach Portal',
      'today': 'Today', 'name': 'Name', 'location': 'Location', 'time': 'Time',
      'days': 'Days', 'start_time': 'Start Time', 'end_time': 'End Time',
      'classes': 'Classes', 'capacity': 'Capacity', 'instructor': 'Instructor',
      'base_salary': 'Base Salary', 'amount': 'Amount', 'reason': 'Reason', 'date': 'Date',
      'deductions': 'Deductions', 'add_deduction': 'Add Deduction',
      'body_fat': 'Body Fat %', 'muscle_mass': 'Muscle Mass (kg)', 'bmi': 'BMI',
      'hydration': 'Hydration %', 'weight': 'Weight (kg)', 'scan_date': 'Scan Date',
      'fitness_level': 'Fitness Level', 'goals': 'Goals',
      'injuries': 'Injuries / Notes', 'coach_remarks': 'Coach Remarks',
      'meal_name': 'Meal Name', 'calories': 'Calories', 'protein': 'Protein (g)',
      'carbs': 'Carbs (g)', 'fat': 'Fat (g)', 'add_meal': 'Add Meal',
      'subscription': 'Subscription', 'attendance_history': 'Attendance History',
      'time_in': 'Time In', 'time_out': 'Time Out', 'no_data': 'No data yet',
      'search': 'Search members...', 'filter': 'Filter',
      'login_subtitle': 'Sign in to your coach account',
      'shift_off': 'Day Off', 'assign_shift': 'Assign Shift',
      'add_slot': 'Add Slot', 'open_class': 'Open', 'closed_class': 'Closed',
      'total_deductions': 'Total Deductions', 'net_salary': 'Net Salary',
      'coach': 'Coach', 'head_coach': 'Head Coach', 'reschedule_alert': 'Rescheduled',
      'new_request': 'New Request', 'session_reminder': 'Session in 30 min',
      'new_message': 'New Message', 'type': 'Type', 'member': 'Member',
      'personal_info': 'Personal Info', 'age': 'Age', 'phone': 'Phone',
      'join_date': 'Join Date', 'plan_expiry': 'Plan Expiry', 'records': 'Records',
      'time_tracking': 'Time Tracking', 'settings': 'Settings', 'language': 'Language',
      'english': 'English', 'arabic': 'Arabic', 'active': 'Active', 'confirmed_text': 'CONFIRMED',
      'hold_for_2s': 'Hold for 2 seconds', 'scanning': 'SCANNING', 'no_history': 'No history found',
      'latest_inbody': 'LATEST INBODY', 'muscle': 'MUSCLE', 'no_workout': 'NO WORKOUT PLAN ASSIGNED',
      'no_scans': 'NO INBODY SCANS FOUND', 'weight_trend': 'WEIGHT TREND', 'new_scan': 'NEW SCAN',
      'no_diet': 'NO DIET PLAN FOUND', 'daily_totals': 'DAILY TOTALS', 'edit_goals': 'EDIT GOALS',
      'new_assessment': 'NEW ASSESSMENT', 'items': 'ITEMS', 'add_item': 'ADD ITEM',
      'save_changes': 'SAVE CHANGES', 'edit_exercise': 'EDIT EXERCISE', 'save_exercise': 'SAVE EXERCISE',
      'save_assessment': 'SAVE ASSESSMENT', 'no_assessments': 'NO ASSESSMENTS FOUND',
      'no_sessions_found': 'NO SESSIONS FOUND',
      'leave_requests': 'Leave Requests', 'request_leave': 'Request Leave',
      'booking_requests': 'Booking Requests', 'request_details': 'Request Details',
      'no_requests': 'No pending requests',
      'phone_field': 'PHONE', 'email_field': 'EMAIL', 'address_field': 'ADDRESS', 'member_id': 'MEMBER ID',
      'status': 'STATUS', 'sessions_left': 'SESSIONS LEFT', 'gym_floor': 'Gym Floor',
      'open_btn': 'OPEN',      'pt_subs': 'PT SUBS', 'active_members': 'Active Members',
      'requests': 'REQUESTS', 'soon': 'SOON', 'no_sessions_today': 'NO SESSIONS TODAY',
      'chats': 'CHATS', 'no_conversations': 'No conversations yet', 'active_now': 'Active now',
      'start_conversation': 'Start the conversation', 'recording': 'Recording…',
      'reply_great_work': 'Great work today!', 'reply_diet_plan': 'Check your new diet plan',
      'reply_check_in': 'Don\'t forget to check in', 'reply_push_harder': 'Let\'s push harder!',
    },
    'ar': {
      'nav_home': 'الرئيسية', 'nav_schedule': 'الجدول', 'nav_members': 'الأعضاء',
      'nav_requests': 'الطلبات', 'nav_chat': 'المحادثات', 'nav_management': 'الإدارة',
      'nav_time': 'الوقت', 'nav_attendance': 'الحضور', 'nav_more': 'المزيد', 'nav_profile': 'الملف الشخصي',
      'good_morning': 'صباح الخير', 'good_afternoon': 'مساء الخير',
      'good_evening': 'مساء النور', 'on_shift': 'في الوردية', 'off_shift': 'خارج الدوام',
      'on_break': 'في استراحة', 'personal_training': 'تدريب المدرب',
      'today_sessions': 'جلسات PT', 'today_classes': 'الكلاسات',
      'pending_requests': 'طلبات معلقة', 'live_time': 'الآن',
      'work_shifts': 'الوردية', 'pt_sessions': 'جلسات التدريب',
      'see_all': 'عرض الكل',
      'all_members': 'جميع الأعضاء', 'member_plan': 'الخطة', 'last_session': 'آخر جلسة',
      'overview': 'نظرة عامة', 'workouts': 'التمارين', 'inbody': 'إن بودي',
      'diet_plan': 'الحمية', 'assessment': 'التقييم', 'sessions': 'الجلسات',
      'add_exercise': 'إضافة تمرين', 'exercise_name': 'اسم التمرين',
      'muscle_group': 'المجموعة العضلية', 'weight_kg': 'الوزن (كجم)', 'sets': 'الجولات',
      'reps_per_set': 'تكرارات / جولة', 'save': 'حفظ', 'cancel': 'إلغاء',
      'delete': 'حذف', 'edit': 'تعديل', 'add': 'إضافة', 'confirm': 'تأكيد',
      'accept': 'قبول', 'reject': 'رفض', 'set_schedule': 'تحديد الجدول',
      'reject_reason': 'سبب الرفض', 'requested_plan': 'الخطة المطلوبة',
      'preferred_times': 'الأوقات المفضلة', 'type_message': 'اكتب رسالة...',
      'send': 'إرسال', 'conversations': 'المحادثات', 'start_break': 'بدء الاستراحة',
      'end_break': 'إنهاء الاستراحة', 'start_pt': 'بدء تدريب المدرب',
      'end_pt': 'إنهاء تدريب المدرب', 'session_history': 'سجل الجلسات',
      'duration': 'المدة', 'check_in': 'تسجيل الحضور', 'check_out': 'تسجيل الانصراف',
      'hold_to_checkin': 'اضغط للحضور', 'confirmed': 'تم التسجيل',
      'notifications': 'الإشعارات', 'mark_all_read': 'تعليم الكل',
      'management': 'الإدارة', 'shift_planner': 'مخطط الوردية',
      'inbody_schedule': 'جدول إن بودي', 'class_management': 'الكلاسات',
      'salary_deductions': 'الرواتب والخصومات', 'logout': 'تسجيل الخروج',
      'sign_in': 'دخول', 'email': 'البريد الإلكتروني', 'password': 'كلمة المرور',
      'welcome_back': 'أهلاً بعودتك', 'coach_portal': 'بوابة المدرب',
      'today': 'اليوم', 'name': 'الاسم', 'location': 'الموقع', 'time': 'الوقت',
      'days': 'الأيام', 'start_time': 'وقت البداية', 'end_time': 'وقت النهاية',
      'classes': 'الكلاسات', 'capacity': 'السعة', 'instructor': 'المدرب',
      'base_salary': 'الراتب الأساسي', 'amount': 'المبلغ', 'reason': 'السبب',
      'date': 'التاريخ', 'deductions': 'الخصومات', 'add_deduction': 'إضافة خصم',
      'body_fat': 'نسبة الدهون %', 'muscle_mass': 'الكتلة العضلية (كجم)', 'bmi': 'مؤشر الكتلة',
      'hydration': 'الترطيب %', 'weight': 'الوزن (كجم)', 'scan_date': 'تاريخ الفحص',
      'fitness_level': 'مستوى اللياقة', 'goals': 'الأهداف',
      'injuries': 'الإصابات / ملاحظات', 'coach_remarks': 'ملاحظات المدرب',
      'meal_name': 'اسم الوجبة', 'calories': 'السعرات', 'protein': 'بروتين (جم)',
      'carbs': 'كربوهيدرات (جم)', 'fat': 'دهون (جم)', 'add_meal': 'إضافة وجبة',
      'subscription': 'الاشتراك', 'attendance_history': 'سجل الحضور',
      'time_in': 'وقت الدخول', 'time_out': 'وقت الخروج', 'no_data': 'لا توجد بيانات',
      'search': 'بحث عن عضو...', 'filter': 'تصفية',
      'login_subtitle': 'سجّل دخولك كمدرب',
      'shift_off': 'إجازة', 'assign_shift': 'تعيين وردية',
      'add_slot': 'إضافة موعد', 'open_class': 'مفتوح', 'closed_class': 'مغلق',
      'total_deductions': 'إجمالي الخصومات', 'net_salary': 'صافي الراتب',
      'coach': 'مدرب', 'head_coach': 'كبير المدربين', 'reschedule_alert': 'إعادة جدولة',
      'new_request': 'طلب جديد', 'session_reminder': 'جلسة خلال 30 دقيقة',
      'new_message': 'رسالة جديدة', 'type': 'النوع', 'member': 'العضو',
      'personal_info': 'المعلومات الشخصية', 'age': 'العمر', 'phone': 'الهاتف',
      'join_date': 'تاريخ الانضمام', 'plan_expiry': 'انتهاء الخطة', 'records': 'سجلات',
      'time_tracking': 'تتبع الوقت', 'settings': 'الإعدادات', 'language': 'اللغة',
      'english': 'الإنجليزية', 'arabic': 'العربية', 'active': 'نشط', 'confirmed_text': 'تم التأكيد',
      'hold_for_2s': 'اضغط لمدة ثانيتين', 'scanning': 'جاري المسح', 'no_history': 'لم يتم العثور على سجل',
      'latest_inbody': 'أحدث إن بودي', 'muscle': 'العضلات', 'no_workout': 'لم يتم تعيين خطة تمارين',
      'no_scans': 'لم يتم العثور على فحوصات إن بودي', 'weight_trend': 'تطور الوزن', 'new_scan': 'فحص جديد',
      'no_diet': 'لم يتم العثور على خطة حمية', 'daily_totals': 'إجمالي اليوم', 'edit_goals': 'تعديل الأهداف',
      'new_assessment': 'تقييم جديد', 'items': 'الأصناف', 'add_item': 'إضافة صنف',
      'save_changes': 'حفظ التغييرات', 'edit_exercise': 'تعديل التمرين', 'save_exercise': 'حفظ التمرين',
      'save_assessment': 'حفظ التقييم', 'no_assessments': 'لم يتم العثور على تقييمات',
      'no_sessions_found': 'لم يتم العثور على جلسات',
      'leave_requests': 'طلبات الإجازة', 'request_leave': 'طلب إجازة',
      'booking_requests': 'طلبات الحجز', 'request_details': 'تفاصيل الطلب',
      'no_requests': 'لا توجد طلبات معلقة',
      'phone_field': 'الهاتف', 'email_field': 'البريد الإلكتروني', 'address_field': 'العنوان', 'member_id': 'رقم العضو',
      'status': 'الحالة', 'sessions_left': 'الجلسات المتبقية', 'gym_floor': 'صالة الجيم',
      'open_btn': 'فتح', 'pt_subs': 'اشتراكات PT', 'active_members': 'الأعضاء النشطين',
      'requests': 'الطلبات', 'soon': 'قريباً', 'no_sessions_today': 'لا توجد جلسات اليوم',
      'chats': 'المحادثات', 'no_conversations': 'لا توجد محادثات بعد', 'active_now': 'نشط الآن',
      'start_conversation': 'ابدأ المحادثة', 'recording': 'جاري التسجيل...',
      'reply_great_work': 'عمل رائع اليوم!', 'reply_diet_plan': 'تحقق من خطة نظامك الغذائي الجديد',
      'reply_check_in': 'لا تنسَ تسجيل الحضور', 'reply_push_harder': 'لنضغط بقوة أكبر!',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
