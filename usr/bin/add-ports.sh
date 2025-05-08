#!/bin/sh

set -eu

interfaces=$(ls /sys/class/net)

echo "Listing LAN ports..."
lan_ports=""

for iface in $interfaces; do
  case "$iface" in
    lan*)
      lan_ports="$lan_ports $iface"
      ;;
  esac
done

if [ -z "$lan_ports" ]; then
  echo "Error: No LAN ports found. Aborting..." >&2
  exit 1
fi

# Sort lan ports (e.g., lan1 lan2 lan10 properly)
sorted_ports=$(echo "$lan_ports" | tr ' ' '\n' | sort -V)

for port in $sorted_ports; do
  echo "$port"
done

# Use provided bridge name or default
br="${1:-br0}"
echo "Adding ports to bridge '$br'..."

port_number=1
for port in $sorted_ports; do
  if ovs-vsctl list-ports "$br" | grep -qx "$port"; then
    echo "Skipping $port (already exists on $br)"
    continue
  fi

  echo "Adding $port to $br with ofport_request=$port_number..."
  ovs-vsctl add-port "$br" "$port" -- set Interface "$port" ofport_request="$port_number"
  port_number=$((port_number + 1))
done
