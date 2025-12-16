#!/bin/bash

# Cleanup function to kill background processes
cleanup() {
    echo "Shutting down..."
    [ -n "$AGENT_PID" ] && kill $AGENT_PID 2>/dev/null
    [ -n "$BRIDGE_PID" ] && kill $BRIDGE_PID 2>/dev/null
    exit 0
}

# Trap SIGINT (Ctrl+C) and call cleanup
trap cleanup SIGINT

# Start Micro XRCE-DDS agent in background
MicroXRCEAgent udp4 -p 8888 &
AGENT_PID=$!

# Start ROS 2 bridge in background
ros2 run ros_gz_bridge parameter_bridge --ros-args -p config_file:=$(pwd)/Tools/simulation/gz/models/x500_gzlidar/bridge_config.yaml &
BRIDGE_PID=$!

# Start PX4
PX4_SYS_AUTOSTART=4001 PX4_GZ_WORLD=default  PX4_GZ_MODEL_POSE="-5,0,0,0,0,0" PX4_SIM_MODEL=gz_x500_gzlidar ./build/px4_sitl_default/bin/px4

# Cleanup when PX4 exits normally
cleanup
