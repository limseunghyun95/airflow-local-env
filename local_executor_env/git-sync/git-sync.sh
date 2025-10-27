#!/bin/bash
echo 'Start git-sync.sh'

# --- 환경 변수 ---
GIT_REPO=${GIT_REPO:-'---'}
GIT_BRANCH=${GIT_BRANCH:-'main'}
GIT_TYPE=${GIT_TYPE:-'gitlab'}
GIT_USER=${GIT_USER:-'---'}
TOKEN_NAME=${TOKEN_NAME:-'---'}
TOKEN=${TOKEN:-'glpat-XXXX'}
SYNC_INTERVAL=${SYNC_INTERVAL:-60}

TARGET_DIR=${TARGET_DIR:-'/dags'}
TMP_DIR=${TMP_DIR:-'/tmp/git-sync'}

GIT_URL="https://${TOKEN_NAME}:${TOKEN}@${GIT_TYPE}.com/${GIT_USER}/${GIT_REPO}.git"
echo "Git URL: $GIT_URL"

mkdir -p "$TARGET_DIR"
mkdir -p "$TMP_DIR"

# --- Git clone or update ---
if [ ! -d "$TMP_DIR/.git" ]; then
    echo "No git repo found in $TMP_DIR — cloning..."
    git clone --branch "$GIT_BRANCH" "$GIT_URL" "$TMP_DIR"
else
    echo "Existing repo found in $TMP_DIR — fetching updates..."
    cd "$TMP_DIR"
    git fetch origin "$GIT_BRANCH" || echo "Fetch failed"
    git reset --hard "origin/$GIT_BRANCH" || echo "Reset failed"
fi

# --- DAGs sync function ---
sync_dags() {
    if [ -d "$TMP_DIR/dags" ]; then
        echo "Syncing dags/ to $TARGET_DIR"
        rsync -av --delete "$TMP_DIR/dags/" "$TARGET_DIR/"
    else
        echo "Warning: no dags/ directory found in repository"
    fi
}

# 최초 동기화
sync_dags

# --- 주기적 sync ---
cd "$TMP_DIR"
while true; do
    git fetch origin "$GIT_BRANCH" || echo "Fetch failed"
    git reset --hard "origin/$GIT_BRANCH" || echo "Reset failed"
    
    sync_dags
    
    echo "Synced at $(date)"
    sleep "$SYNC_INTERVAL"
done
