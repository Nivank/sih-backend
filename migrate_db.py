#!/usr/bin/env python3
"""
Database migration script to add photo support to notes table.
Run this to update existing database schema.
"""

import os
from sqlalchemy import create_engine, text
from db import DATABASE_URL

def migrate_database():
    """Add photo columns to notes table."""
    engine = create_engine(DATABASE_URL)
    
    print("🔄 Migrating database to add photo support...")
    
    with engine.connect() as conn:
        try:
            # Add photo columns to notes table
            conn.execute(text("ALTER TABLE notes ADD COLUMN photo_data BLOB"))
            print("✅ Added photo_data column")
        except Exception as e:
            if "duplicate column name" in str(e).lower():
                print("✅ photo_data column already exists")
            else:
                print(f"❌ Error adding photo_data: {e}")
        
        try:
            conn.execute(text("ALTER TABLE notes ADD COLUMN photo_filename VARCHAR(255)"))
            print("✅ Added photo_filename column")
        except Exception as e:
            if "duplicate column name" in str(e).lower():
                print("✅ photo_filename column already exists")
            else:
                print(f"❌ Error adding photo_filename: {e}")
        
        try:
            conn.execute(text("ALTER TABLE notes ADD COLUMN photo_content_type VARCHAR(100)"))
            print("✅ Added photo_content_type column")
        except Exception as e:
            if "duplicate column name" in str(e).lower():
                print("✅ photo_content_type column already exists")
            else:
                print(f"❌ Error adding photo_content_type: {e}")
        
        # Commit all changes
        conn.commit()
        
    print("✅ Database migration completed!")

if __name__ == "__main__":
    migrate_database()