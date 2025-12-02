# Cloudflare Worker - Shelly Temperature Proxy

A Cloudflare Worker that acts as a secure proxy between your macOS app and the Shelly Cloud API. This keeps your API credentials secure on the server side and provides a simple JSON endpoint.

## Features

- Secure API credential storage (never exposed to clients)
- Fetches temperature from two Shelly BLU H&T sensors
- Optional historical data storage using Cloudflare KV
- Fast edge computing with Cloudflare Workers
- Automatic rate limiting handling (1 request/second)

## Prerequisites

- A Cloudflare account (free tier works)
- Node.js 18+ installed
- Wrangler CLI installed
- Shelly Cloud account with:
  - API Auth Key
  - Two BLU H&T device IDs (inside and outside sensors)

## Quick Start

### 1. Install Wrangler CLI

```bash
npm install -g wrangler
```

### 2. Login to Cloudflare

```bash
wrangler login
```

### 3. Create KV Namespace (Optional - for history)

```bash
wrangler kv:namespace create "TEMPERATURE_HISTORY"
```

Copy the `id` from the output and update `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "TEMPERATURE_HISTORY"
id = "your-kv-namespace-id-here"
```

### 4. Set Environment Variables

Set your Shelly Cloud credentials as secrets:

```bash
# Your Shelly Cloud server URL (usually https://shelly-211-eu.shelly.cloud)
wrangler secret put SHELLY_SERVER_URL

# Your Shelly Cloud API auth key
wrangler secret put SHELLY_AUTH_KEY

# Device ID for inside sensor
wrangler secret put SHELLY_INSIDE_DEVICE_ID

# Device ID for outside sensor
wrangler secret put SHELLY_OUTSIDE_DEVICE_ID
```

### 5. Deploy

```bash
wrangler deploy
```

After deployment, you'll get a URL like:
```
https://shelly-temperature-proxy.your-subdomain.workers.dev
```

### 6. Test

```bash
curl https://your-worker-url.workers.dev
```

Should return:
```json
{"inside": 22.5, "outside": 15.3}
```

## API Endpoints

### GET `/`

Returns current temperature readings:

```json
{
  "inside": 22.5,
  "outside": 15.3
}
```

### GET `/history`

Returns historical temperature data (last 24 hours):

```json
[
  {
    "timestamp": 1701234567890,
    "inside": 22.5,
    "outside": 15.3
  },
  ...
]
```

## Configuration

### Environment Variables

All sensitive data is stored as Cloudflare Workers secrets:

- `SHELLY_SERVER_URL` - Your Shelly Cloud server URL (default: `https://shelly-211-eu.shelly.cloud`)
- `SHELLY_AUTH_KEY` - Your Shelly Cloud API auth key
- `SHELLY_INSIDE_DEVICE_ID` - Device ID for inside sensor
- `SHELLY_OUTSIDE_DEVICE_ID` - Device ID for outside sensor

### Optional: Custom Domain

Edit `wrangler.toml`:

```toml
routes = [
  { pattern = "temperature.yourdomain.com", custom_domain = true }
]
```

### Optional: Restrict CORS

Edit `worker.js` and change:

```javascript
'Access-Control-Allow-Origin': '*',
```

to:

```javascript
'Access-Control-Allow-Origin': 'https://yourdomain.com',
```

## Getting Your Shelly Cloud Credentials

1. Log in to [Shelly Cloud](https://my.shelly.cloud/)
2. Go to **Settings → API**
3. Generate or copy your **Auth Key**
4. Find your device IDs:
   - Go to **Devices**
   - Click on each device (inside and outside)
   - Copy the Device ID from the URL or device details

## Troubleshooting

### Check Worker Logs

```bash
wrangler tail
```

### Test Shelly API Directly

```bash
curl "https://api.shelly.cloud/device/status?id=YOUR_DEVICE_ID&auth_key=YOUR_AUTH_KEY"
```

### Common Issues

**"Device not connected to cloud"**
- Make sure your devices are registered in Shelly Cloud
- Check that device IDs are correct

**"Rate limit exceeded"**
- The worker automatically waits 1 second between requests
- If you're making too many requests, increase the cache time

**"Temperature not found in API response"**
- Check the Shelly API response structure
- The worker expects temperature at `data.device_status['temperature:0'].tC`
- Update the extraction path in `worker.js` if your API structure differs

## Cost

Cloudflare Workers free tier includes:
- 100,000 requests per day
- 10ms CPU time per request
- 1 GB KV storage

This is more than enough for a temperature monitor that updates every minute (1,440 requests/day).

## Security Notes

- All API credentials are stored as Cloudflare Workers secrets (encrypted)
- Never commit secrets to git
- The worker uses CORS headers to allow cross-origin requests
- Consider restricting CORS to your domain in production

## Local Development

```bash
# Install dependencies
npm install

# Run locally
wrangler dev

# Test locally
curl http://localhost:8787
```

## Files

- `worker.js` - Main worker code
- `wrangler.toml` - Cloudflare Workers configuration
- `package.json` - Node.js dependencies

