from flask import Blueprint, render_template, redirect, url_for
from flask_login import login_required

# Create blueprint
main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    """Home page that redirects to login page."""
    return redirect(url_for('auth.login'))


@main_bp.route('/home')
@login_required
def home():
    """Home page that requires login."""
    return render_template('home.html')
