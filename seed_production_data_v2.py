import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate("true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

COACH_UID = "w6P5VAvYZIdFFck0Xp5BOXznpfo1" # From logs and discovery
MEMBER_PERS_ID = "50392"

def seed_production():
    print("--- Production Data Alignment ---")

    # 1. Update Coach Role and Profile
    coach_ref = db.collection('Coaches').document(COACH_UID)
    coach_ref.set({
        'uid': COACH_UID,
        'email': 'omar.mizo@truefit.com',
        'name': 'OMAR MIZO',
        'role': 'head_coach',
        'specialty': 'Head Coach / Performance Specialist',
        'is_active': True,
        'updated_at': firestore.SERVER_TIMESTAMP
    }, merge=True)
    print(f"Coach {COACH_UID} updated to head_coach.")

    # 2. Update Member Profile (Link to Coach)
    # Using 'Users' as the primary app collection if it exists, otherwise creating it
    member_ref = db.collection('Users').document(MEMBER_PERS_ID)
    member_ref.set({
        'pers_ID': MEMBER_PERS_ID,
        'member_name': 'Abdelrahman Zakaria',
        'phone': '01032592970',
        'assigned_coach_id': COACH_UID,
        'plan': 'ELITE PT',
        'progress': 85,
        'initials': 'AZ',
        'updated_at': firestore.SERVER_TIMESTAMP
    }, merge=True)
    print(f"Member {MEMBER_PERS_ID} linked to coach.")

    # 3. Deterministic Chat Room (coachUID_memberID)
    chat_id = f"{COACH_UID}_{MEMBER_PERS_ID}"
    chat_ref = db.collection('Chat_Rooms').document(chat_id)
    chat_ref.set({
        'id': chat_id,
        'participants': [COACH_UID, MEMBER_PERS_ID],
        'coach_id': COACH_UID,
        'member_id': MEMBER_PERS_ID,
        'last_message': 'Welcome to True Fit Coaching portal.',
        'last_message_time': firestore.SERVER_TIMESTAMP,
        'is_active': True
    }, merge=True)
    print(f"Chat room {chat_id} initialized.")

    # 4. User PT Wallet
    wallet_ref = db.collection('User_PT_Wallet').document(MEMBER_PERS_ID)
    wallet_ref.set({
        'pers_ID': MEMBER_PERS_ID,
        'member_id': MEMBER_PERS_ID,
        'assigned_coach_id': COACH_UID,
        'sessions_left': 12,
        'total': 24,
        'member_name': 'Abdelrahman Zakaria'
    }, merge=True)
    print(f"PT Wallet for {MEMBER_PERS_ID} synced.")

    print("--- Alignment Complete ---")

if __name__ == "__main__":
    seed_production()
