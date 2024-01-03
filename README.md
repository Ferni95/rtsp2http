*WIP* and in testing for standard sharing, currently it is very coupled with my current setup.

Note this is a fork from: https://github.com/nullvoid413/RTSP2HTTP making it local only(remote access can be done via VPN)

# RTSP2HTTP
This project is intended to convert RTSP streams to HTTP, very useful to convert IP cameras and been able to use on Klipper or Octoprint.

*If you detect any bug/problem using the script, open an issue on Github and explain the steps where it happened and how, so I can reproduce and fix them.*

## Installation

Install requirements to use RTSP2HTTP:

NGINX(Installed with Klipper)

FFMPEG:
```bash
sudo apt-get update && sudo apt-get install -y ffmpeg
```

## Setup

1. Download this repo

2. Set Executable Permissions:

```bash
sudo chmod +x run_ffmpeg.sh
```

3. Configure Camera Streams:

*Input the RTSP link for each of your cameras. Remember, each line in this file corresponds to one camera. To configure multiple cameras, simply add more lines with their respective RTSP links.*
```bash
Edit the stream_config.conf file that you downloaded from this Repo 
```

4. Initiate Streaming Process:

*Start the streaming process by running the start_streaming.sh script. Execute this command:*
```bash
sudo ./run_ffmpeg.sh
```

5. Copy to NGINX file the camtest file

- Review the location of your config/script on camtest file
- Copy camtest file to /etc/nginx/sites-available
```bash
ln -s /etc/nginx/sites-available/camtest /etc/nginx/sites-enabled
nginx -t
systemctl restart nginx
```

6. Check your new webpage and enjoy your IP camera feed.

Additional Notes:

*Ensure that your system meets all the necessary prerequisites for running the project.
For any troubleshooting or additional configurations, refer to the project's documentation or contact support.
By following these steps, you should be able to successfully set up and enjoy the Camera Streaming.
For further assistance or inquiries, please do not hesitate to reach out.*



