#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Application properties file path
PROPERTIES_FILE_PATH="$SCRIPT_DIR/application.properties"

# Check if properties file exists
if [ ! -f "$PROPERTIES_FILE_PATH" ]; then
    echo "Error: $PROPERTIES_FILE_PATH not found"
    exit 1
fi

# Read application properties
APPLICATION_JAR=$(grep "^application\.jar=" "$PROPERTIES_FILE_PATH" | cut -d'=' -f2)

# Check if application jar exists
if [ ! -f "$APPLICATION_JAR" ]; then
    echo "Error: $APPLICATION_JAR not found"
    exit 1
fi

# Start Spring Boot application
start() {
    echo "Starting Spring Boot application..."
    nohup java -jar "$APPLICATION_JAR" >/dev/null 2>&1 &
    echo "Application started."
}

# Stop Spring Boot application
stop() {
    echo "Stopping Spring Boot application..."
    PID=$(ps aux | grep "$APPLICATION_JAR" | grep -v grep | awk '{print $2}')
    if [ -n "$PID" ]; then
        for i in {1..10}
        do
            kill "$PID"
            sleep 10
            if ! ps -p "$PID" > /dev/null
            then
                echo "Application stopped."
                return 0
            fi
        done
        kill -9 "$PID"
        echo "Application stopped with -9 signal."
    else
        echo "Application not running."
    fi
}

# Check command line arguments
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
