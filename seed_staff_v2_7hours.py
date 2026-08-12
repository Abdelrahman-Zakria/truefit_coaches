import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

# Initialize Firebase
cred = credentials.Certificate("C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
SHIFT_DURATION = 7  # Hours
GYM_START_HOUR = 9  # 9 AM
GYM_END_HOUR = 28   # 4 AM (next day) - 9 + 19 hours = 4 AM

def format_time(hour):
    h = hour % 24
    am_pm = "AM" if h < 12 else "PM"
    display_h = h if h <= 12 else h - 12
    if display_h == 0: display_h = 12
    return f"{display_h}:00 {am_pm}"

def seed_7hour_shifts():
    print("Re-seeding shifts with strict 7-hour rule...")

    # Get all coaches
    coaches = db.collection('Gym_Coaches').stream()
    males = []
    females = []

    for doc in coaches:
        c = doc.to_dict()
        c['uid'] = doc.id
        if c.get('sex') == 'male':
            males.append(c)
        else:
            females.append(c)

    print(f"Found {len(males)} males and {len(females)} females.")

    # We want to cover 9 AM to 4 AM (19 hours total)
    # With 7 hour shifts, we need 3 shifts to cover the day (21 hours total, with some overlap)
    # Shift 1: 9 AM - 4 PM
    # Shift 2: 4 PM - 11 PM
    # Shift 3: 9 PM - 4 AM (Overlap with shift 2)

    SHIFTS_DEFINITION = [
        (9, 16),   # 9 AM - 4 PM
        (16, 23),  # 4 PM - 11 PM
        (21, 28)   # 9 PM - 4 AM
    ]

    def assign_team_shifts(team):
        for idx, coach in enumerate(team):
            day_off_idx = idx % 7
            day_off = DAYS[day_off_idx]

            # Rotate shifts per coach so they don't always have the same one
            # Using a simple rotation logic based on the coach index
            base_shift_idx = idx % 3

            for day_idx, day in enumerate(DAYS):
                doc_id = f"{coach['uid']}_{day}"
                is_off = (day == day_off)

                # Further rotate shift daily so one coach doesn't always work mornings
                shift_for_the_day_idx = (base_shift_idx + day_idx) % 3
                start_h, end_h = SHIFTS_DEFINITION[shift_for_the_day_idx]

                db.collection('Coaches_Shifts').document(doc_id).set({
                    "coachId": coach['uid'],
                    "day": day,
                    "startTime": format_time(start_h) if not is_off else "",
                    "endTime": format_time(end_h) if not is_off else "",
                    "isOff": is_off
                })
        print(f"Assigned shifts for team of {len(team)}.")

    print("Processing Male Team...")
    assign_team_shifts(males)

    print("Processing Female Team...")
    assign_team_shifts(females)

    print("Seeding Complete!")

if __name__ == "__main__":
    seed_7hour_shifts()
