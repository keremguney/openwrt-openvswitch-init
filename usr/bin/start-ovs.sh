#!/bin/bash
set -e
set -u

echo "Creating required directories..."
mkdir -p /var/run/openvswitch
chmod 755 /var/run/openvswitch
chown root:root /var/run/openvswitch
mkdir -p /etc/openvswitch

echo "Creating OVS database (ignore if already exists/locked)..."
if [ ! -f /etc/openvswitch/conf.db ]; then
    ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema || true
else
    echo "Database already exists. Skipping creation."
fi

echo "Starting ovsdb-server..."
if [ -f /var/run/openvswitch/ovsdb-server.pid ] && kill -0 $(cat /var/run/openvswitch/ovsdb-server.pid) 2>/dev/null; then
    echo "Warning: ovsdb-server is already running (pid $(cat /var/run/openvswitch/ovsdb-server.pid)). Skipping start."
else
    ovsdb-server --remote=punix:/var/run/openvswitch/db.sock \
                 --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                 --pidfile --detach
fi

echo "Initializing OVS database..."
ovs-vsctl --no-wait init

echo "Starting ovs-vswitchd..."
if [ -f /var/run/openvswitch/ovs-vswitchd.pid ] && kill -0 $(cat /var/run/openvswitch/ovs-vswitchd.pid) 2>/dev/null; then
    echo "Warning: ovs-vswitchd is already running (pid $(cat /var/run/openvswitch/ovs-vswitchd.pid)). Skipping start."
else
    ovs-vswitchd --pidfile --detach
fi

echo "Open vSwitch started successfully."

