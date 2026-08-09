INSERT INTO users (id, full_name, email, role)
VALUES
    (1, 'Asha Verma', 'asha.verma@fireguard.ai', 'ADMIN'),
    (2, 'Rohan Singh', 'rohan.singh@fireguard.ai', 'ANALYST'),
    (3, 'Meera Nair', 'meera.nair@fireguard.ai', 'RESPONDER');

INSERT INTO regions (id, name, state_code, boundary)
VALUES
    (
        1,
        'Pine Valley Reserve',
        'PV',
        ST_Multi(ST_GeomFromText('POLYGON((77.0000 28.0000, 77.0000 28.1000, 77.1000 28.1000, 77.1000 28.0000, 77.0000 28.0000))', 4326))
    );

INSERT INTO grid_cells (id, region_id, cell_code, resolution_m, cell_boundary, centroid)
VALUES
    (
        1,
        1,
        'PV-001',
        500,
        ST_GeomFromText('POLYGON((77.0100 28.0100, 77.0100 28.0500, 77.0500 28.0500, 77.0500 28.0100, 77.0100 28.0100))', 4326),
        ST_GeomFromText('POINT(77.0300 28.0300)', 4326)
    ),
    (
        2,
        1,
        'PV-002',
        500,
        ST_GeomFromText('POLYGON((77.0500 28.0100, 77.0500 28.0500, 77.0900 28.0500, 77.0900 28.0100, 77.0500 28.0100))', 4326),
        ST_GeomFromText('POINT(77.0700 28.0300)', 4326)
    );

INSERT INTO fire_events (id, region_id, grid_cell_id, reported_by_user_id, event_status, severity, source, ignition_time, containment_percent, ignition_point, perimeter)
VALUES
    (
        1,
        1,
        1,
        3,
        'ACTIVE',
        'HIGH',
        'SATELLITE',
        '2026-08-08 12:30:00+00',
        20,
        ST_GeomFromText('POINT(77.0320 28.0310)', 4326),
        ST_Multi(ST_GeomFromText('POLYGON((77.0260 28.0260, 77.0260 28.0360, 77.0380 28.0360, 77.0380 28.0260, 77.0260 28.0260))', 4326))
    );

INSERT INTO weather_observations (id, grid_cell_id, observed_at, temperature_c, humidity_percent, wind_speed_mps, wind_direction_deg, precipitation_mm, observation_point)
VALUES
    (1, 1, '2026-08-09 04:00:00+00', 36.20, 21.50, 7.80, 125.00, 0.00, ST_GeomFromText('POINT(77.0315 28.0308)', 4326)),
    (2, 2, '2026-08-09 04:00:00+00', 35.10, 24.20, 5.50, 110.00, 0.00, ST_GeomFromText('POINT(77.0695 28.0303)', 4326));

INSERT INTO satellite_observations (id, grid_cell_id, captured_at, satellite_name, thermal_anomaly_score, confidence_percent, hotspot, footprint)
VALUES
    (
        1,
        1,
        '2026-08-09 03:45:00+00',
        'Sentinel-2A',
        0.86,
        92.00,
        ST_GeomFromText('POINT(77.0320 28.0312)', 4326),
        ST_GeomFromText('POLYGON((77.0240 28.0240, 77.0240 28.0400, 77.0400 28.0400, 77.0400 28.0240, 77.0240 28.0240))', 4326)
    );

INSERT INTO terrain_features (id, grid_cell_id, vegetation_type, fuel_load_t_ha, average_slope_deg, average_elevation_m, feature_geometry)
VALUES
    (
        1,
        1,
        'FOREST',
        18.40,
        14.20,
        612.00,
        ST_GeomFromText('POLYGON((77.0120 28.0120, 77.0120 28.0480, 77.0480 28.0480, 77.0480 28.0120, 77.0120 28.0120))', 4326)
    ),
    (
        2,
        2,
        'SHRUBLAND',
        10.10,
        7.40,
        580.00,
        ST_GeomFromText('POLYGON((77.0520 28.0120, 77.0520 28.0480, 77.0880 28.0480, 77.0880 28.0120, 77.0520 28.0120))', 4326)
    );

INSERT INTO risk_predictions (id, grid_cell_id, weather_observation_id, satellite_observation_id, model_version, risk_level, risk_score, predicted_at, valid_until)
VALUES
    (1, 1, 1, 1, 'baseline-v0.1', 'EXTREME', 0.9300, '2026-08-09 04:05:00+00', '2026-08-09 10:05:00+00'),
    (2, 2, 2, NULL, 'baseline-v0.1', 'HIGH', 0.7400, '2026-08-09 04:05:00+00', '2026-08-09 10:05:00+00');

