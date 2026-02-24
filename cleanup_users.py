import firebase_admin
from firebase_admin import credentials, auth, db
import sys

# The project ID from your screenshot
PROJECT_ID = "kitahack2026-f1f3e"

# SETUP
try:
    cred = credentials.Certificate('service-account.json')
    # Explicitly setting project_id in initialization
    firebase_admin.initialize_app(cred, {
        'projectId': PROJECT_ID,
        'databaseURL': f'https://{PROJECT_ID}-default-rtdb.asia-southeast1.firebasedatabase.app/'
    })
    print(f"✅ Firebase Admin Initialized for {PROJECT_ID}")
except Exception as e:
    print(f"❌ Failed to initialize Firebase Admin: {e}")
    sys.exit(1)

def cleanup_auth_and_db():
    print("🧹 Cleaning up Firebase Auth and Realtime Database...")
    
    # 1. Delete all users from Firebase Auth
    try:
        print("🗑️ Deleting all users from Firebase Auth...")
        # Iterating through all users
        page = auth.list_users()
        total_deleted = 0
        while True:
            uids = [user.uid for user in page.users]
            if uids:
                result = auth.delete_users(uids)
                total_deleted += result.success_count
                print(f"   - Deleted {result.success_count} users...")
            
            if page.has_next_page:
                page = page.get_next_page()
            else:
                break
        
        if total_deleted == 0:
            print("ℹ️ No users found in Firebase Auth.")
        else:
            print(f"✅ Total users deleted: {total_deleted}")
            
    except Exception as e:
        print(f"❌ Error deleting users from Auth: {e}")
        print("   (Note: You can also delete users manually in Firebase Console -> Authentication)")

    # 2. Clear 'users' node in Realtime Database
    try:
        print("🗑️ Clearing 'users' node in Realtime Database...")
        ref = db.reference('/users')
        ref.delete()
        print("✅ 'users' node cleared.")
    except Exception as e:
        print(f"❌ Error clearing RTDB: {e}")

    print("\n✨ Cleanup Process Finished!")

if __name__ == "__main__":
    cleanup_auth_and_db()
