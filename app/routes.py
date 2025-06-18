from flask import Blueprint, render_template, redirect, url_for, jsonify
from flask_login import login_required
import datetime

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


@main_bp.route('/health')
def health_check():
    """Health check endpoint for Docker container monitoring."""
    health_data = {
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'service': 'captive-portal-platform'
    }
    return jsonify(health_data)
