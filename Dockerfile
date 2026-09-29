FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg fonts-dejavu-core coreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY bundle /bundle

RUN cat /bundle/part* | base64 -d > /tmp/source.zip \
    && python -m zipfile -e /tmp/source.zip /app \
    && rm -rf /tmp/source.zip /bundle \
    && pip install --no-cache-dir -r /app/requirements.txt

ENV PYTHONUNBUFFERED=1
EXPOSE 8787

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import os,urllib.request; urllib.request.urlopen('http://127.0.0.1:'+os.getenv('PORT','8787')+'/healthz', timeout=3).read()" || exit 1

CMD ["sh","-c","uvicorn app:app --host 0.0.0.0 --port ${PORT:-8787}"]
