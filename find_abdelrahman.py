import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('C:/Users/tiger/StudioProjects/truefit_coaches/true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

docs = db.collection('Gym_pers').where('pers_NAME_EN', '==', 'Abdelrahman Zakaria').stream()
for doc in docs:
    print(f"Doc ID: {doc.id}, Data: {doc.to_dict()}")

docs_ar = db.collection('Gym_pers').where('pers_NAME_AR', '==', 'عبدالرحمن زكريا').stream()
for doc in docs_ar:
    print(f"Doc ID (AR): {doc.id}, Data: {doc.to_dict()}")
