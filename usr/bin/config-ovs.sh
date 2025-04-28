#!/bin/sh

DEVICE_INFO_FILE="/etc/deviceInfo"
APPS_VERSION_FILE="/usr/and/version"

export OVS_MFR_DESC="Andasis"
echo "Set OVS_MFR_DESC to: $OVS_MFR_DESC"

if [ -f "$DEVICE_INFO_FILE" ]; then
    DEVICE_TYPE=$(grep -i "device-type-name" "$DEVICE_INFO_FILE" | cut -d '=' -f 2)
    
    if [ -n "$DEVICE_TYPE" ]; then
        export OVS_HW_DESC="$DEVICE_TYPE"
        
        echo "Set OVS_HW_DESC to: $DEVICE_TYPE"
        
    else
        echo "Could not find device type in $DEVICE_INFO_FILE"
        exit 1
    fi
else
    echo "Device info file not found: $DEVICE_INFO_FILE"
    exit 1
fi


if [ -f "$APPS_VERSION_FILE" ]; then
    APPS_VER=$(grep -i "APPS_VER" "$APPS_VERSION_FILE" | cut -d '=' -f 2)

    if [ -n "$APPS_VER" ]; then
        export OVS_SW_DESC="$APPS_VER"
        echo "Set OVS_SW_DESC to: $APPS_VER"
    else
        echo "Could not find APPS_VER in $APPS_VERSION_FILE"
        exit 1
    fi
else
    echo "Apps version file not found: $APPS_VERSION_FILE"
    exit 1
fi

export OVS_SERIAL_DESC="example serial number"
echo "Set OVS_SERIAL_DESC to: $OVS_SERIAL_DESC"

export OVS_DP_DESC="example description"
echo "Set OVS_DP_DESC to: $OVS_DP_DESC"

