#!/usr/bin/env bash
# ============================================================
#  بث فارغ (شاشة سوداء + صوت صامت) على Restream
# ============================================================
set -euo pipefail

RTMP_URL="rtmp://live.restream.io/live/re_12000328_event11d497e43c154270ae00c867bf7d2225"
WIDTH=1920
HEIGHT=1080
FPS=60

# اختيار الترميز: تلقائي NVENC إذا كان GPU NVIDIA متاح، وإلا libx264 ultrafast
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q h264_nvenc; then
  VCODEC="h264_nvenc -preset p1 -tune ll"
  echo "==> باستخدام NVENC (تسريع GPU - صفر ضغط على المعالج)"
else
  VCODEC="libx264 -preset ultrafast -tune zerolatency"
  echo "==> باستخدام libx264 ultrafast (بدون GPU)"
fi

ffmpeg -re \
  -f lavfi -i "color=c=black:s=${WIDTH}x${HEIGHT}:r=${FPS}" \
  -f lavfi -i "anullsrc=r=44100:cl=stereo" \
  -c:v ${VCODEC} \
  -b:v 4500k -maxrate 6000k -bufsize 8000k \
  -pix_fmt yuv420p -g $((FPS*2)) \
  -c:a aac -b:a 128k -ar 44100 -ac 2 \
  -f flv "$RTMP_URL"
