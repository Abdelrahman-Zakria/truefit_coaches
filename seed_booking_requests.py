import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

cred = credentials.Certificate('C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

coach_id = "w6P5VAvYZIdFFck0Xp5BOXznpfo1" # Omar Mizo

requests = [
    {
        "coach_id": coach_id,
        "date": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d"),
        "pers_ID": 50392, # Abdelrahman Zakaria
        "status": "pending",
        "time": "7:00 PM",
        "timestamp": datetime.now(),
        "type": "pt"
    },
    {
        "coach_id": coach_id,
        "date": (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d"),
        "pers_ID": 50392,
        "status": "pending",
        "time": "10:00 AM",
        "timestamp": datetime.now(),
        "type": "pt"
    }
]

def seed_requests():
    print("Seeding booking requests...")
    for r in requests:
        db.collection('User_Bookings').add(r)
        print(f"Added pending request for member {r['pers_ID']} on {r['date']} at {r['time']}")

if __name__ == "__main__":
    seed_requests()
