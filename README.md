# VTX Roku HUD

A simple Roku Developer Mode HUD app for showing a rotating set of monitoring dashboard images from a server on your home network.

This is intentionally **not** a full web browser. Roku apps do not provide a normal Chromium/WebView browser surface. The reliable pattern is:

```text
Monitoring dashboards -> server-rendered PNG/JPEG snapshots -> Roku full-screen rotator
```

## Features

- Full-screen image HUD
- Gets page list from your local server
- Auto-rotates pages
- Remote controls:
  - Right / Fast Forward: next page
  - Left / Rewind: previous page
  - Play/Pause: pause or resume rotation
  - OK: refresh/re-show current page
  - Star `*`: settings
- Settings screen stores the HUD server URL in Roku registry

## Expected server response

The app requests:

```text
http://YOUR-SERVER:PORT/api/pages
```

Return JSON like this:

```json
{
  "rotateSeconds": 15,
  "pages": [
    { "title": "Router", "url": "/hud/router.png" },
    { "title": "BORG", "url": "/hud/borg.png" },
    { "title": "Services", "url": "/hud/services.png" },
    { "title": "Network", "url": "/hud/network.png" }
  ]
}
```

Relative URLs are resolved against the server URL.

## Sideload

1. Enable Developer Mode on the Roku.
2. Clone this repo.
3. Zip the app contents, not the parent folder:

```powershell
.\scripts\package.ps1
```

4. Open the Roku developer installer in a browser:

```text
http://ROKU-IP
```

5. Upload `dist/VTX-Roku-HUD.zip`.

## Test server

A tiny Node.js static server is included under `server/sample-node`.

```powershell
cd server\sample-node
node server.js
```

Then set the Roku app server URL to:

```text
http://YOUR-PC-IP:8080
```

## Notes

For real dashboards, have the server render your web pages to images. Playwright, Puppeteer, Grafana image renderer, or a Maestro/BORG image endpoint would all work.
