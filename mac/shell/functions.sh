sencha() {
  local container_name="sencha-cmd-$$"
  local colima_profile="amd"
  local started_colima=0

  # Colima(vz) 設定
  local colima_arch="aarch64"
  local colima_vm_type="vz"
  local colima_vz_rosetta="--vz-rosetta"
  local colima_mount_type="virtiofs"
  local colima_mount_inotify="--mount-inotify"
  local colima_cpu="6"
  local colima_mem="12"
  local colima_disk="60"

  # ---- Java heap (Closure/ES transpile 対策) ----
  # 必要ならここだけ増やす（例: Xmx6144m など）
  local java_xms="1024m"
  local java_xmx="8192m"
  local java_opts="-Xms${java_xms} -Xmx${java_xmx}"

  # ---- 既存のsencha-cmdコンテナをクリーンアップ ----
  docker ps -a --format '{{.Names}}' | grep '^sencha-cmd-' | while read -r name; do
    docker stop "$name" >/dev/null 2>&1
    docker rm -f "$name" >/dev/null 2>&1
  done

  # ---- Colima start (必要な場合のみ) ----
  if ! colima status --profile "$colima_profile" 2>/dev/null | grep -q Running; then
    echo "[sencha] starting colima profile: $colima_profile (vz+rosetta)"
    colima start --profile "$colima_profile" \
      --arch "$colima_arch" \
      --vm-type "$colima_vm_type" \
      $colima_vz_rosetta \
      --mount-type "$colima_mount_type" \
      $colima_mount_inotify \
      --cpu "$colima_cpu" --memory "$colima_mem" --disk "$colima_disk" \
      >/dev/null
    started_colima=1
  fi

  cleanup() {
    # コンテナ後始末（名前で管理）
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
      # タイムアウト1秒で停止を試みて、すぐに強制削除
      docker stop -t 1 "$container_name" >/dev/null 2>&1
      docker rm -f "$container_name" >/dev/null 2>&1
    fi

    # Colima stop（自分で起動した場合のみ）
    if [ "$started_colima" -eq 1 ]; then
      echo "[sencha] stopping colima profile: $colima_profile"
      colima stop --profile "$colima_profile" >/dev/null
    fi
  }

  # 終了経路を全部拾う（成功/失敗/CTRL+C/kill）
  trap 'cleanup' EXIT
  trap 'cleanup; exit 130' INT
  trap 'cleanup; exit 143' TERM

  docker run \
    --platform=linux/amd64 \
    --init \
    --name "$container_name" \
    -e "JAVA_OPTS=${java_opts}" \
    -e "_JAVA_OPTIONS=${java_opts}" \
    -e "JAVA_TOOL_OPTIONS=${java_opts}" \
    -e "SENCHA_JAVA_OPTS=${java_opts}" \
    -p 1841:1841 \
    -v "$(pwd)":/app \
    -w /app \
    rockmagicnet/sencha-cmd:6.6.0 \
    "$@"

  return $?
}
