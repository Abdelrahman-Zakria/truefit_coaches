import firebase_admin
from firebase_admin import credentials, firestore, auth
import json
import os

# IMPORTANT: This script requires a service account key to perform 'auth' operations.
# Please ensure you have a 'firebase_credentials.json' file in the root directory.

def seed_data():
    try:
        # Initialize Firebase Admin
        cred_path = 'true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json'
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        else:
            print("Error: 'firebase_credentials.json' not found. Please provide a service account key.")
            return

        db = firestore.client()
        print("Firebase initialized successfully.")

        # 1. Handle Coaches & Auth
        # Data from screenshot + request
        coaches_data = [
            {
                "id": "coach1", # Internal ID for mapping
                "name": "Omar Mizo",
                "email": "omar.mizo@truefit.com",
                "role": "head_coach",
                "rating": 5,
                "bio": {
                    "ar": "مدرب معتمد بخبرة 10 سنوات",
                    "en": "Certified trainer with 10 years experience."
                },
                "specialty": {
                    "ar": "كمال الأجسام والقوة",
                    "en": "Bodybuilding & Strength"
                }
            },
            {
                "id": "coach2",
                "name": "Ahmed Hassan",
                "email": "ahmed.hassan@truefit.com",
                "role": "coach",
                "rating": 4.8,
                "bio": {
                    "ar": "مدرب كمال أجسام",
                    "en": "Bodybuilding Coach"
                },
                "specialty": {
                    "ar": "تخسيس ولياقة",
                    "en": "Weight Loss & Fitness"
                }
            }
        ]

        head_coach_uid = ""

        for coach in coaches_data:
            # Create Firebase Auth User
            try:
                user = auth.get_user_by_email(coach["email"])
                print(f"User {coach['email']} already exists.")
                uid = user.uid
            except auth.UserNotFoundError:
                user = auth.create_user(
                    email=coach["email"],
                    password="truefit@123",
                    display_name=coach["name"]
                )
                print(f"Created user {coach['email']} with UID: {user.uid}")
                uid = user.uid

            if coach["role"] == "head_coach":
                head_coach_uid = uid

            # Update/Create Coach Document in Gym_Coaches
            coach_doc = {
                "name": coach["name"],
                "email": coach["email"],
                "role": coach["role"],
                "rating": coach["rating"],
                "bio": coach["bio"],
                "specialty": coach["specialty"],
                "uid": uid
            }
            db.collection("Gym_Coaches").document(uid).set(coach_doc)
            print(f"Seeded coach {coach['name']} in Firestore.")

        # 2. Seed Member 50392 data
        member_id = 50392

        # Ensure member exists in a simplified user profile collection if needed
        # But primarily User_PT_Wallet to show up in the app
        member_wallet_doc = {
            "pers_ID": member_id,
            "member_name": "Omar Ali", # Example name
            "coach_id": head_coach_uid,
            "sessions_left": 10,
            "total": 12,
            "assigned_coach_id": head_coach_uid # Recommended field from gap analysis
        }
        db.collection("User_PT_Wallet").document(f"{member_id}_{head_coach_uid}").set(member_wallet_doc)
        print(f"Seeded wallet for member {member_id} assigned to head coach.")

        # 3. Seed Missing Collections Data for the App

        # Shifts for Head Coach
        days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for day in days:
            db.collection("Coaches_Shifts").add({
                "coach_id": head_coach_uid,
                "day": day,
                "start_time": "08:00",
                "end_time": "16:00",
                "is_off": day == "Fri"
            })
        print("Seeded weekly shifts for head coach.")

        # Progress (InBody) for Member 50392
        db.collection("Gym_Progress_InBody").add({
            "member_id": member_id,
            "date": "2025-07-15",
            "weight": "80.5",
            "body_fat_pct": "18.2",
            "muscle_mass": "38.5",
            "bmi": "24.1",
            "bmi_status": "Normal",
            "weight_change": "-1.5",
            "body_fat_change": "-0.5",
            "muscle_mass_change": "+0.4",
            "total_weight_lost": "5.0",
            "total_muscle_gain": "2.0",
            "total_body_fat_change": "-3.0"
        })
        print("Seeded InBody progress for member 50392.")

        # Workout for Member 50392
        db.collection("Gym_Member_Workouts").add({
            "member_id": member_id,
            "coach_id": head_coach_uid,
            "exercises": [
                {"name": "Bench Press", "sets": 4, "reps": 10, "weight": 80.0},
                {"name": "Squat", "sets": 4, "reps": 8, "weight": 100.0},
                {"name": "Deadlift", "sets": 3, "reps": 5, "weight": 140.0}
            ]
        })
        print("Seeded workout for member 50392.")

        # Diet Plan for Member 50392
        db.collection("Gym_Diet_Plans").document(str(member_id)).set({
            "total_calories": "2500",
            "water_goal": "3.5",
            "current_water": 1.5,
            "protein_goal": "180g",
            "carbs_goal": "250g",
            "fats_goal": "70g",
            "meals": [
                {
                    "id": "m1",
                    "time": "08:00 AM",
                    "title": "Breakfast",
                    "items": ["Oatmeal", "Eggs", "Banana"],
                    "calories": 600,
                    "protein": 30,
                    "carbs": 70,
                    "fats": 15
                },
                {
                    "id": "m2",
                    "time": "01:00 PM",
                    "title": "Lunch",
                    "items": ["Chicken Breast", "Rice", "Broccoli"],
                    "calories": 800,
                    "protein": 50,
                    "carbs": 90,
                    "fats": 10
                }
            ]
        })
        print("Seeded diet plan for member 50392.")

        print("\nSUMMARY:")
        print(f"Head Coach Login: omar.mizo@truefit.com / truefit@123")
        print(f"Coach Login: ahmed.hassan@truefit.com / truefit@123")
        print(f"Target Member: 50392")
        print("Seeding completed successfully.")

    except Exception as e:
        print(f"Error seeding data: {e}")

if __name__ == "__main__":
    seed_data()
