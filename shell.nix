#! /usr/bin/env nix-shell
{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  }
}:
let
  # Import unstable channel for claude-code and latest tools
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Go toolchain - using latest stable version
    go_1_24
    gopls              # Go language server for IDE support
    gotools            # Additional Go tools (goimports, etc.)

    # Database tools
    goose              # Database migrations
    sqlc               # Type-safe SQL query generation
    sqlite             # SQLite database (latest available in nixpkgs)
    sqlite-interactive # Interactive SQLite shell

    # Template & frontend tools
    templ              # Go template compiler
    tailwindcss        # Tailwind CSS CLI

    # Development tools
    air                # Live reload for Go

    # Environment & secrets
    direnv             # Auto-load environment variables

    # Utilities
    curl               # API testing
    jq                 # JSON processing

  ] ++ [
    unstable.claude-code
  ];

  # Shell hook - runs when entering the shell
  shellHook = ''
    echo "🌱 Daily Garden Guide Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Go:         $(go version | cut -d' ' -f3)"
    echo "templ:      $(templ version 2>/dev/null || echo 'installed')"
    echo "sqlc:       $(sqlc version 2>/dev/null || echo 'installed')"
    echo "air:        $(air -v 2>/dev/null | head -n1 || echo 'installed')"
    echo "goose:      $(goose -version 2>/dev/null || echo 'installed')"
    echo ""

    # Helper functions
    dev() {
      echo "🚀 Starting development server with live reload..."
      air
    }

    db-migrate() {
      echo "📊 Running migrations..."
      goose -dir db/migrations sqlite3 ./dailygardenguide.db up
    }

    db-rollback() {
      echo "⏪ Rolling back one migration..."
      goose -dir db/migrations sqlite3 ./dailygardenguide.db down
    }

    db-reset() {
      echo "🔄 Resetting database..."
      rm -f dailygardenguide.db
      goose -dir db/migrations sqlite3 ./dailygardenguide.db up
    }

    gen() {
      echo "⚙️  Generating code..."
      templ generate
      sqlc generate
    }

    test() {
      echo "🧪 Running tests..."
      go test ./...
    }

    build() {
      echo "🔨 Building binary..."
      go build -o bin/dailygardenguide ./cmd/server
    }

    export -f dev db-migrate db-rollback db-reset gen test build

    echo "📝 Available commands:"
    echo "  dev         - Start development server with live reload"
    echo "  db-migrate  - Run database migrations"
    echo "  db-rollback - Roll back last migration"
    echo "  db-reset    - Reset database (destructive)"
    echo "  gen         - Generate templ + sqlc code"
    echo "  test        - Run tests"
    echo "  build       - Build production binary"
    echo ""

    # Set up direnv if .envrc exists
    if [ -f .envrc ]; then
      eval "$(direnv hook bash)"
      echo "✓ direnv configured (.envrc found)"
    else
      echo "ℹ Create .envrc file for environment variables"
    fi

    # Set GOPATH if not set
    export GOPATH="''${GOPATH:-$HOME/go}"
    export PATH="$GOPATH/bin:$PATH"

    echo ""
  '';

  # Allow unsafe/experimental features
  NIX_CONFIG = ''
    experimental-features = nix-command flakes
    allow-import-from-derivation = true
  '';

  # Environment variables for development
  ANTHROPIC_API_KEY = "";  # Set in .envrc
  OPENWEATHER_API_KEY = ""; # Set in .envrc
  DATABASE_URL = "file:./dailygardenguide.db";
  PORT = "8080";
}
