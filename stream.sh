#!/usr/bin/env bash
# ============================================================
#  بث فيديو مباشر على Restream باستخدام FFmpeg
#  -c copy (نسخ بدون ترميز) => صفر ضغط على المعالج
# ============================================================
set -euo pipefail

# ---------- الإعدادات (عدّل حسب حاجتك) ----------
VIDEO_URL="https://youtu.be/dj6iermvLtU"          # رابط الفيديو
RTMP_URL="rtmp://live.restream.io/live/re_12000328_event11d497e43c154270ae00c867bf7d2225"
LOOP_ENABLED="1"    # 1 = يعيد البث باستمرار ، 0 = مرة واحدة فقط
# --------------------------------------------------

echo "==> [1/3] التأكد من وجود t-dlp و ffmpeg"
command -v yt-dlp   >/dev/null 2>&1 || { echo "ثبّت yt-dlp:  pip install yt-dlp"; exit 1; }
command -v ffmpeg   >/dev/null 2>&1 || { echo "ثبّت ffmpeg من موقع ffmpeg.org"; exit 1; }

echo "==> [2/3] تحميل الفيديو بأعلى جودة متاحة"
yt-dlp -f "best[height<=1080]/best" --no-part -o "video.mp4" "$VIDEO_URL"

LOOP_FLAG=""
[ "$LOOP_ENABLED" = "1" ] && LOOP_FLAG="-stream_loop -1"

echo "==> [3/3] بدء البث بـ -c copy (بدون إعادة ترميز)"
# ملاحظة: إذا كان الملف VP9/Opus بدّل الأسطر لتحويل الصيغة
ffmpeg $LOOP_FLAG -re -i video.mp4 \
  -c:v copy -c:a copy \
  -f flv "$RTMP_URL"
