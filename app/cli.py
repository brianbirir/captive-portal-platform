from flask import Blueprint
import click
from app import db
from app.models import User

cli_bp = Blueprint('cli', __name__, cli_group=None)

@cli_bp.cli.command('init-db')
def init_db():
    """Initialize the database."""
    db.create_all()
    click.echo('Initialized the database.')
