import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

docs = db.collection('User_PT_Wallet').where('pers_ID', '==', 50392).stream()
for doc in docs:
    print(f"Doc ID: {doc.id}, Data: {doc.to_dict()}")

docs_str = db.collection('User_PT_Wallet').where('pers_ID', '==', "50392").stream()
for doc in docs_str:
    print(f"Doc ID (Str): {doc.id}, Data: {doc.to_dict()}")
