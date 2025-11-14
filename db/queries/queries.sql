-- name: GetAllGardensByUserId :many
SELECT
  *
FROM
  gardens
WHERE
  user_id = ?;
