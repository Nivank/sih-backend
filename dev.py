#!/usr/bin/env python3
"""
Development Management Script for Bharat Transliteration API

Provides common development operations:
- Start/stop backend server
- Run frontend
- Run tests
- Database management
- User management
"""

import subprocess
import sys
import os
import signal
import time
from pathlib import Path


class DevManager:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.frontend_dir = self.project_root / "frontend"
        self.backend_proc = None
        self.frontend_proc = None
    
    def activate_venv(self):
        """Ensure virtual environment is activated."""
        venv_path = self.project_root / ".venv"
        if not venv_path.exists():
            print("⚠️  Virtual environment not found. Creating...")
            subprocess.run([sys.executable, "-m", "venv", ".venv"], cwd=self.project_root)
        
        # Check if we're in virtual environment
        if not hasattr(sys, 'real_prefix') and not (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
            print("🔧 Please activate virtual environment first:")
            print(f"   .venv\\Scripts\\Activate.ps1")
            return False
        return True
    
    def install_backend_deps(self):
        """Install backend dependencies."""
        print("📦 Installing backend dependencies...")
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], 
                      cwd=self.project_root)
    
    def install_frontend_deps(self):
        """Install frontend dependencies."""
        print("📦 Installing frontend dependencies...")
        subprocess.run(["flutter", "pub", "get"], cwd=self.frontend_dir)
    
    def start_backend(self, port=8000):
        """Start the backend server."""
        if not self.activate_venv():
            return False
        
        print(f"🚀 Starting backend server on port {port}...")
        try:
            self.backend_proc = subprocess.Popen(
                [sys.executable, "-m", "uvicorn", "main:app", "--reload", "--port", str(port)],
                cwd=self.project_root
            )
            print(f"✅ Backend started (PID: {self.backend_proc.pid})")
            print(f"   API Docs: http://localhost:{port}/docs")
            return True
        except Exception as e:
            print(f"❌ Failed to start backend: {e}")
            return False
    
    def start_frontend(self, platform="chrome", port=5174):
        """Start the frontend application."""
        print(f"🚀 Starting frontend on {platform}...")
        try:
            cmd = ["flutter", "run", "-d", platform]
            if platform == "chrome":
                cmd.extend(["--web-port", str(port)])
            
            self.frontend_proc = subprocess.Popen(cmd, cwd=self.frontend_dir)
            print(f"✅ Frontend started (PID: {self.frontend_proc.pid})")
            return True
        except Exception as e:
            print(f"❌ Failed to start frontend: {e}")
            return False
    
    def run_tests(self):
        """Run the test suite."""
        if not self.activate_venv():
            return False
        
        print("🧪 Running tests...")
        try:
            result = subprocess.run([sys.executable, "test_auth_flow.py"], 
                                  cwd=self.project_root)
            return result.returncode == 0
        except Exception as e:
            print(f"❌ Test execution failed: {e}")
            return False
    
    def create_user(self, email, password):
        """Create a new user."""
        if not self.activate_venv():
            return False
        
        print(f"👥 Creating user: {email}")
        try:
            result = subprocess.run(
                [sys.executable, "create_users.py", "create", email, password],
                cwd=self.project_root
            )
            return result.returncode == 0
        except Exception as e:
            print(f"❌ User creation failed: {e}")
            return False
    
    def list_users(self):
        """List all users."""
        if not self.activate_venv():
            return False
        
        try:
            subprocess.run([sys.executable, "create_users.py", "list"], 
                          cwd=self.project_root)
            return True
        except Exception as e:
            print(f"❌ Failed to list users: {e}")
            return False
    
    def setup_project(self):
        """Complete project setup."""
        print("🔧 Setting up Bharat Transliteration API project...")
        
        # Check prerequisites
        try:
            subprocess.run(["python", "--version"], check=True, capture_output=True)
        except subprocess.CalledProcessError:
            print("❌ Python not found. Please install Python 3.11+")
            return False
        
        try:
            subprocess.run(["flutter", "--version"], check=True, capture_output=True)
        except subprocess.CalledProcessError:
            print("⚠️  Flutter not found. Frontend won't be available.")
        
        # Install dependencies
        if self.activate_venv():
            self.install_backend_deps()
        
        if self.frontend_dir.exists():
            self.install_frontend_deps()
        
        # Create default users
        print("👥 Creating default users...")
        subprocess.run([sys.executable, "create_users.py", "defaults"], 
                      cwd=self.project_root)
        
        print("✅ Setup complete!")
        print("\\n🚀 Quick start:")
        print("   python dev.py backend    # Start backend server")
        print("   python dev.py frontend   # Start frontend app")
        print("   python dev.py test       # Run tests")
        return True
    
    def stop_services(self):
        """Stop running services."""
        print("🛑 Stopping services...")
        
        if self.backend_proc:
            self.backend_proc.terminate()
            print("✅ Backend stopped")
        
        if self.frontend_proc:
            self.frontend_proc.terminate()
            print("✅ Frontend stopped")
    
    def show_status(self):
        """Show project status."""
        print("📈 Project Status:")
        print("=" * 40)
        
        # Check virtual environment
        venv_path = self.project_root / ".venv"
        print(f"Virtual Env: {'✅' if venv_path.exists() else '❌'} {venv_path}")
        
        # Check dependencies
        try:
            import fastapi
            print(f"Backend Deps: ✅ FastAPI {fastapi.__version__}")
        except ImportError:
            print("Backend Deps: ❌ Not installed")
        
        # Check database
        db_path = self.project_root / "app.db"
        print(f"Database: {'✅' if db_path.exists() else '❌'} {db_path}")
        
        # Check frontend
        pubspec_path = self.frontend_dir / "pubspec.yaml"
        print(f"Frontend: {'✅' if pubspec_path.exists() else '❌'} Flutter app")
    
    def show_help(self):
        """Show help information."""
        print("""
📄 Bharat Transliteration API - Development Manager

Usage: python dev.py <command> [options]

Commands:
  setup                     Complete project setup
  backend [port]           Start backend server (default: 8000)
  frontend [platform]      Start frontend app (default: chrome)
  both                     Start both backend and frontend
  test                     Run test suite
  user <email> <password>  Create new user
  users                    List all users
  status                   Show project status
  stop                     Stop all services
  help                     Show this help

Examples:
  python dev.py setup
  python dev.py backend 9000
  python dev.py frontend android
  python dev.py both
  python dev.py user test@example.com password123
  python dev.py test
""")


