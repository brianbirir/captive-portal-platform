from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash

from .models import User

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

# Mock user for demonstration purposes
# In a real app, you would use a database
mock_user = User(id=1, email='user@example.com')
mock_user.set_password('password')

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """User login page."""
    if current_user.is_authenticated:
        return redirect(url_for('main.home'))
    
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        # Check if user exists and password is correct
        if email == mock_user.email and mock_user.check_password(password):
            login_user(mock_user)
            next_page = request.args.get('next')
            return redirect(next_page or url_for('main.home'))
        else:
            flash('Please check your email and password and try again.')
    
    return render_template('login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    """User logout route."""
    logout_user()
    return redirect(url_for('auth.login'))
