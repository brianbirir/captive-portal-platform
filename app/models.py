from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from app import login_manager

class User(UserMixin):
    """User account model."""
    
    def __init__(self, id, email):
        self.id = id
        self.email = email
        self.password_hash = None
    
    def set_password(self, password):
        """Create hashed password."""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check hashed password."""
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    """Check if user is logged-in upon page load."""
    # In a real application, this would query your database
    if int(user_id) == 1:  # Mock user has ID=1
        mock_user = User(id=1, email='user@example.com')
        return mock_user
    return None
