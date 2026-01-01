import os
import django
import sys

# Setup Django environment
sys.path.append('c:/Users/HP/Desktop/mobile_projet_clone/medconnect-backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_medconnect.settings')
django.setup()

from app.models import User, Conversation, Message
from app.serializers import ConversationSerializer
from rest_framework.request import Request
from rest_framework.test import APIRequestFactory

def debug():
    print("Debugging Messaging Module...")
    
    # 1. Check Users
    try:
        users = User.objects.all()
        print(f"Total Users: {users.count()}")
        for u in users[:5]:
            print(f"User: {u.username}, Role: {getattr(u, 'role', 'N/A')}, is_patient: {getattr(u, 'is_patient', 'MD missing')}")
    except Exception as e:
        print(f"Error checking users: {e}")

    # 2. Check Conversations
    try:
        conversations = Conversation.objects.all()
        print(f"Total Conversations: {conversations.count()}")
        for c in conversations:
            print(f"Conversation: {c.id}, Patient: {c.patient.username}, Doctor: {c.doctor.username}")
            
            # Test Serializer
            # Need a mock request for context
            factory = APIRequestFactory()
            request = factory.get('/')
            request.user = c.patient # simulate patient view
            
            context = {'request': request}
            try:
                serializer = ConversationSerializer(c, context=context)
                print(f"Serialized Data: {serializer.data.keys()}") # Just check keys to avoid massive output
            except Exception as se:
                print(f"Serializer Error for convo {c.id}: {se}")
                import traceback
                traceback.print_exc()

    except Exception as e:
        print(f"Error checking conversations: {e}")

if __name__ == '__main__':
    debug()
