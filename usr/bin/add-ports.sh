
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

for port in $lan_ports; do
  echo "$port"
done

# Use provided bridge name or default
br="${1:-br0}"
echo "Adding ports to bridge '$br'..."

for port in $lan_ports; do
  # Check if port already exists on the bridge
  if ovs-vsctl list-ports "$br" | grep -qx "$port"; then
    echo "Skipping $port (already exists on $br)"
    continue
  fi

  echo "Adding $port to $br..."
  ovs-vsctl add-port "$br" "$port"
done

