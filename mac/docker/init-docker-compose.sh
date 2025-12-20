echo "== Setup docker compose plugin =="

# docker-compose が brew で入っているか確認
if brew list docker-compose >/dev/null 2>&1; then
  mkdir -p "$HOME/.docker/cli-plugins"

  COMPOSE_BIN="$(brew --prefix docker-compose)/bin/docker-compose"
  TARGET="$HOME/.docker/cli-plugins/docker-compose"

  if [ -L "$TARGET" ] || [ -e "$TARGET" ]; then
    echo "docker-compose plugin already exists. Skipping."
  else
    ln -s "$COMPOSE_BIN" "$TARGET"
    echo "docker-compose plugin linked."
  fi
else
  echo "docker-compose is not installed. Skipping docker compose plugin setup."
fi
