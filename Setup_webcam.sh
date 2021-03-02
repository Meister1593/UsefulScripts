sudo modprobe v4l2loopback
read -p "Enter address: " address
sudo ffmpeg -i "http://$address:8080/video" -map 0:v -vcodec rawvideo -vf format=yuv420p -f v4l2 /dev/video0
