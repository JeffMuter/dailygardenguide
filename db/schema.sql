-- Daily Garden Guide Database Schema
-- SQLite3
SELECT
  email
FROM
  -- Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  first_name TEXT NOT NULL,
  zip_code TEXT NOT NULL,
  hardiness_zone INTEGER NOT NULL,
  timezone TEXT NOT NULL,
  email_time TEXT NOT NULL DEFAULT '06:00',
  email_frequency TEXT NOT NULL DEFAULT 'daily',
  email_enabled BOOLEAN NOT NULL DEFAULT 1,
  last_email_sent_at TIMESTAMP,
  email_failures INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users (email);

CREATE INDEX idx_users_email_enabled ON users (email_enabled)
WHERE
  email_enabled = 1;

-- Gardens table
CREATE TABLE gardens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  garden_type TEXT NOT NULL,
  size_sqft INTEGER,
  sun_hours INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gardens_user ON gardens (user_id);

-- Plant library table
CREATE TABLE plant_library (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  common_name TEXT NOT NULL,
  scientific_name TEXT,
  variety TEXT,
  plant_type TEXT NOT NULL,
  sun_hours_min INTEGER NOT NULL,
  sun_hours_max INTEGER,
  water_hours_per_week REAL,
  drought_tolerant BOOLEAN DEFAULT 0,
  days_to_maturity INTEGER,
  mature_height_inches INTEGER,
  mature_spread_inches INTEGER,
  spacing_inches INTEGER,
  soil_ph_min REAL,
  soil_ph_max REAL,
  frost_tolerant BOOLEAN DEFAULT 0,
  companion_plants TEXT,
  incompatible_plants TEXT,
  common_pests TEXT,
  notes TEXT,
  data_source TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plant_library_type ON plant_library (plant_type);

CREATE INDEX idx_plant_library_common_name ON plant_library (common_name);

-- Plant schedules table
CREATE TABLE plant_schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plant_id INTEGER NOT NULL REFERENCES plant_library (id) ON DELETE CASCADE,
  min_zone INTEGER NOT NULL,
  max_zone INTEGER NOT NULL,
  plant_month_start INTEGER NOT NULL,
  plant_month_end INTEGER NOT NULL,
  harvest_month_start INTEGER,
  harvest_month_end INTEGER,
  remove_month INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_schedules_plant ON plant_schedules (plant_id);

CREATE INDEX idx_schedules_zone_plant ON plant_schedules (min_zone, max_zone, plant_month_start);

-- Plants table (user's plants in their gardens)
CREATE TABLE plants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  garden_id INTEGER NOT NULL REFERENCES gardens (id) ON DELETE CASCADE,
  plant_id INTEGER REFERENCES plant_library (id) ON DELETE SET NULL,
  custom_plant_name TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'planted',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (
    (
      plant_id IS NOT NULL
      AND custom_plant_name IS NULL
    )
    OR (
      plant_id IS NULL
      AND custom_plant_name IS NOT NULL
    )
  )
);

CREATE INDEX idx_plants_garden ON plants (garden_id);

CREATE INDEX idx_plants_library ON plants (plant_id);

CREATE UNIQUE INDEX idx_plants_garden_plant ON plants (garden_id, plant_id)
WHERE
  plant_id IS NOT NULL;

-- Garden reports table
CREATE TABLE garden_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  report_type TEXT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  email_sent BOOLEAN NOT NULL DEFAULT 0,
  email_sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reports_user ON garden_reports (user_id, created_at DESC);

CREATE INDEX idx_reports_period ON garden_reports (user_id, period_start);

-- Messages table (chat history)
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_user ON messages (user_id, created_at DESC);
