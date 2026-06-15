const http = require('http');
const fs = require('fs');
const path = require('path');

const port = Number(process.env.PORT || 8080);
const root = __dirname;

const pages = {
  rotateSeconds: 10,
  pages: [
    { title: 'Router', url: '/hud/router.svg' },
    { title: 'BORG', url: '/hud/borg.svg' },
    { title: 'Services', url: '/hud/services.svg' },
    { title: 'Network', url: '/hud/network.svg' }
  ]
};

function send(res, code, type, body) {
  res.writeHead(code, {
    'Content-Type': type,
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*'
  });
  res.end(body);
}

http.createServer((req, res) => {
  if (req.url === '/api/pages') {
    return send(res, 200, 'application/json', JSON.stringify(pages, null, 2));
  }

  if (req.url.startsWith('/hud/')) {
    const file = path.join(root, req.url);
    if (!file.startsWith(path.join(root, 'hud'))) return send(res, 403, 'text/plain', 'Forbidden');
    if (!fs.existsSync(file)) return send(res, 404, 'text/plain', 'Not found');
    return send(res, 200, 'image/svg+xml', fs.readFileSync(file));
  }

  send(res, 200, 'text/plain', 'VTX Roku HUD sample server. Try /api/pages');
}).listen(port, '0.0.0.0', () => {
  console.log(`VTX Roku HUD sample server listening on http://0.0.0.0:${port}`);
});
