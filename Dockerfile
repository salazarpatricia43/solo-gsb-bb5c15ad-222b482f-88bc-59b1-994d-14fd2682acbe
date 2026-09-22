FROM python:3.12-slim

LABEL org.opencontainers.image.title="task-barrier-api" \
      org.opencontainers.image.description="并行任务协调收尾屏障 API：幂等报到、阻塞等待、取消、运行中延期与参与者替补" \
      org.opencontainers.image.version="1.4.0"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 8000

# uvicorn 每 30s 向 Redis 发一次 ping 级别的探活；这里只探 HTTP 进程
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).status==200 else 1)"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
