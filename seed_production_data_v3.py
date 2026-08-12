import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate("true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

COACH_UID = "w6P5VAvYZIdFFck0Xp5BOXznpfo1"
MEMBER_PERS_ID = "50392"

def seed_production():
    print("--- Production Data Alignment (Gym_Coaches Schema) ---")

    # 1. Update Coach Role and Profile in Gym_Coaches
    coach_ref = db.collection('Gym_Coaches').document(COACH_UID)
    coach_ref.set({
        'uid': COACH_UID,
        'email': 'omar.mizo@truefit.com',
        'name': 'OMAR MIZO',
        'role': 'head_coach',
        'rating': 5.0,
        'bio': {
            'ar': 'مدرب رئيسي متخصص في الأداء الرياضي والقوة',
            'en': 'Head Coach / Performance Specialist'
        },
        'specialty': {
            'ar': 'تخصص الأداء الرياضي والقوة',
            'en': 'Performance Specialist / Strength'
        }
    }, merge=True)
    print(f"Coach {COACH_UID} updated in Gym_Coaches with head_coach role.")

    # 2. Update Member Profile in Gym_pers (based on discovery)
    member_ref = db.collection('Gym_pers').document(MEMBER_PERS_ID)
    member_ref.set({
        'assigned_coach_id': COACH_UID,
        'pers_ID': 50392,
    }, merge=True)
    print(f"Member {MEMBER_PERS_ID} in Gym_pers linked to coach {COACH_UID}.")

    # 3. Deterministic Chat Room in Gym_Conversations
    # Based on discovery, the ID format seems to be memberID_coachUID or similar
    chat_id = f"{MEMBER_PERS_ID}_{COACH_UID}"
    chat_ref = db.collection('Gym_Conversations').document(chat_id)
    chat_ref.set({
        'id': chat_id,
        'participants': [int(MEMBER_PERS_ID), COACH_UID],
        'coach_id': COACH_UID,
        'member_id': int(MEMBER_PERS_ID),
        'coach_name': 'OMAR MIZO',
        'is_online': True,
        'unread_count': 0,
        'last_message': 'System initialized. High-performance coaching ready.',
        'updated_at': firestore.SERVER_TIMESTAMP
    }, merge=True)
    print(f"Conversation {chat_id} initialized in Gym_Conversations.")

    print("--- Alignment Complete ---")

if __name__ == "__main__":
    seed_production()
