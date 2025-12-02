# Example Frontend Implementations

This folder contains example HTML files that demonstrate how to use the temperature API.

## Files

- `temperature.html` - Simple temperature display with auto-refresh
- `index.html` - Full dashboard with historical data visualization

## Usage

1. Deploy your Cloudflare Worker backend (see `../cloudflare-worker/README.md`)
2. Update the `apiEndpoint` in the HTML file's `CONFIG` object
3. Open the HTML file in a browser or deploy to static hosting

## Deployment Options

- **Cloudflare Pages** (recommended - same account as Workers)
- GitHub Pages
- Netlify
- Vercel
- Any static web server

## Local Testing

```bash
# Python 3
python3 -m http.server 8000

# Node.js
npx http-server

# Then open: http://localhost:8000/temperature.html
```

## Configuration

Update the `CONFIG` object in each HTML file:

```javascript
const CONFIG = {
    apiEndpoint: 'https://your-worker.workers.dev',
    historyEndpoint: 'https://your-worker.workers.dev/history',
    updateInterval: 60000 // milliseconds
};
```
