#!/bin/bash
    sed -i "s|var streamUrl = '.*';|var streamUrl = 'REPLACE_WITH_STREAM_URL';|" "./template.html"

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null
}

# Function to handle cleanup actions
cleanup() {
    # Restore the placeholder value in template.html
    sed -i "s|var streamUrl = '.*';|var streamUrl = 'REPLACE_WITH_STREAM_URL';|" "./template.html"

    # Stop services (you can add your service stopping logic here)
    sudo ./stop_services.sh

    exit 0
}

# Trap signals and call the cleanup function when any of these signals are received
trap 'cleanup' SIGINT SIGTERM SIGHUP

# Check for ffmpeg
if command_exists ffmpeg; then
    echo "ffmpeg is installed."
else
    echo "ffmpeg is not installed. Installing ffmpeg..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
fi

# If all dependencies are satisfied, continue with the script

# Run ffmpeg in the background and log its output
echo "Starting ffmpeg..."
sudo ./run_ffmpeg.sh > ./ffmpeg.log 2>&1 &

# Ask the user if they want to stop services
echo "Services are running. Do you want to stop them? (y/n): "
read stop_answer
if [ "$stop_answer" = "y" ]; then
    cleanup
fi
