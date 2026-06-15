const http = require('http');
const zlib = require('zlib');

const port = Number(process.env.PORT || 8080);

const pages = {
  rotateSeconds: 10,
  pages: [
    { title: 'Router', url: '/hud/router.png' },
    { title: 'BORG', url: '/hud/borg.png' },
    { title: 'Services', url: '/hud/services.png' },
    { title: 'Network', url: '/hud/network.png' }
  ]
};

const palette = {
  '/hud/router.png': [16, 24, 32],
  '/hud/borg.png': [20, 40, 20],
  '/hud/services.png': [40, 20, 30],
  '/hud/network.png': [16, 16, 40]
};

function send(res, code, type, body) {
  res.writeHead(code, {
    'Content-Type': type,
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*'
  });
  res.end(body);
}

function crc32(buf) {
  let c = ~0;
  for (const b of buf) {
    c ^= b;
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
  }
  return ~c >>> 0;
}

function chunk(type, data) {
  const t = Buffer.from(type);
  const len = Buffer.alloc(4);
  const crc = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])));
  return Buffer.concat([len, t, data, crc]);
}

function png(width, height, bg) {
  const raw = Buffer.alloc((width * 3 + 1) * height);
  for (let y = 0; y < height; y++) {
    const row = y * (width * 3 + 1);
    raw[row] = 0;
    for (let x = 0; x < width; x++) {
      const i = row + 1 + x * 3;
      const stripe = Math.floor(x / 80) % 2 === 0 ? 32 : 0;
      raw[i] = Math.min(bg[0] + stripe, 255);
      raw[i + 1] = Math.min(bg[1] + stripe, 255);
      raw[i + 2] = Math.min(bg[2] + stripe, 255);
    }
  }

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;  // bit depth
  ihdr[9] = 2;  // truecolor
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0))
  ]);
}

http.createServer((req, res) => {
  if (req.url === '/api/pages') {
    return send(res, 200, 'application/json', JSON.stringify(pages, null, 2));
  }

  if (palette[req.url]) {
    return send(res, 200, 'image/png', png(1280, 720, palette[req.url]));
  }

  send(res, 200, 'text/plain', 'VTX Roku HUD sample server. Try /api/pages');
}).listen(port, '0.0.0.0', () => {
  console.log(`VTX Roku HUD sample server listening on http://0.0.0.0:${port}`);
});
