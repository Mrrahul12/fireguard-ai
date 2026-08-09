# FireGuard AI - Development Foundation

FireGuard AI is planned as an AI-assisted wildfire risk prediction and short-horizon spread simulation platform.

This repository currently contains **only the development scaffold** for frontend, backend, ML service, and geospatial database integration.

> Advanced features such as ML model training/inference workflows, satellite processing pipelines, and fire spread simulation logic are intentionally **not** implemented yet.

## Folder Structure

```text
fireguard-ai/
├── frontend/        # React + Vite + TypeScript + Tailwind + Router + Axios + Leaflet
├── backend/         # Spring Boot (Java 17, Maven) REST API scaffold
├── ml-service/      # FastAPI scaffold with geospatial/data-science dependencies
├── data-pipeline/   # Placeholder for future data ingestion/transformation jobs
├── database/        # PostGIS initialization scripts
├── docs/            # Placeholder for project documentation
├── docker-compose.yml
└── .env.example
```

## Prerequisites

- Docker + Docker Compose
- Node.js 20+ (for local frontend runs)
- Java 17+ and Maven (for local backend runs)
- Python 3.11+ (for local ML runs)

## Quick Start (All Services with Docker Compose)

1. Copy environment template:

   ```bash
   cp .env.example .env
   ```

2. Start all services:

   ```bash
   docker compose up --build
   ```

3. Stop services:

   ```bash
   docker compose down
   ```

## Run Individual Services (Local Dev)

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend default URL: `http://localhost:5173`

### Backend

```bash
cd backend
mvn spring-boot:run
```

Backend default URL: `http://localhost:8080`

### ML Service

```bash
cd ml-service
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

ML service default URL: `http://localhost:8000`

## Health Checks

### Backend health endpoint

```bash
curl http://localhost:8080/api/v1/health
```

Expected response:

```json
{"status":"UP","service":"backend"}
```

### ML health endpoint

```bash
curl http://localhost:8000/health
```

Expected response:

```json
{"status":"UP","service":"ml-service"}
```

## Useful Docker Compose Commands

Start in detached mode:

```bash
docker compose up -d --build
```

View status:

```bash
docker compose ps
```

Tail logs:

```bash
docker compose logs -f backend ml-service frontend postgres
```

Rebuild one service:

```bash
docker compose up --build backend
```

## Troubleshooting

- **Geospatial Python dependency issues (GeoPandas/Rasterio/Shapely)**:
  - These packages rely on native geospatial libraries. Use the provided ML Dockerfile first, because it installs required system libs (`gdal`, `geos`, `proj`, spatial index).
  - For local non-Docker installs, ensure OS packages for GDAL/GEOS/PROJ are installed before `pip install -r requirements.txt`.

- **Port conflicts**:
  - Update `.env` values (`FRONTEND_PORT`, `BACKEND_PORT`, `ML_SERVICE_PORT`, `POSTGRES_PORT`) if defaults are already in use.

- **Backend Docker build TLS/certificate issues (restricted networks)**:
  - If Maven inside Docker cannot download dependencies with PKIX/certificate errors, your network may require custom CA trust configuration in Docker.
  - In that case, run backend locally (`mvn spring-boot:run`) while you configure Docker daemon/container trust settings for your organization CA.

- **Backend CORS issues in browser**:
  - Set `CORS_ALLOWED_ORIGINS` in `.env` to match your frontend origin.
