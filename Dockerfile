# Pull a pre-built alpine docker image with nginx and python3 installed
FROM python:3.10.5-slim 
# tiangolo/uwsgi-nginx:python3.8-alpine-2020-12-19

# Set the port on which the app runs; make both values the same.
#
# IMPORTANT: When deploying to Azure App Service, go to the App Service on the Azure 
# portal, navigate to the Applications Settings blade, and create a setting named
# WEBSITES_PORT with a value that matches the port here (the Azure default is 80).
# You can also create a setting through the App Service Extension in VS Code.
ENV LISTEN_PORT=8000
EXPOSE 8000

# Indicate where uwsgi.ini lives
ENV UWSGI_INI uwsgi.ini

# Tell nginx where static files live. Typically, developers place static files for
# multiple apps in a shared folder, but for the purposes here we can use the one
# app's folder. Note that when multiple apps share a folder, you should create subfolders
# with the same name as the app underneath "static" so there aren't any collisions
# when all those static files are collected together, as when using Django's
# collectstatic command.
ENV STATIC_URL /app/static_collected

# Copy the app files to a folder and run it from there
WORKDIR /app
ADD . /app

# Make app folder writeable for the sake of db.sqlite3, and make that file also writeable.
# Ideally you host the database somewhere else so that the app folders can remain read only.
# Without these permissions you see the errors "unable to open database file" and
# "attempt to write to a readonly database", respectively, whenever the app attempts to
# write to the database.
RUN chmod g+w /app
# RUN chmod g+w /app/db.sqlite3

# Make sure dependencies are installed
RUN python3 -m pip install -r requirements.txt

ENV DJANGO_SETTINGS_MODULE=web_project.envs.dev_local

# # Creates a non-root user with an explicit UID and adds permission to access the /app folder
# # For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser

# # During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "web_project.wsgi"]

RUN apt-get update
RUN apt-get install ffmpeg -y
