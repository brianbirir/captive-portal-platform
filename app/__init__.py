from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
login_manager.login_view = 'auth.login'  # Specify the login view
login_manager.login_message = "You must be logged in to access this page!"
login_manager.login_message_category = "error"

def create_app():
    """Initialize the core application."""
    app = Flask(__name__, instance_relative_config=False)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key')
    
    # Configure SQLite database
    database_url = os.environ.get('DATABASE_URL', 'sqlite:///captive_portal.db')
    if database_url.startswith('sqlite:///') and not database_url.startswith('sqlite:////'):
        # If it's a relative path, make it absolute
        basedir = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
        database_url = 'sqlite:///' + os.path.join(basedir, database_url.replace('sqlite:///', ''))
    
    app.config['SQLALCHEMY_DATABASE_URI'] = database_url
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # Initialize plugins
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    
    with app.app_context():
        # Include routes
        from . import routes
        from . import auth
        from . import models
        
        # Create tables if they don't exist
        db.create_all()
        
        # Import CLI commands
        from . import cli
        
        # Register blueprints
        app.register_blueprint(routes.main_bp)
        app.register_blueprint(auth.auth_bp)
        app.register_blueprint(cli.cli_bp)
        
        return app
