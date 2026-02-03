# Base image (from the trusted registry)
FROM python:3.11-slim

WORKDIR /app

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# <KERNEL-CAPABILITIES> Copy project files and change ownership to non-root user (uid 1000)
COPY --chown=1000:1000 . .

# <KERNEL-CAPABILITIES> Creates the user during the image build
RUN adduser --disabled-password --gecos "" --uid 1000 appuser

# <KERNEL-CAPABILITIES> Ensure db directory exists and is owned by appuser
RUN mkdir -p db && chown -R 1000:1000 db

# <KERNEL-CAPABILITIES> Switches all subsequent commands (and the container's runtime process) to that user
USER appuser

EXPOSE 8000

# Run migrations at startup against the mounted volume, then start gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn mysite.wsgi:application --bind 0.0.0.0:8000"]