def main():
    manager = DevManager()
    
    if len(sys.argv) < 2:
        manager.show_help()
        return
    
    command = sys.argv[1].lower()
    
    try:
        if command == "setup":
            manager.setup_project()
        
        elif command == "backend":
            port = int(sys.argv[2]) if len(sys.argv) > 2 else 8000
            manager.start_backend(port)
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                manager.stop_services()
        
        elif command == "frontend":
            platform = sys.argv[2] if len(sys.argv) > 2 else "chrome"
            manager.start_frontend(platform)
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                manager.stop_services()
        
        elif command == "both":
            manager.start_backend()
            time.sleep(2)  # Wait for backend to start
            manager.start_frontend()
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                manager.stop_services()
        
        elif command == "test":
            manager.run_tests()
        
        elif command == "user":
            if len(sys.argv) != 4:
                print("❌ Usage: python dev.py user <email> <password>")
                return
            manager.create_user(sys.argv[2], sys.argv[3])
        
        elif command == "users":
            manager.list_users()
        
        elif command == "status":
            manager.show_status()
        
        elif command == "stop":
            manager.stop_services()
        
        elif command == "help":
            manager.show_help()
        
        else:
            print(f"❌ Unknown command: {command}")
            manager.show_help()
    
    except KeyboardInterrupt:
        print("\\n🛑 Interrupted by user")
        manager.stop_services()
    except Exception as e:
        print(f"❌ Error: {e}")
        manager.stop_services()


if __name__ == "__main__":
    main()