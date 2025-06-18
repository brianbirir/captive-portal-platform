"""Gunicorn configuration file optimized for Docker deployment."""
import multiprocessing

# Gunicorn config variables
# Dynamically set the number of workers based on available CPU cores
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "gthread"
threads = 4
bind = "0.0.0.0:8000"
daemon = False
pidfile = None  # No pidfile in Docker containers
umask = 0
user = None  # Docker runs as defined user in Dockerfile
group = None
tmp_upload_dir = None
worker_tmp_dir = "/tmp"
graceful_timeout = 30
timeout = 60
keepalive = 5

# Logging - output to stdout/stderr for Docker to capture
errorlog = "-"
loglevel = "info"
accesslog = "-"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
