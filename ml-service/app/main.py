from fastapi import FastAPI

app = FastAPI(title="FireGuard AI ML Service", version="0.1.0")


@app.get('/health')
def health() -> dict[str, str]:
    return {'status': 'UP', 'service': 'ml-service'}