INSERT INTO fire_simulations (id, fire_event_id, initiated_by_user_id, simulation_name, status, started_at, completed_at, notes)
VALUES
    (1, 1, 2, 'Pine Valley 6-hour spread', 'COMPLETED', '2026-08-09 04:20:00+00', '2026-08-09 04:35:00+00', 'Baseline placeholder simulation output for schema validation.');

INSERT INTO simulation_cells (id, simulation_id, grid_cell_id, timestep_hour, predicted_intensity, spread_rate_mph, simulated_perimeter)
VALUES
    (
        1,
        1,
        1,
        1,
        0.6800,
        190.00,
        ST_GeomFromText('POLYGON((77.0270 28.0270, 77.0270 28.0375, 77.0390 28.0375, 77.0390 28.0270, 77.0270 28.0270))', 4326)
    ),
    (
        2,
        1,
        2,
        2,
        0.4200,
        120.00,
        ST_GeomFromText('POLYGON((77.0550 28.0200, 77.0550 28.0340, 77.0740 28.0340, 77.0740 28.0200, 77.0550 28.0200))', 4326)
    );

INSERT INTO villages (id, region_id, name, population, location, boundary)
VALUES
    (
        1,
        1,
        'Kedar Hamlet',
        1850,
        ST_GeomFromText('POINT(77.0180 28.0180)', 4326),
        ST_GeomFromText('POLYGON((77.0155 28.0155, 77.0155 28.0205, 77.0205 28.0205, 77.0205 28.0155, 77.0155 28.0155))', 4326)
    ),
    (
        2,
        1,
        'Ridgeview',
        2670,
        ST_GeomFromText('POINT(77.0840 28.0240)', 4326),
        ST_GeomFromText('POLYGON((77.0810 28.0210, 77.0810 28.0270, 77.0870 28.0270, 77.0870 28.0210, 77.0810 28.0210))', 4326)
    );

INSERT INTO roads (id, region_id, road_name, road_type, is_evacuation_route, geometry)
VALUES
    (
        1,
        1,
        'Pine Valley Highway',
        'HIGHWAY',
        TRUE,
        ST_GeomFromText('LINESTRING(77.0050 28.0150, 77.0950 28.0400)', 4326)
    ),
    (
        2,
        1,
        'Forest Track 7',
        'TRAIL',
        FALSE,
        ST_GeomFromText('LINESTRING(77.0200 28.0450, 77.0600 28.0200)', 4326)
    );

INSERT INTO alerts (id, region_id, fire_event_id, village_id, alert_type, severity, status, message, issued_at, expires_at, affected_area)
VALUES
    (
        1,
        1,
        1,
        1,
        'WARNING',
        'HIGH',
        'ACTIVE',
        'High wildfire risk near Kedar Hamlet. Prepare for potential evacuation.',
        '2026-08-09 04:45:00+00',
        '2026-08-09 12:45:00+00',
        ST_Multi(ST_GeomFromText('POLYGON((77.0140 28.0140, 77.0140 28.0400, 77.0450 28.0400, 77.0450 28.0140, 77.0140 28.0140))', 4326))
    );

SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE((SELECT MAX(id) FROM users), 1), true);
SELECT setval(pg_get_serial_sequence('regions', 'id'), COALESCE((SELECT MAX(id) FROM regions), 1), true);
SELECT setval(pg_get_serial_sequence('grid_cells', 'id'), COALESCE((SELECT MAX(id) FROM grid_cells), 1), true);
SELECT setval(pg_get_serial_sequence('fire_events', 'id'), COALESCE((SELECT MAX(id) FROM fire_events), 1), true);
SELECT setval(pg_get_serial_sequence('weather_observations', 'id'), COALESCE((SELECT MAX(id) FROM weather_observations), 1), true);
SELECT setval(pg_get_serial_sequence('satellite_observations', 'id'), COALESCE((SELECT MAX(id) FROM satellite_observations), 1), true);
SELECT setval(pg_get_serial_sequence('terrain_features', 'id'), COALESCE((SELECT MAX(id) FROM terrain_features), 1), true);
SELECT setval(pg_get_serial_sequence('risk_predictions', 'id'), COALESCE((SELECT MAX(id) FROM risk_predictions), 1), true);
SELECT setval(pg_get_serial_sequence('fire_simulations', 'id'), COALESCE((SELECT MAX(id) FROM fire_simulations), 1), true);
SELECT setval(pg_get_serial_sequence('simulation_cells', 'id'), COALESCE((SELECT MAX(id) FROM simulation_cells), 1), true);
SELECT setval(pg_get_serial_sequence('villages', 'id'), COALESCE((SELECT MAX(id) FROM villages), 1), true);
SELECT setval(pg_get_serial_sequence('roads', 'id'), COALESCE((SELECT MAX(id) FROM roads), 1), true);
SELECT setval(pg_get_serial_sequence('alerts', 'id'), COALESCE((SELECT MAX(id) FROM alerts), 1), true);
