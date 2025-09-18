#!/usr/bin/env bash
set -euo pipefail

# Usage: ./latency.sh <RTT_MS>

RTT_MS="${1:-0}"
ONEWAY_MS=$(awk "BEGIN {printf \"%.3f\", ${RTT_MS}/2.0}")

REDIS_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lmcache_redis)
VLLM_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lmcache_vllm)

get_iface() {
  local c="$1"
  docker exec "$c" sh -lc "ip route show default 2>/dev/null | awk '{print \$5; exit}' || echo eth0"
}

apply_one_way_prio_filter() {
  local c="$1" peer_ip="$2"
  local iface
  iface="$(get_iface "$c")"

  docker exec "$c" tc qdisc del dev "$iface" root 2>/dev/null || true

  # root prio (3 bands)
  docker exec "$c" tc qdisc add dev "$iface" root handle 1: prio bands 3

  docker exec "$c" tc qdisc add dev "$iface" parent 1:1 handle 10: netem delay "${ONEWAY_MS}ms"
  docker exec "$c" tc qdisc add dev "$iface" parent 1:3 handle 30: netem delay 0ms

  docker exec "$c" tc filter add dev "$iface" parent 1: protocol ip prio 1 u32 match ip dst "${peer_ip}"/32 flowid 1:1
  docker exec "$c" tc filter add dev "$iface" parent 1: protocol ip prio 2 u32 match ip dst 0.0.0.0/0 flowid 1:3

  docker exec "$c" tc qdisc show dev "$iface" || true
  docker exec "$c" tc filter show dev "$iface" parent 1: || true
}

echo "[latency.sh] RTT=${RTT_MS}ms -> one-way=${ONEWAY_MS}ms"
echo "[latency.sh] redis=${REDIS_IP}, vllm=${VLLM_IP}"

apply_one_way_prio_filter lmcache_redis "$VLLM_IP"
apply_one_way_prio_filter lmcache_vllm "$REDIS_IP"