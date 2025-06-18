from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash

from .models import User
from . import db

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

# Create a default admin user if none exists
def create_default_user():
    if User.query.filter_by(email='admin@example.com').first() is None:
        default_user = User(email='admin@example.com')
        default_user.set_password('password')
        db.session.add(default_user)
        db.session.commit()

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """User login page."""
    if current_user.is_authenticated:
        return redirect(url_for('main.home'))
    
    # Ensure default user exists
    create_default_user()
    
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = User.query.filter_by(email=email).first()
        
        # Check if user exists and password is correct
        if user and user.check_password(password):
            login_user(user)
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
