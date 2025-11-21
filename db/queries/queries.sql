-- name: GetAllGardensByUserId :many
SELECT * FROM  gardens WHERE  user_id = ?;

-- name: CreateUser :one
INSERT INTO users (
  email,
  password_hash,
  first_name,
  zip_code,
  hardiness_zone,
  timezone,
  email_time,
  email_frequency,
  email_enabled
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
RETURNING *;

-- name: CreateGarden :one
INSERT INTO gardens (
  user_id,
  name,
  garden_type,
  size_sqft,
  sun_hours
) VALUES (?, ?, ?, ?, ?)
RETURNING *;

