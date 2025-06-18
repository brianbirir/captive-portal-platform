#!/bin/bash
set -e

# Create migrations directory if it doesn't exist
if [ ! -d "/app/migrations" ]; then
    echo "Initializing migrations directory..."
    mkdir -p /app/migrations
    flask db init
fi

# Apply any pending migrations
echo "Applying database migrations..."
flask db upgrade

# Create default admin user if not exists
echo "Checking for default admin user..."
python -c "
from app import create_app, db
from app.models import User
app = create_app()
with app.app_context():
    if User.query.filter_by(email='admin@example.com').first() is None:
        admin = User(email='admin@example.com')
        admin.set_password('password')
        db.session.add(admin)
        db.session.commit()
        print('Default admin user created')
    else:
        print('Default admin user already exists')
"

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn -c gunicorn_config.py wsgi:app
