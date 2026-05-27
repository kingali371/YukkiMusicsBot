# === مرحلة البناء ===
FROM python:3.9-slim AS builder

WORKDIR /app

# تثبيت المتطلبات الأساسية للبناء
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# تثبيت المتطلبات في مجلد مؤقت
COPY requirements.txt .
RUN pip3 install --no-cache-dir --user -r requirements.txt


# === مرحلة التشغيل النهائية ===
FROM python:3.9-slim

WORKDIR /app

# تثبيت المتطلبات الأساسية فقط (بدون أدوات البناء)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# نسخ المكتبات المثبتة من مرحلة البناء
COPY --from=builder /root/.local /root/.local

# جعل المجلدات المحلية ضمن PATH
ENV PATH=/root/.local/bin:$PATH

# نسخ ملفات المشروع
COPY . .

# أمر التشغيل
CMD ["python3", "-m", "YukkiMusic"]
