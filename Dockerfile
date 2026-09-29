FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY source.zip /tmp/source.zip
RUN python -m zipfile -e /tmp/source.zip /app \
    && rm -f /tmp/source.zip \
    && pip install --no-cache-dir -r /app/requirements.txt

ENV PYTHONUNBUFFERED=1
EXPOSE 8787

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8787/healthz', timeout=3).read()" || exit 1

CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8787"]
