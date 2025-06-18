from flask import Flask
from flask_login import LoginManager

# Initialize login manager
login_manager = LoginManager()
login_manager.login_view = 'auth.login'  # Specify the login view
login_manager.login_message = "You must be logged in to access this page!"
login_manager.login_message_category = "error"

def create_app():
    """Initialize the core application."""
    app = Flask(__name__, instance_relative_config=False)
    app.config['SECRET_KEY'] = 'your-secret-key'  # Change this to a random string in production
    
    # Initialize plugins
    login_manager.init_app(app)
    
    with app.app_context():
        # Include routes
        from . import routes
        from . import auth
        
        # Register blueprints
        app.register_blueprint(routes.main_bp)
        app.register_blueprint(auth.auth_bp)
        
        return app
