CREATE EXTENSION IF NOT EXISTS postgis;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'ANALYST', 'RESPONDER')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE regions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    state_code VARCHAR(10) NOT NULL,
    boundary GEOMETRY(MULTIPOLYGON, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE grid_cells (
    id BIGSERIAL PRIMARY KEY,
    region_id BIGINT NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
    cell_code VARCHAR(40) NOT NULL UNIQUE,
    resolution_m INTEGER NOT NULL CHECK (resolution_m > 0),
    cell_boundary GEOMETRY(POLYGON, 4326) NOT NULL,
    centroid GEOMETRY(POINT, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE fire_events (
    id BIGSERIAL PRIMARY KEY,
    region_id BIGINT NOT NULL REFERENCES regions(id) ON DELETE RESTRICT,
    grid_cell_id BIGINT REFERENCES grid_cells(id) ON DELETE SET NULL,
    reported_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    event_status VARCHAR(20) NOT NULL CHECK (event_status IN ('ACTIVE', 'CONTAINED', 'EXTINGUISHED')),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    source VARCHAR(40) NOT NULL CHECK (source IN ('SATELLITE', 'SENSOR', 'MANUAL', 'MODEL')),
    ignition_time TIMESTAMPTZ NOT NULL,
    containment_percent NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (containment_percent >= 0 AND containment_percent <= 100),
    ignition_point GEOMETRY(POINT, 4326) NOT NULL,
    perimeter GEOMETRY(MULTIPOLYGON, 4326),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE weather_observations (
    id BIGSERIAL PRIMARY KEY,
    grid_cell_id BIGINT NOT NULL REFERENCES grid_cells(id) ON DELETE CASCADE,
    observed_at TIMESTAMPTZ NOT NULL,
    temperature_c NUMERIC(5,2) NOT NULL,
    humidity_percent NUMERIC(5,2) NOT NULL CHECK (humidity_percent >= 0 AND humidity_percent <= 100),
    wind_speed_mps NUMERIC(6,2) NOT NULL CHECK (wind_speed_mps >= 0),
    wind_direction_deg NUMERIC(6,2) CHECK (wind_direction_deg >= 0 AND wind_direction_deg < 360),
    precipitation_mm NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (precipitation_mm >= 0),
    observation_point GEOMETRY(POINT, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (grid_cell_id, observed_at)
);

CREATE TABLE satellite_observations (
    id BIGSERIAL PRIMARY KEY,
    grid_cell_id BIGINT NOT NULL REFERENCES grid_cells(id) ON DELETE CASCADE,
    captured_at TIMESTAMPTZ NOT NULL,
    satellite_name VARCHAR(80) NOT NULL,
    thermal_anomaly_score NUMERIC(5,2) NOT NULL CHECK (thermal_anomaly_score >= 0 AND thermal_anomaly_score <= 1),
    confidence_percent NUMERIC(5,2) NOT NULL CHECK (confidence_percent >= 0 AND confidence_percent <= 100),
    hotspot GEOMETRY(POINT, 4326) NOT NULL,
    footprint GEOMETRY(POLYGON, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (grid_cell_id, satellite_name, captured_at)
);

CREATE TABLE terrain_features (
    id BIGSERIAL PRIMARY KEY,
    grid_cell_id BIGINT NOT NULL REFERENCES grid_cells(id) ON DELETE CASCADE,
    vegetation_type VARCHAR(20) NOT NULL CHECK (vegetation_type IN ('FOREST', 'SHRUBLAND', 'GRASSLAND', 'AGRICULTURE', 'URBAN', 'BARREN')),
    fuel_load_t_ha NUMERIC(6,2) NOT NULL CHECK (fuel_load_t_ha >= 0),
    average_slope_deg NUMERIC(5,2) NOT NULL CHECK (average_slope_deg >= 0 AND average_slope_deg <= 90),
    average_elevation_m NUMERIC(7,2) NOT NULL,
    feature_geometry GEOMETRY(POLYGON, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (grid_cell_id)
);

CREATE TABLE risk_predictions (
    id BIGSERIAL PRIMARY KEY,
    grid_cell_id BIGINT NOT NULL REFERENCES grid_cells(id) ON DELETE CASCADE,
    weather_observation_id BIGINT REFERENCES weather_observations(id) ON DELETE SET NULL,
    satellite_observation_id BIGINT REFERENCES satellite_observations(id) ON DELETE SET NULL,
    model_version VARCHAR(50) NOT NULL,
    risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'EXTREME')),
    risk_score NUMERIC(5,4) NOT NULL CHECK (risk_score >= 0 AND risk_score <= 1),
    predicted_at TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (grid_cell_id, model_version, predicted_at)
);

CREATE TABLE fire_simulations (
    id BIGSERIAL PRIMARY KEY,
    fire_event_id BIGINT REFERENCES fire_events(id) ON DELETE SET NULL,
    initiated_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    simulation_name VARCHAR(140) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED')),
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE simulation_cells (
    id BIGSERIAL PRIMARY KEY,
    simulation_id BIGINT NOT NULL REFERENCES fire_simulations(id) ON DELETE CASCADE,
    grid_cell_id BIGINT NOT NULL REFERENCES grid_cells(id) ON DELETE CASCADE,
    timestep_hour INTEGER NOT NULL CHECK (timestep_hour >= 0),
    predicted_intensity NUMERIC(5,4) NOT NULL CHECK (predicted_intensity >= 0 AND predicted_intensity <= 1),
    spread_rate_mph NUMERIC(8,2) NOT NULL CHECK (spread_rate_mph >= 0),
    simulated_perimeter GEOMETRY(POLYGON, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (simulation_id, grid_cell_id, timestep_hour)
);

CREATE TABLE villages (
    id BIGSERIAL PRIMARY KEY,
    region_id BIGINT NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
    name VARCHAR(120) NOT NULL,
    population INTEGER NOT NULL CHECK (population >= 0),
    location GEOMETRY(POINT, 4326) NOT NULL,
    boundary GEOMETRY(POLYGON, 4326),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (region_id, name)
);

CREATE TABLE roads (
    id BIGSERIAL PRIMARY KEY,
    region_id BIGINT NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
    road_name VARCHAR(160) NOT NULL,
    road_type VARCHAR(20) NOT NULL CHECK (road_type IN ('HIGHWAY', 'PRIMARY', 'SECONDARY', 'LOCAL', 'TRAIL')),
    is_evacuation_route BOOLEAN NOT NULL DEFAULT FALSE,
    geometry GEOMETRY(LINESTRING, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (region_id, road_name)
);

CREATE TABLE alerts (
    id BIGSERIAL PRIMARY KEY,
    region_id BIGINT NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
    fire_event_id BIGINT REFERENCES fire_events(id) ON DELETE SET NULL,
    village_id BIGINT REFERENCES villages(id) ON DELETE SET NULL,
    alert_type VARCHAR(20) NOT NULL CHECK (alert_type IN ('WATCH', 'WARNING', 'EVACUATION')),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'RESOLVED', 'CANCELLED')),
    message TEXT NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    affected_area GEOMETRY(MULTIPOLYGON, 4326),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_regions_boundary_gist ON regions USING GIST (boundary);
CREATE INDEX idx_grid_cells_boundary_gist ON grid_cells USING GIST (cell_boundary);
CREATE INDEX idx_grid_cells_centroid_gist ON grid_cells USING GIST (centroid);
CREATE INDEX idx_fire_events_ignition_point_gist ON fire_events USING GIST (ignition_point);
CREATE INDEX idx_fire_events_perimeter_gist ON fire_events USING GIST (perimeter);
CREATE INDEX idx_weather_observations_point_gist ON weather_observations USING GIST (observation_point);
CREATE INDEX idx_satellite_observations_hotspot_gist ON satellite_observations USING GIST (hotspot);
CREATE INDEX idx_satellite_observations_footprint_gist ON satellite_observations USING GIST (footprint);
CREATE INDEX idx_terrain_features_geometry_gist ON terrain_features USING GIST (feature_geometry);
CREATE INDEX idx_simulation_cells_perimeter_gist ON simulation_cells USING GIST (simulated_perimeter);
CREATE INDEX idx_villages_location_gist ON villages USING GIST (location);
CREATE INDEX idx_villages_boundary_gist ON villages USING GIST (boundary);
CREATE INDEX idx_roads_geometry_gist ON roads USING GIST (geometry);
CREATE INDEX idx_alerts_affected_area_gist ON alerts USING GIST (affected_area);

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_regions_updated_at BEFORE UPDATE ON regions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_grid_cells_updated_at BEFORE UPDATE ON grid_cells
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_fire_events_updated_at BEFORE UPDATE ON fire_events
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_weather_observations_updated_at BEFORE UPDATE ON weather_observations
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_satellite_observations_updated_at BEFORE UPDATE ON satellite_observations
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_terrain_features_updated_at BEFORE UPDATE ON terrain_features
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_risk_predictions_updated_at BEFORE UPDATE ON risk_predictions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_fire_simulations_updated_at BEFORE UPDATE ON fire_simulations
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_simulation_cells_updated_at BEFORE UPDATE ON simulation_cells
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_villages_updated_at BEFORE UPDATE ON villages
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_roads_updated_at BEFORE UPDATE ON roads
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_alerts_updated_at BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
