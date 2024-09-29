FROM python:3.9-slim

# Work dir
WORKDIR /app

# Copy requirements.txt files for install depends
COPY requirements.txt /app/

# Install depends
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

# Port
EXPOSE 5000

CMD ["python", "app.py"]
