#!/bin/bash

# Path to the configuration file
config_file="./stream_config.conf"

# Path to the HTML template
html_template="./template.html"

# Directory containing the HTML files
html_directory="./html"
video_directory="./html/HLS" # Update with the path where .ts video files are generated
metadata_file="./html/camera_metadata.json"

# Function to start an ffmpeg stream
start_ffmpeg_stream() {
    local url=$1
    local stream_number=$2
    local output_file="${video_directory}/stream$stream_number.m3u8" # Changed file extension to .m3u8
    local thumbnail_file="${html_directory}/camera${stream_number}.jpg"

    echo $url
    echo $thumbnail_file
    echo $stream_number

    # Start ffmpeg to generate the stream and m3u8 file
    ffmpeg -rtsp_transport tcp -i "$url" -c:v copy -c:a copy -f hls -hls_time 2 -hls_list_size 3 -hls_flags delete_segments -hls_segment_filename "${video_directory}/stream${stream_number}-%03d.ts" "$output_file" 2> "${output_file}.log" &

    sleep 10
    # Generate a thumbnail for the stream
    generate_thumbnail "$output_file" "$thumbnail_file"

    # Add camera metadata to the metadata file
    echo "{\"camera\": $stream_number, \"video_file\": \"stream$stream_number.m3u8\"}" >> "$metadata_file"

    # Generate thumbnails and camera links for index.html
    generate_html_content "$stream_number" "$thumbnail_file"
}

# Function to generate a thumbnail for a video file
generate_thumbnail() {
    local video_file="$1"
    local thumbnail_file="$2"

    # Use ffmpeg to generate the thumbnail
    if ffmpeg -i "$video_file" -vf "thumbnail,scale=150:150" -frames:v 1 -update 1 "$thumbnail_file" -y; then
        echo "Thumbnail generated for $video_file"
    else
        echo "Error generating thumbnail for $video_file"
    fi
}

# Function to create an HTML file for each stream
create_html_file() {
    local stream_number=$1
    local html_file="$html_directory/camera${stream_number}.html"
    cp "$html_template" "$html_file"
}

# Function to generate HTML content for index.html
generate_html_content() {
    local stream_number=$1
    local thumbnail_file="$2"

    cat >> "$html_directory/index.html" <<EOF
    <div class="camera-thumbnail">
        <a href="camera${stream_number}.html">
            <img src="camera${stream_number}.jpg" alt="Camera $stream_number Thumbnail" width="150" height="150">
        </a>
        <a href="camera${stream_number}.html">Camera $stream_number</a>
    </div>
EOF
}

# Remove the existing metadata file
rm -f "$metadata_file"

# Clean HTML directories
rm -rf "${html_directory}/"
mkdir -p $video_directory

# Create or overwrite index.html with the initial HTML structure
cat > "$html_directory/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Camera Thumbnails</title>
    <style>
        /* Add your CSS styles here for dark theme and responsiveness */
        body {
            background-color: #1a1a1a;
            color: #ffffff;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-around;
            align-items: center;
            min-height: 100vh;
        }

        .camera-thumbnail {
            width: 200px;
            height: 200px;
            margin: 10px;
            background-color: #333333;
            border-radius: 10px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .camera-thumbnail:hover {
            background-color: #555555;
        }

        .camera-thumbnail a {
            text-decoration: none;
            color: #ffffff;
            font-size: 18px;
            text-align: center;
            margin-top: 10px;
        }
    </style>
</head>
<body>
EOF

# Read each URL from the configuration file, start a stream, and create an HTML file
i=0
# DEBUG
#cat "$config_file"
while IFS= read -r url || [[ -n "$url" ]]; do
    echo $url
    ((i++))
    start_ffmpeg_stream "$url" "$i"
    create_html_file "$i"
    
done < "$config_file"

echo $i

# Wait for a moment to allow ffmpeg processes to start
sleep 5

# Check each ffmpeg process for errors
for j in $(seq 1 $i); do
    if grep -q 'error' "$video_directory/stream${j}.m3u8.log"; then
        echo "ffmpeg for stream${j} encountered an error."
    else
        echo "ffmpeg for stream${j} is running."
    fi
done

# Close the index.html file
echo "</body></html>" >> "$html_directory/index.html"
