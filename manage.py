#!/usr/bin/env python
import click
from flask.cli import FlaskGroup
from app import create_app, db
from app.models import User

def create_cli_app():
    return create_app()

cli = FlaskGroup(create_app=create_cli_app)

@cli.command('create-admin')
def create_admin():
    """Create default admin user"""
    app = create_app()
    with app.app_context():
        if User.query.filter_by(email='admin@example.com').first() is None:
            admin = User(email='admin@example.com')
            admin.set_password('password')
            db.session.add(admin)
            db.session.commit()
            click.echo('Admin user created!')
        else:
            click.echo('Admin user already exists!')

if __name__ == '__main__':
    cli()
