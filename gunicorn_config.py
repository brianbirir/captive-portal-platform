"""Gunicorn configuration file."""

# Gunicorn config variables
workers = 1
worker_class = "gthread"
threads = 4
bind = "0.0.0.0:8000"
daemon = False
pidfile = "gunicorn.pid"
umask = 0
user = None
group = None
tmp_upload_dir = None

# Logging
errorlog = "-"
loglevel = "info"
accesslog = "-"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
