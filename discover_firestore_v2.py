import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate("true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

def discover_member():
    print("--- Exhaustive Member Search: 50392 ---")

    # Check common collection names
    collections = ['Users', 'Gym_pers', 'Members', 'Profiles']

    for coll_name in collections:
        print(f"\nChecking collection: {coll_name}")
        # Check by Document ID
        doc = db.collection(coll_name).document('50392').get()
        if doc.exists:
            print(f"  Found as Document ID in {coll_name}: {doc.to_dict()}")

        # Check by field pers_ID
        docs = db.collection(coll_name).where('pers_ID', '==', '50392').stream()
        for d in docs:
            print(f"  Found by pers_ID field in {coll_name} (ID: {d.id}): {d.to_dict()}")

        # Check by numeric pers_ID if applicable
        docs = db.collection(coll_name).where('pers_ID', '==', 50392).stream()
        for d in docs:
            print(f"  Found by numeric pers_ID field in {coll_name} (ID: {d.id}): {d.to_dict()}")

if __name__ == "__main__":
    discover_member()
