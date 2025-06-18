# Captive Portal Platform

A Flask-based captive portal platform.

## Features

- User authentication system
- Secure password handling
- Modern, eye-catching Neo-brutalist UI design
- Tailwind CSS utility classes with custom neo-brutalist components
- Interactive UI elements with playful animations
- Gunicorn integration for production deployment
- Docker containerization for easy deployment and scaling
- Docker Compose for orchestration and environment management

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

You can modify these values in the `docker-compose.yml` file or pass them when running the container:

```bash
docker-compose run -e SECRET_KEY=my-secret-key web
```

### Docker Volumes

The Docker Compose configuration mounts the local `app` directory into the container, allowing you to make code changes without rebuilding the container. For production, consider removing this volume and rebuilding the image for each deployment.

## Login Credentials

For demonstration purposes, the following credentials are available:

- Email: `user@example.com`
- Password: `password`

*Note: In a production environment, you should use a proper database to store and verify user credentials.*

## Project Structure

```text
captive-portal-platform/
│
├── app/                        # Flask application
│   ├── __init__.py             # App initialization
│   ├── auth.py                 # Authentication routes
│   ├── models.py               # User model
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
├── .dockerignore               # Files to exclude from Docker context
├── docker-compose.yml          # Docker Compose configuration for development
├── docker-compose.prod.yml     # Docker Compose configuration for production
├── docker.sh                   # Docker management script
├── Dockerfile                  # Docker image definition
├── gunicorn_config.py          # Gunicorn configuration
├── Pipfile                     # Project dependencies
├── Pipfile.lock                # Lock file for dependencies
├── README.md                   # Project documentation
└── wsgi.py                     # WSGI entry point
```
