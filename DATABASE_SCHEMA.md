# Database Schema

## users

User accounts with location and email preferences.

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name TEXT NOT NULL,

    zip_code TEXT NOT NULL,                -- For weather API
    hardiness_zone INTEGER NOT NULL,       -- USDA zones 1-13
    timezone TEXT NOT NULL,                -- IANA timezone (e.g., 'America/New_York')

    email_time TEXT NOT NULL DEFAULT '06:00',  -- HH:MM format, user's local time
    email_frequency TEXT NOT NULL DEFAULT 'daily',  -- daily, weekly
    email_enabled BOOLEAN NOT NULL DEFAULT 1,
    last_email_sent_at TIMESTAMP,
    email_failures INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_email_enabled ON users(email_enabled) WHERE email_enabled = 1;
```

---

## gardens

User's garden spaces. Each user can have multiple gardens with different conditions.

```sql
CREATE TABLE gardens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,

    garden_type TEXT NOT NULL,         -- raised_bed, container, in_ground, greenhouse
    size_sqft INTEGER,                 -- Square feet
    sun_hours INTEGER NOT NULL,        -- Average hours of direct sun per day

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gardens_user ON gardens(user_id);
```

---

## plants

User's plant instances in their gardens. One row per plant type per garden.

```sql
CREATE TABLE plants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    garden_id INTEGER NOT NULL REFERENCES gardens(id) ON DELETE CASCADE,
    plant_id INTEGER REFERENCES plant_library(id) ON DELETE SET NULL,  -- NULL for custom plants
    custom_plant_name TEXT,            -- Used when plant_id is NULL

    quantity INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'planted',  -- planted, sprouted, flowering, harvesting, removed
    notes TEXT,                        -- User observations, AI chat context

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK ((plant_id IS NOT NULL AND custom_plant_name IS NULL) OR (plant_id IS NULL AND custom_plant_name IS NOT NULL))
);

CREATE INDEX idx_plants_garden ON plants(garden_id);
CREATE INDEX idx_plants_library ON plants(plant_id);
CREATE UNIQUE INDEX idx_plants_garden_plant ON plants(garden_id, plant_id) WHERE plant_id IS NOT NULL;
```

---

## plant_library

Zone-independent plant characteristics. One row per plant species/variety.

```sql
CREATE TABLE plant_library (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    common_name TEXT NOT NULL,
    scientific_name TEXT,
    variety TEXT,
    plant_type TEXT NOT NULL,          -- vegetable, fruit, herb, flower, shrub, tree

    sun_hours_min INTEGER NOT NULL,
    sun_hours_max INTEGER,             -- NULL = unlimited
    water_hours_per_week REAL,
    drought_tolerant BOOLEAN DEFAULT 0,

    days_to_maturity INTEGER,
    mature_height_inches INTEGER,
    mature_spread_inches INTEGER,
    spacing_inches INTEGER,

    soil_ph_min REAL,
    soil_ph_max REAL,
    frost_tolerant BOOLEAN DEFAULT 0,

    companion_plants TEXT,             -- Comma-separated
    incompatible_plants TEXT,
    common_pests TEXT,
    notes TEXT,

    data_source TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plant_library_type ON plant_library(plant_type);
CREATE INDEX idx_plant_library_common_name ON plant_library(common_name);
```

---

## plant_schedules

Zone-specific planting schedules. Multiple rows per plant for different climate zones. Months are integers 1-12.

**Why separate:** Tomatoes in zone 3 plant in June, zone 9 plants in March. Normalizing this allows fast queries without TEXT parsing.

```sql
CREATE TABLE plant_schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plant_id INTEGER NOT NULL REFERENCES plant_library(id) ON DELETE CASCADE,

    min_zone INTEGER NOT NULL,
    max_zone INTEGER NOT NULL,

    plant_month_start INTEGER NOT NULL,
    plant_month_end INTEGER NOT NULL,
    harvest_month_start INTEGER,
    harvest_month_end INTEGER,
    remove_month INTEGER,              -- NULL = perennial

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_schedules_plant ON plant_schedules(plant_id);
CREATE INDEX idx_schedules_zone_plant ON plant_schedules(min_zone, max_zone, plant_month_start);
```

**Query pattern:**
```sql
-- What can I plant in zone 7 this month?
SELECT pl.*, ps.* FROM plant_library pl
JOIN plant_schedules ps ON pl.id = ps.plant_id
WHERE ps.min_zone <= 7 AND ps.max_zone >= 7
  AND ps.plant_month_start <= 5 AND ps.plant_month_end >= 5;
```

---

## garden_reports

Personalized gardening reports generated for users. Can be viewed via web or sent via email.

```sql
CREATE TABLE garden_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    content TEXT NOT NULL,                 -- Generated report content
    report_type TEXT NOT NULL,             -- 'daily', 'weekly'

    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    email_sent BOOLEAN NOT NULL DEFAULT 0,
    email_sent_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reports_user ON garden_reports(user_id, created_at DESC);
CREATE INDEX idx_reports_period ON garden_reports(user_id, period_start);
```

---

## messages

Conversation history between users and the AI assistant. Stores all messages for context and chat history.

```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    role TEXT NOT NULL,                    -- 'user' or 'assistant'
    content TEXT NOT NULL,                 -- Message content

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_user ON messages(user_id, created_at DESC);
```

**Query patterns:**
```sql
-- Get recent conversation for a user (last 50 messages)
SELECT * FROM messages
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 50;
```
