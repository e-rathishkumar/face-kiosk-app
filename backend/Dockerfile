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
    make \
    cmake \
    python3-dev \
    wget \
    unzip \
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

# Create uploads and exports directories for persistent storage
RUN mkdir -p $HOME/app/uploads $HOME/app/exports && chown -R user $HOME/app/uploads $HOME/app/exports

# Download buffalo_sc model from GitHub directly to avoid GDrive quotas
RUN mkdir -p $HOME/app/models/buffalo_sc && \
    wget -q https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_sc.zip -O /tmp/buffalo_sc.zip && \
    unzip -o -q /tmp/buffalo_sc.zip -d $HOME/app/models/buffalo_sc && \
    rm /tmp/buffalo_sc.zip && \
    chown -R user $HOME/app/models

# Switch to the non-root user
USER user

# Start the application using uvicorn on port 7860 (HuggingFace requirement)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
