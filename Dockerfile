FROM python:3.12-slim AS builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install --no-cache-dir pipenv

# Copy dependencies
COPY Pipfile Pipfile.lock ./

# Install dependencies to system
RUN pipenv install --deploy --system

# Final stage
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install curl for health checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Set Python paths
ENV PYTHONPATH=/usr/local/lib/python3.12/site-packages

# Set environment variables
ENV FLASK_APP=wsgi.py \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

# Create a non-root user to run the application
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Expose the port
EXPOSE 8000

# Run the application with Gunicorn
CMD gunicorn -c gunicorn_config.py wsgi:app
