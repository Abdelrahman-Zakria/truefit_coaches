import firebase_admin
from firebase_admin import credentials, auth, firestore

# Initialize Firebase
cred = credentials.Certificate("C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

DEFAULT_PASSWORD = "truefit@123"

# New Staff Data
NEW_COACHES = [
    # 4 Male Coaches
    {"email": "m1@truefit.com", "name": "Male Coach 1", "sex": "male", "role": "coach", "salary": 25000},
    {"email": "m2@truefit.com", "name": "Male Coach 2", "sex": "male", "role": "coach", "salary": 26000},
    {"email": "m3@truefit.com", "name": "Male Coach 3", "sex": "male", "role": "coach", "salary": 27000},
    {"email": "m4@truefit.com", "name": "Male Coach 4", "sex": "male", "role": "coach", "salary": 28000},
    # 5 Female Coaches (1 Head Coach)
    {"email": "f1_head@truefit.com", "name": "Female Head Coach", "sex": "female", "role": "head_coach", "salary": 45000},
    {"email": "f2@truefit.com", "name": "Female Coach 2", "sex": "female", "role": "coach", "salary": 24000},
    {"email": "f3@truefit.com", "name": "Female Coach 3", "sex": "female", "role": "coach", "salary": 25000},
    {"email": "f4@truefit.com", "name": "Female Coach 4", "sex": "female", "role": "coach", "salary": 26000},
    {"email": "f5@truefit.com", "name": "Female Coach 5", "sex": "female", "role": "coach", "salary": 27000},
]

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

# Default male schedule pattern
MALE_PATTERN = {
    "Sat": {"start": "9:00 AM", "end": "4:00 AM", "isOff": False},
    "Sun": {"start": "3:00 PM", "end": "4:00 AM", "isOff": False},
    "Mon": {"start": "9:00 AM", "end": "4:00 AM", "isOff": False},
    "Tue": {"start": "3:00 PM", "end": "4:00 AM", "isOff": False},
    "Wed": {"start": "9:00 AM", "end": "4:00 AM", "isOff": False},
    "Thu": {"start": "3:00 PM", "end": "4:00 AM", "isOff": False},
    "Fri": {"start": "5:00 PM", "end": "4:00 AM", "isOff": False},
}

def seed():
    print("Starting Staff Expansion Seeding...")

    # Handle Existing Coaches too
    existing_coaches = db.collection('Gym_Coaches').stream()
    all_target_coaches = []
    for doc in existing_coaches:
        c = doc.to_dict()
        c['uid'] = doc.id
        all_target_coaches.append(c)

    # Add New Coaches
    for coach in NEW_COACHES:
        try:
            user = auth.get_user_by_email(coach['email'])
            uid = user.uid
            print(f"User {coach['email']} already exists.")
        except auth.UserNotFoundError:
            user = auth.create_user(
                email=coach['email'],
                password=DEFAULT_PASSWORD,
                display_name=coach['name']
            )
            uid = user.uid
            print(f"Created Auth User: {coach['name']}")

        # Seed Gym_Coaches
        db.collection('Gym_Coaches').document(uid).set({
            "uid": uid,
            "name": coach['name'],
            "email": coach['email'],
            "role": coach['role'],
            "sex": coach['sex'],
            "baseSalary": coach['salary'],
            "specialty": {"en": "Personal Training", "ar": "تدريب شخصي"},
            "rating": 5.0
        })
        coach['uid'] = uid
        all_target_coaches.append(coach)

    # Seed Coaches_Shifts freshly
    print("Seeding Coaches_Shifts...")
    for idx, coach in enumerate(all_target_coaches):
        # Assign a different day off for each coach to ensure coverage
        day_off_idx = idx % 7
        day_off = DAYS[day_off_idx]

        for day in DAYS:
            doc_id = f"{coach['uid']}_{day}"
            pattern = MALE_PATTERN.get(day, {"start": "9:00 AM", "end": "5:00 PM", "isOff": False})

            is_off = (day == day_off)

            db.collection('Coaches_Shifts').document(doc_id).set({
                "coachId": coach['uid'],
                "day": day,
                "startTime": pattern['start'] if not is_off else "",
                "endTime": pattern['end'] if not is_off else "",
                "isOff": is_off
            })

    print("Seeding Complete!")

if __name__ == "__main__":
    seed()
