# Backend - Shelly Temperature API

This directory contains the backend code for the Tempy temperature monitoring system.

## Structure

```
backend/
├── cloudflare-worker/    # Cloudflare Worker implementation (recommended)
│   ├── worker.js         # Main worker code
│   ├── wrangler.toml     # Cloudflare configuration
│   ├── package.json      # Dependencies
│   ├── .env.example      # Example environment variables
│   └── README.md         # Setup instructions
└── examples/             # Example frontend implementations
    ├── temperature.html  # Simple temperature display
    └── index.html        # Full dashboard with history
```

## Quick Start

The recommended backend is the **Cloudflare Worker** implementation. See [cloudflare-worker/README.md](./cloudflare-worker/README.md) for detailed setup instructions.

### Why Cloudflare Workers?

- Free tier (100k requests/day)
- Global edge network (low latency)
- Built-in KV storage for history
- No server management
- Automatic scaling

### Alternative Backends

You can also implement your own backend using:

- **Node.js/Express** - See examples in `examples/` folder
- **Python/Flask** - Similar structure
- **AWS Lambda** - Serverless option
- **Any REST API** - As long as it returns JSON in this format:

```json
{
  "inside": 22.5,
  "outside": 15.3
}
```

## API Requirements

Your backend must provide:

1. **GET endpoint** that returns:
   ```json
   {
     "inside": 22.5,
     "outside": 15.3
   }
   ```

2. **CORS headers** (if accessed from browser):
   ```
   Access-Control-Allow-Origin: *
   Access-Control-Allow-Methods: GET
   ```

3. **Optional: History endpoint** (`/history`):
   ```json
   [
     {
       "timestamp": 1701234567890,
       "inside": 22.5,
       "outside": 15.3
     }
   ]
   ```

## Security

**Important**: Never expose your Shelly Cloud API credentials in client-side code!

- Store credentials as environment variables or secrets
- Use a backend proxy (like the Cloudflare Worker) to keep credentials secure
- Consider adding API key authentication for production use

## Setup Checklist

- [ ] Choose a backend solution (Cloudflare Worker recommended)
- [ ] Get Shelly Cloud credentials (Auth Key + Device IDs)
- [ ] Deploy backend and get the API URL
- [ ] Update macOS app with your API URL
- [ ] Test the API endpoint
- [ ] (Optional) Set up historical data storage

## Next Steps

1. Follow the [Cloudflare Worker setup guide](./cloudflare-worker/README.md)
2. Update the macOS app's API URL in `Tempy/TemperatureService.swift`
3. Deploy and test!

