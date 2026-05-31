# LU Reels Video Host

Public MP4 hosting for the local LU reels pipeline.

Hermes/Mark-XXXV copies generated reels into `reels/`, commits them, pushes to GitHub, and gives Instagram Graph API a public `raw.githubusercontent.com` URL.

Expected `.env` values in `D:\LY\Mark-XXXV-main\.env`:

```env
LU_REELS_REPO_DIR=C:\Users\Dell\.openclaw\workspace\lu-reels-video-host
LU_REELS_PUBLIC_BASE_URL=https://raw.githubusercontent.com/OWNER/lu-reels-video-host/main/reels
```

Do not put API keys or private files here. This repo should stay public because Instagram must fetch the `.mp4` by HTTPS.

