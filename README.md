# Daily Garden Guide

Daily personalized email recommendations for home gardeners based on their plants and local weather.

## Tech Stack

Go 1.23 • HTMX • TailwindCSS • SQLite • Claude API • OpenWeatherMap • AWS SES

## Setup

**Prerequisites:** Nix + direnv

```bash
# Enter project and allow direnv
cd dailygardenguide
direnv allow

# Add API keys to .envrc
export ANTHROPIC_API_KEY="sk-ant-xxx"
export OPENWEATHER_API_KEY="xxx"
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"

# Initialize and start
db-migrate
gen
dev
```

Visit http://localhost:8080

## Commands

- `dev` - Start with live reload
- `gen` - Generate templ + sqlc code
- `build` - Build production binary
- `test` - Run tests
- `db-migrate` / `db-rollback` / `db-reset` - Database migrations

## Project Structure

```
cmd/server/              # Entry point
internal/
  ├── handlers/          # HTTP routes
  ├── services/          # Business logic (AI, weather, email)
  ├── templates/         # Templ templates
  └── db/                # Generated sqlc code
db/
  ├── migrations/        # Goose migrations
  └── queries/           # SQL for sqlc
static/                  # CSS/JS assets
```

## Architecture

### Request Flow
User → Handler → Service → Database/APIs → Templ + HTMX response

### Plant Knowledge
- **Local library**: SQLite with 300-500 common plants (zones, requirements, seasons)
- **Claude API**: Conversational interface for setup and personalized recommendations
- **Custom plants**: AI can web scrape to add unlisted plants to user's garden
- Combines local speed/cost with AI intelligence

### Key Workflows
1. **Garden setup**: Claude-powered chat guides plant selection from local library
2. **Daily emails**: Cron job fetches weather, generates AI recommendations, sends via SES
3. **HTMX interactions**: Dynamic updates without JavaScript

## Database

### Migrations
```bash
goose -dir db/migrations create migration_name sql
db-migrate  # Run pending
db-rollback # Undo last
```

### Queries
Write SQL in `db/queries/*.sql`, run `gen` to create type-safe Go functions.

## Environment Variables

**Required:**
- `ANTHROPIC_API_KEY`
- `OPENWEATHER_API_KEY`
- `DATABASE_URL` (default: `file:./garden.db`)

**Optional:**
- `PORT` (default: 8080)
- `EMAIL_FROM`, `AWS_SES_REGION`
- `LOG_LEVEL` (default: info)

## Deployment

### Daily Email Cron
```bash
0 6 * * * /path/to/bin/dailygardenguide send-emails
```

### Database Backup
```bash
sqlite3 garden.db ".backup garden-backup-$(date +%Y%m%d).db"
```

## Troubleshooting

- **Database locked**: Enable WAL mode or use PostgreSQL for concurrent writes
- **Air not reloading**: Check `.air.toml` and `fs.inotify.max_user_watches`
- **Templates stale**: Run `gen` and restart Air

## Roadmap

**MVP (Current):**
Garden setup • Daily emails • Password auth • Plant management

**Future:**
Photo ID • Harvest tracking • Garden journal • Mobile app • Community
