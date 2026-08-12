import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random

# Use the service account file
cred = credentials.Certificate('true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

coach_id = "w6P5VAvYZIdFFck0Xp5BOXznpfo1"
branch_id = "f6RdOgPflSRuW47UJFfUd"
branch_name = "branch2"

def seed_history():
    # Last 3 days history
    for i in range(1, 4):
        date = datetime.now() - timedelta(days=i)

        # Check In between 9-10 AM
        check_in = date.replace(hour=9, minute=random.randint(0, 59), second=0, microsecond=0)
        # Check Out between 4-5 PM
        check_out = date.replace(hour=16, minute=random.randint(0, 59), second=0, microsecond=0)

        data = {
            "coachId": coach_id,
            "branchId": branch_id,
            "locationName": branch_name,
            "timestampIn": check_in,
            "timestampOut": check_out,
            "status": "completed"
        }

        db.collection('attendance').add(data)

    print(f"Seeded 3 history records for {coach_id}")

if __name__ == "__main__":
    seed_history()
