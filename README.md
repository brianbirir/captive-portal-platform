# Captive Portal Platform

A Flask-based captive portal platform.

## Features

- User authentication system with SQLite database
- Database migration support via Flask-Migrate (Alembic)
- Secure password handling
- Modern, eye-catching Neo-brutalist UI design
- Tailwind CSS utility classes with custom neo-brutalist components
- Interactive UI elements with playful animations
- Gunicorn integration for production deployment
- Docker containerization for easy deployment and scaling
- Docker Compose for orchestration and environment management
- Automated database management and backups

## Installation

1. Make sure you have Python 3.12+ installed
2. Install pipenv if not already installed:

   ```bash
   pip install pipenv
   ```

3. Clone the repository and navigate to the project directory
4. Install dependencies:

   ```bash
   pipenv install
   ```

## Development

To run the application in development mode:

```bash
pipenv run python wsgi.py
```

This will start the Flask development server on `http://127.0.0.1:5000/`

## Production

### Using Gunicorn Directly

To run the application in production using Gunicorn:

```bash
pipenv run gunicorn -c gunicorn_config.py wsgi:app
```

This will start Gunicorn on `0.0.0.0:8000` as specified in the configuration file.

### Using Docker (Recommended)

The application can also be run using Docker, which provides better isolation and easier deployment.

#### Prerequisites

- Docker
- Docker Compose

#### Building and Running the Docker Container

1. Build the Docker image:

   ```bash
   docker-compose build
   ```

1. Start the container:

   ```bash
   docker-compose up -d
   ```

1. The application will be available at `http://localhost:8000`

#### Docker Management Script

For convenience, a management script is provided that supports both development and production environments:

```bash
# Development environment (default)
./docker.sh build       # Build the Docker image
./docker.sh up          # Start the containers
./docker.sh down        # Stop the containers
./docker.sh logs        # View logs
./docker.sh restart     # Restart containers
./docker.sh shell       # Access shell in the container
./docker.sh ps          # Show container status
./docker.sh health      # Check application health

# Database operations
./docker.sh db-migrate "Migration description"  # Create a new database migration
./docker.sh db-upgrade                         # Apply pending migrations
./docker.sh db-downgrade                       # Revert last migration
./docker.sh create-admin                       # Create default admin user
./docker.sh backup-db                          # Backup the database

# Production environment
./docker.sh build prod  # Build the production Docker image
./docker.sh up prod     # Start production containers
./docker.sh down prod   # Stop production containers
# ... and so on with other commands
```

#### Production Deployment

For production deployment, a separate Docker Compose file is provided with optimized settings:

```bash
# Set a secure secret key for production
export SECRET_KEY="your-secure-secret-key-here"

# Start the production containers
./docker.sh up prod
```

The production setup includes:

- Resource constraints for better host resource management
- No volume mounts for better security and stability
- Environment variable for the secret key
- Always restart policy for maximum uptime

### Environment Variables and Customization

When running with Docker, you can customize the application behavior using environment variables:

- `FLASK_APP`: The entry point to the Flask application (default: `wsgi.py`)
- `FLASK_ENV`: The environment to run Flask in (`development` or `production`)
- `SECRET_KEY`: Secret key for session signing (change this in production!)
- `DATABASE_URL`: SQLite database connection string (default: `sqlite:///captive_portal.db`)

You can modify these values in the `docker-compose.yml` file or pass them when running the container:

```bash
docker-compose run -e SECRET_KEY=my-secret-key -e DATABASE_URL=sqlite:///my_custom_db.db web
```

A `.env` file is also supported for managing environment variables. Create a `.env` file in the project root with the following contents:

```env
FLASK_APP=wsgi.py
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=your-secret-key-here
DATABASE_URL=sqlite:///captive_portal.db
```

### Docker Volumes

The Docker Compose configuration mounts the following volumes:

- The local `app` directory into the container, allowing you to make code changes without rebuilding the container
- The `migrations` directory to persist database migrations
- The `captive_portal.db` SQLite database file to persist data between container restarts

For production, consider a more robust database setup for high-traffic applications.

## Database Management

The application uses SQLite as the database engine with SQLAlchemy as the ORM (Object-Relational Mapping) layer. Flask-Migrate (Alembic) is used for database migrations.

### Creating Migrations

When you make changes to your database models, you need to create a migration:

```bash
# Using the docker.sh script
./docker.sh db-migrate "Added user roles"

# Or directly with Flask
FLASK_APP=wsgi.py pipenv run flask db migrate -m "Added user roles"
```

### Applying Migrations

To apply pending migrations:

```bash
# Using the docker.sh script
./docker.sh db-upgrade

# Or directly with Flask
FLASK_APP=wsgi.py pipenv run flask db upgrade
```

### Rolling Back Migrations

If you need to roll back a migration:

