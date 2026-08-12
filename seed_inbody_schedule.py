import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random

# Initialize Firebase
cred = credentials.Certificate("C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

COACH_ID = "w6P5VAvYZIdFFck0Xp5BOXznpfo1"
COACH_NAME = "OMAR MIZO"

def seed_inbody_schedule():
    print("Seeding InBody Schedule...")

    # Clear existing schedule (optional)
    # docs = db.collection('InBody_Schedule').stream()
    # for doc in docs:
    #     doc.reference.delete()

    today = datetime.now()

    slots = []

    # Generate 5 upcoming slots
    for i in range(5):
        date = today + timedelta(days=i)
        date_str = date.strftime('%Y-%m-%d')

        # Morning slot
        slots.append({
            "date": date_str,
            "time": "10:00 AM",
            "supervisorId": COACH_ID,
            "supervisorName": COACH_NAME,
            "memberName": None
        })

        # Evening slot (assigned to a different coach for variety)
        slots.append({
            "date": date_str,
            "time": "06:00 PM",
            "supervisorId": "dummy_coach_id_1",
            "supervisorName": "AHMED KHALED",
            "memberName": "Youssef Ali" if i % 2 == 0 else None
        })

    for slot in slots:
        db.collection('InBody_Schedule').add(slot)
        print(f"Added slot for {slot['date']} at {slot['time']}")

    print("Seeding Complete!")

if __name__ == "__main__":
    seed_inbody_schedule()
