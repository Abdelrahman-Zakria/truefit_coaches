import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate("true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

def discover():
    print("--- Firestore Discovery ---")

    # List all root collections
    collections = db.collections()
    for coll in collections:
        print(f"\nCollection: {coll.id}")
        # Sample first 2 documents
        docs = coll.limit(2).stream()
        for doc in docs:
            print(f"  Document ID: {doc.id}")
            print(f"  Data: {doc.to_dict()}")

    # Specific check for our target coach
    print("\n--- Targeted Check: Coach Omar ---")
    coach_query = db.collection('Coaches').where('email', '==', 'omar.mizo@truefit.com').stream()
    for coach in coach_query:
        print(f"Found Coach Document: {coach.id}")
        print(f"Data: {coach.to_dict()}")

    # Specific check for our target member
    print("\n--- Targeted Check: Member 50392 ---")
    member_query = db.collection('Users').where('pers_ID', '==', '50392').stream()
    for member in member_query:
        print(f"Found Member Document: {member.id}")
        print(f"Data: {member.to_dict()}")

if __name__ == "__main__":
    discover()
