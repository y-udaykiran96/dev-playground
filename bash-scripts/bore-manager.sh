#!/bin/bash

PID_FILE="$HOME/bore-logs/bore.pid"
EXPOSE_PORTS=(8080 8444 8443)
mkdir -p "$HOME/bore-logs"

bore_expose_port() {
    BORE_COMMAND="/opt/homebrew/bin/bore local $1 --to ec2-54-243-25-175.compute-1.amazonaws.com -p 3$1"
    LOG_FILE="$HOME/bore-logs/bore-$1.log"
    echo "---- Command:$BORE_COMMAND  |  Logs:$LOG_FILE ----"
    $BORE_COMMAND >> "$LOG_FILE" 2>&1 &
    echo $! >> "$PID_FILE"
    echo "Bore tunnel started on port:$1"
    sleep 2  
    tail -n 10 "$LOG_FILE"
    echo "---------------------------------------------------"
}

start_bore() {
    echo "Starting Bore tunnels... PWD:$PWD"
    
    if [ -n "$1" ]; then
        bore_expose_port "$1"
    else
        # If no argument is provided, loop through EXPOSE_PORTS array
        for PORT in "${EXPOSE_PORTS[@]}"; do
            bore_expose_port "$PORT"
        done
    fi

    echo "Bore tunnels started successfully."
}

stop_bore() {
    if [[ -f "$PID_FILE" ]]; then
        echo "Stopping Bore tunnels..."
        while read -r pid; do
            kill "$pid"
        done < "$PID_FILE"
        rm -f "$PID_FILE"
        echo "Bore tunnels stopped."
    else
        echo "No Bore process running."
    fi
}

status_bore() {
    if [[ -f "$PID_FILE" ]]; then
        echo "Bore is running with PIDs:"
        cat "$PID_FILE"
    else
        echo "Bore is not running."
    fi
}

case "$1" in
    start)
        start_bore $2
        ;;
    stop)
        stop_bore
        ;;
    status)
        status_bore
        ;;
    restart)
        stop_bore
        start_bore
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