```bash
# Using the docker.sh script
./docker.sh db-downgrade

# Or directly with Flask
FLASK_APP=wsgi.py pipenv run flask db downgrade
```

### Database Backups

Regular database backups are recommended:

```bash
# Using the docker.sh script
./docker.sh backup-db
```

Backups are stored in the `backups` directory with timestamps.

## Login Credentials

After initial setup, a default admin user is created:

- Email: `admin@example.com`
- Password: `password`

**Important**: Change this password immediately in a production environment.

## Project Structure

```text
captive-portal-platform/
│
├── app/                        # Flask application
│   ├── __init__.py             # App initialization
│   ├── auth.py                 # Authentication routes
│   ├── cli.py                  # CLI commands for Flask
│   ├── models.py               # Database models with SQLAlchemy
│   ├── routes.py               # Main routes
│   ├── static/                 # Static files
│   │   ├── css/                # CSS files
│   │   │   └── main.css        # Main CSS file with neo-brutalist styles
│   │   └── js/                 # JavaScript files
│   │       ├── main.js         # Main JS file
│   │       └── tailwind.config.js # Tailwind configuration
│   └── templates/              # HTML templates
│       ├── base.html           # Base template
│       ├── home.html           # Home page template
│       ├── login.html          # Login page template
│       └── unauthorized.html   # Unauthorized access page
│
├── migrations/                 # Database migrations directory
│   ├── README                  # Migration instructions
│   ├── alembic.ini             # Alembic configuration
│   ├── env.py                  # Environment configuration
│   ├── script.py.mako          # Script template
│   └── versions/               # Migration versions
│
├── backups/                    # Database backup directory
├── .dockerignore               # Files to exclude from Docker context
├── .env                        # Environment variables
├── .gitignore                  # Files to ignore in git
├── captive_portal.db           # SQLite database file
├── docker-compose.yml          # Docker Compose configuration for development
├── docker-compose.prod.yml     # Docker Compose configuration for production
├── docker-entrypoint.sh        # Docker entry point script for database setup
├── docker.sh                   # Docker management script
├── Dockerfile                  # Docker image definition
├── gunicorn_config.py          # Gunicorn configuration
├── manage.py                   # Management script with CLI commands
├── Pipfile                     # Project dependencies
├── Pipfile.lock                # Lock file for dependencies
├── README.md                   # Project documentation
└── wsgi.py                     # WSGI entry point
```

## Raspberry Pi Deployment

For easy deployment on a Raspberry Pi with Nginx as a reverse proxy, a comprehensive deployment script is included.

### Requirements for Raspberry Pi

- Raspberry Pi with Raspberry Pi OS (formerly Raspbian)
- Sudo/root access
- Internet connection

### Deployment Options

The script supports multiple deployment methods:

1. Using Docker (recommended)
   - Containerized deployment
   - Less impact on the Raspberry Pi's filesystem
   - Automated database setup and migrations
   - Persistent SQLite database through volume mounts

2. Direct installation
   - Uses Python virtual environment
   - Local SQLite database with automated migration support
   - Managed by systemd service

### Basic Usage

```bash
# Copy the repository to your Raspberry Pi
# SSH into your Raspberry Pi
ssh pi@raspberry.local

# Navigate to the project directory and run the deployment script
cd captive-portal-platform
sudo ./deploy.sh
```

This will:

- Set up the Flask application with SQLite database
- Create the initial database migrations
- Set up a default admin user
- Configure the application for production use

### Advanced Options

The deployment script offers several options:

```bash
sudo ./deploy.sh --help            # Show help message
sudo ./deploy.sh --update-system   # Update the system before installation
sudo ./deploy.sh --no-docker       # Use direct installation instead of Docker
sudo ./deploy.sh --hostname myportal.local  # Set custom hostname
sudo ./deploy.sh --port 8080       # Use custom port for the Flask app
```

### Database Management on Raspberry Pi

After deployment, you can manage the database using the following commands:

#### With Docker Deployment

```bash
cd /opt/captive-portal
./docker.sh db-migrate "Description"  # Create a new migration
./docker.sh db-upgrade               # Apply migrations
./docker.sh backup-db                # Backup the database
```

#### With Direct Installation

```bash
cd /opt/captive-portal
source venv/bin/activate
FLASK_APP=wsgi.py flask db migrate -m "Description"  # Create a new migration
FLASK_APP=wsgi.py flask db upgrade                  # Apply migrations
```

### Captive Portal Functionality

The script can optionally set up full captive portal functionality:

- Creates a WiFi access point
- Redirects all web traffic to the login page
- Handles DNS and DHCP

This turns your Raspberry Pi into a complete, standalone captive portal solution.

### Accessing the Portal

After deployment:

1. The web interface is available at `http://captiveportal.local` (or your custom hostname)
2. If using the captive portal functionality, connect to the "CaptivePortal" WiFi network
