# Sample App 2 Dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application file
COPY app.py .

# Expose port
EXPOSE 5000

# Start the application
CMD ["python", "app.py"]
