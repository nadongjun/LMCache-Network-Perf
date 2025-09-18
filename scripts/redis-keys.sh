#!/usr/bin/env bash
set -euo pipefail
docker exec -it lmcache_redis redis-cli KEYS '*'
