# Captive Portal Platform

A Flask-based captive portal platform with authentication and a modern Tailwind CSS UI.

## Features

- User authentication system
- Secure password handling
- Modern, responsive UI using Tailwind CSS
- Gunicorn integration for production deployment

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

To run the application in production using Gunicorn:

```bash
pipenv run gunicorn -c gunicorn_config.py wsgi:app
```

This will start Gunicorn on `0.0.0.0:8000` as specified in the configuration file.

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
│   │   │   └── main.css        # Main CSS file
│   │   └── js/                 # JavaScript files
│   │       └── main.js         # Main JS file
│   └── templates/              # HTML templates
│       ├── base.html           # Base template
│       ├── home.html           # Home page template
│       └── login.html          # Login page template
│
├── gunicorn_config.py          # Gunicorn configuration
├── Pipfile                     # Project dependencies
├── Pipfile.lock                # Lock file for dependencies
├── README.md                   # Project documentation
└── wsgi.py                     # WSGI entry point
```
