import firebase_admin
from firebase_admin import credentials, firestore, auth
import datetime

# Initialize Firebase Admin
cred = credentials.Certificate("true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

COACH_EMAIL = "omar.mizo@truefit.com"
MEMBER_PHONE = "01032592970"
MEMBER_PERS_ID = "50392"

def seed_data():
    print("--- Starting Production Seeding ---")

    # 1. Ensure Coach Omar Mizo exists in Auth and Firestore
    try:
        coach_user = auth.get_user_by_email(COACH_EMAIL)
        coach_uid = coach_user.uid
        print(f"Found Coach UID: {coach_uid}")
    except auth.UserNotFoundError:
        # Note: In a real scenario, you'd create the user here,
        # but since we already have a UID from logs, we use it if possible.
        # w6P5VAvYZIdFFck0Xp5BOXznpfo1 was in the logs
        coach_uid = "w6P5VAvYZIdFFck0Xp5BOXznpfo1"
        print(f"Using known Coach UID from logs: {coach_uid}")

    coach_ref = db.collection('Coaches').document(coach_uid)
    coach_ref.set({
        'name': 'OMAR MIZO',
        'email': COACH_EMAIL,
        'role': 'head_coach',
        'specialty': 'Head Coach / Performance Specialist',
        'bio': 'High-performance coach leading the True Fit ecosystem.',
        'profile_image': '',
        'created_at': firestore.SERVER_TIMESTAMP,
        'is_active': True
    }, merge=True)

    # 2. Ensure Member exists in Firestore
    # We use phone number or pers_ID as a way to find/create
    member_uid = f"member_{MEMBER_PERS_ID}"
    member_ref = db.collection('Users').document(member_uid)
    member_ref.set({
        'member_name': 'Test Member',
        'phone': MEMBER_PHONE,
        'pers_ID': MEMBER_PERS_ID,
        'assigned_coach_id': coach_uid,
        'plan': 'ELITE PT',
        'progress': 75,
        'initials': 'TM',
        'age': 28,
        'weight': 80.5,
        'target_weight': 75.0,
        'created_at': firestore.SERVER_TIMESTAMP
    }, merge=True)
    print(f"Member initialized: {member_uid}")

    # 3. Initialize PT Wallet
    wallet_ref = db.collection('User_PT_Wallet').document(member_uid)
    wallet_ref.set({
        'member_id': member_uid,
        'sessions_left': 12,
        'total_sessions': 24,
        'expiry_date': datetime.datetime.now() + datetime.timedelta(days=90),
        'last_updated': firestore.SERVER_TIMESTAMP
    }, merge=True)

    # 4. Initialize Deterministic Chat Room
    # logic: sorted_uid1_uid2
    uids = [coach_uid, member_uid]
    uids.sort()
    chat_id = "_".join(uids)

    chat_ref = db.collection('Chat_Rooms').document(chat_id)
    chat_ref.set({
        'participants': [coach_uid, member_uid],
        'last_message': 'Welcome to True Fit coaching!',
        'last_message_time': firestore.SERVER_TIMESTAMP,
        'created_at': firestore.SERVER_TIMESTAMP,
        'coach_id': coach_uid,
        'member_id': member_uid
    }, merge=True)
    print(f"Chat room initialized: {chat_id}")

    # 5. Add a dummy session for today to show on dashboard
    today_str = datetime.datetime.now().strftime("%Y-%m-%d")
    booking_ref = db.collection('User_Bookings').add({
        'coach_id': coach_uid,
        'member_id': member_uid,
        'member_name': 'Test Member',
        'date': today_str,
        'time': '10:00 AM',
        'duration': 60,
        'status': 'confirmed',
        'type': 'PT'
    })
    print("Sample booking created for today.")

    print("--- Seeding Complete ---")

if __name__ == "__main__":
    seed_data()
