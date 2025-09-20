#!/usr/bin/env python3
"""
User Management Script for Bharat Transliteration API

This script provides functionality to:
- Create new users
- List existing users
- Delete users
- Reset passwords

Usage:
    python create_users.py create <email> <password>
    python create_users.py list
    python create_users.py delete <email>
    python create_users.py reset <email> <new_password>
"""

import sys
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from models import User, Base
from utils import hash_password


def setup_database():
    """Setup database connection and create tables if they don't exist."""
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./app.db")
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {},
        future=True,
    )
    
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    # Create session
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, future=True)
    return SessionLocal()


def create_user(email: str, password: str):
    """Create a new user."""
    db = setup_database()
    
    try:
        # Check if user already exists
        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            print(f"❌ User '{email}' already exists")
            return False
        
        # Create new user
        user = User(
            email=email,
            password_hash=hash_password(password)
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        
        print(f"✅ Created user: {email}")
        return True
        
    except Exception as e:
        print(f"❌ Error creating user: {e}")
        db.rollback()
        return False
    finally:
        db.close()


def list_users():
    """List all existing users."""
    db = setup_database()
    
    try:
        users = db.query(User).all()
        
        if not users:
            print("No users found.")
            return
        
        print(f"\n📋 Found {len(users)} user(s):\n")
        print(f"{'ID':<5} {'Email':<30} {'Created At':<20}")
        print("-" * 60)
        
        for user in users:
            print(f"{user.id:<5} {user.email:<30} {user.created_at.strftime('%Y-%m-%d %H:%M')}")
        
    except Exception as e:
        print(f"❌ Error listing users: {e}")
    finally:
        db.close()


def delete_user(email: str):
    """Delete a user."""
    db = setup_database()
    
    try:
        user = db.query(User).filter(User.email == email).first()
        
        if not user:
            print(f"❌ User '{email}' not found")
            return False
        
        # Confirm deletion
        confirm = input(f"Are you sure you want to delete user '{email}'? (y/N): ")
        if confirm.lower() != 'y':
            print("Deletion cancelled.")
            return False
        
        db.delete(user)
        db.commit()
        
        print(f"✅ Deleted user: {email}")
        return True
        
    except Exception as e:
        print(f"❌ Error deleting user: {e}")
        db.rollback()
        return False
    finally:
        db.close()


def reset_password(email: str, new_password: str):
    """Reset a user's password."""
    db = setup_database()
    
    try:
        user = db.query(User).filter(User.email == email).first()
        
        if not user:
            print(f"❌ User '{email}' not found")
            return False
        
        setattr(user, 'password_hash', hash_password(new_password))
        db.commit()
        
        print(f"✅ Password reset for user: {email}")
        return True
        
    except Exception as e:
        print(f"❌ Error resetting password: {e}")
        db.rollback()
        return False
    finally:
        db.close()


def create_default_users():
    """Create the default test users."""
    print("🔧 Creating default test users...")
    
    success1 = create_user("nivank", "nivank")
    success2 = create_user("nivank2", "nivank2")
    
    if success1 or success2:
        print("\n🎯 Default users ready for testing:")
        if success1 or db_has_user("nivank"):
            print("1. Email: nivank, Password: nivank")
        if success2 or db_has_user("nivank2"):
            print("2. Email: nivank2, Password: nivank2")


def db_has_user(email: str) -> bool:
    """Check if user exists in database."""
    db = setup_database()
    try:
        user = db.query(User).filter(User.email == email).first()
        return user is not None
    finally:
        db.close()


def show_help():
    """Display help information."""
    print("""\n📚 User Management Commands:

  create <email> <password>    Create a new user
  list                         List all users
  delete <email>               Delete a user
  reset <email> <password>     Reset user password
  defaults                     Create default test users
  help                         Show this help message

📝 Examples:
  python create_users.py create user@example.com mypassword
  python create_users.py list
  python create_users.py delete user@example.com
  python create_users.py reset user@example.com newpassword
  python create_users.py defaults
""")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("🔧 Bharat Transliteration API - User Management")
        show_help()
        return
    
    command = sys.argv[1].lower()
    
    if command == "create":
        if len(sys.argv) != 4:
            print("❌ Usage: python create_users.py create <email> <password>")
            return
        create_user(sys.argv[2], sys.argv[3])
    
    elif command == "list":
        list_users()
    
    elif command == "delete":
        if len(sys.argv) != 3:
            print("❌ Usage: python create_users.py delete <email>")
            return
        delete_user(sys.argv[2])
    
    elif command == "reset":
        if len(sys.argv) != 4:
            print("❌ Usage: python create_users.py reset <email> <new_password>")
            return
        reset_password(sys.argv[2], sys.argv[3])
    
    elif command == "defaults":
        create_default_users()
    
    elif command == "help":
        show_help()
    
    else:
        print(f"❌ Unknown command: {command}")
        show_help()


if __name__ == "__main__":
    main()