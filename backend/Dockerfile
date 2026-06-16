# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies required for OpenCV and InsightFace
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user (HuggingFace requires this)
RUN useradd -m -u 1000 user
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH
WORKDIR $HOME/app

# Copy project and chown to the non-root user
COPY --chown=user . $HOME/app

# Create uploads directory for persistent storage
RUN mkdir -p $HOME/app/uploads && chown -R user $HOME/app/uploads

# Switch to the non-root user
USER user

# Start the application using uvicorn on port 7860 (HuggingFace requirement)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
