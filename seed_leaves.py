import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

# Initialize Firebase Admin SDK
cred = credentials.Certificate('C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# Sample data for leaves
leaves = [
    {
        "coachId": "w6P5VAvYZIdFFck0Xp5BOXznpfo1",
        "coachName": "Omar Mizo",
        "coachGender": "male",
        "leaveDate": (datetime.now() + timedelta(days=5)).strftime("%Y-%m-%d"),
        "createdAt": datetime.now(),
        "reason": "Family emergency and personal matters.",
        "status": "pending",
        "approvedBy": None,
        "leaveType": "Day Off"
    },
    {
        "coachId": "w6P5VAvYZIdFFck0Xp5BOXznpfo1",
        "coachName": "Omar Mizo",
        "coachGender": "male",
        "leaveDate": (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d"),
        "createdAt": datetime.now() - timedelta(days=3),
        "reason": "Routine medical checkup.",
        "status": "approved",
        "approvedBy": "head_coach_id_sample",
        "leaveType": "Day Off"
    },
    {
        "coachId": "S3n8W1qYv0R2T9m5B6V4", # Sample ID for another coach
        "coachName": "Ahmed Hassan",
        "coachGender": "male",
        "leaveDate": (datetime.now() + timedelta(days=7)).strftime("%Y-%m-%d"),
        "createdAt": datetime.now(),
        "reason": "Personal travel plans.",
        "status": "pending",
        "approvedBy": None,
        "leaveType": "Day Off"
    }
]

def seed_leaves():
    print("Seeding coach leaves...")
    col_ref = db.collection('Coach_Leaves')

    for l in leaves:
        col_ref.add(l)
        print(f"Added leave for {l['coachName']} on {l['leaveDate']} ({l['status']})")

if __name__ == "__main__":
    seed_leaves()
