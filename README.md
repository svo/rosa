<p align="center">
  <img src="icon.png" alt="Rosa" width="128">
</p>

# Rosa

[![Build Development](https://github.com/svo/rosa/actions/workflows/development.yml/badge.svg)](https://github.com/svo/rosa/actions/workflows/development.yml)
[![Build Builder](https://github.com/svo/rosa/actions/workflows/builder.yml/badge.svg)](https://github.com/svo/rosa/actions/workflows/builder.yml)
[![Build Service](https://github.com/svo/rosa/actions/workflows/service.yml/badge.svg)](https://github.com/svo/rosa/actions/workflows/service.yml)

Docker image running an [OpenClaw](https://docs.openclaw.ai) gateway with web search and fetch capabilities for researching the intersection of AI and service design, and drafting blog posts about how AI is transforming human-centred service delivery.

## Prerequisites

* `vagrant`
* `ansible`
* `colima`
* `docker`
- An OpenAI API key
- A [Brave Search API](https://brave.com/search/api/) key (for web search)

## Building

```bash
# Build for a specific architecture
./build.sh service arm64
./build.sh service amd64

# Push
./push.sh service arm64
./push.sh service amd64

# Create and push multi-arch manifest
./create-latest.sh service
```

## Running

```bash
docker run -d \
  --name rosa \
  --restart unless-stopped \
  --pull always \
  -e OPENAI_API_KEY="your-api-key" \
  -e BRAVE_API_KEY="your-brave-api-key" \
  -e FIRECRAWL_API_KEY="your-firecrawl-api-key" \
  -e TELEGRAM_BOT_TOKEN="your-telegram-bot-token" \
  -e TELEGRAM_ALLOW_FROM="your-telegram-user-id" \
  -e ROSA_AUTHOR_NAME="Tamara" \
  -e ROSA_BLOG_URL="https://www.tamo.qual.is/" \
  -e ROSA_TOPICS="AI adoption in enterprise, AI-powered SaaS products, machine learning for business operations, conversational AI and customer experience, AI development tools and platforms" \
  -e ROSA_ANALYTICAL_LENS="market analysis, technology adoption lifecycle, jobs-to-be-done framework, lean startup methodology, product-market fit evaluation" \
  -e ROSA_TONE="warm, empathetic, and encouraging — like a knowledgeable friend who genuinely cares, not a detached analyst or a hype piece" \
  -e ROSA_CRON_SCHEDULE="0 8 * * 1" \
  -e ROSA_TIMEZONE="Australia/Melbourne" \
  -e ROSA_WORD_COUNT="500-900" \
  -e ROSA_LOCALE="en-AU" \
  -v /opt/rosa/data:/root/.openclaw \
  -p 127.0.0.1:3000:3000 \
  svanosselaer/rosa-service:latest
```

On first run, the entrypoint automatically configures OpenClaw via non-interactive onboarding and sets up web search, web fetch, and messaging access. Configuration is persisted to the volume at `/root/.openclaw` so subsequent starts skip onboarding.

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | Yes | OpenAI API key for the OpenClaw gateway |
| `BRAVE_API_KEY` | No | [Brave Search API](https://brave.com/search/api/) key for web search |
| `FIRECRAWL_API_KEY` | No | [Firecrawl](https://firecrawl.dev) API key for enhanced web scraping |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token from @BotFather |
| `TELEGRAM_ALLOW_FROM` | With `TELEGRAM_BOT_TOKEN` | Comma-separated Telegram user IDs to allow |
| `ROSA_AUTHOR_NAME` | Yes | Author name for workspace configuration |
| `ROSA_BLOG_URL` | Yes | Blog URL for style reference |
| `ROSA_TOPICS` | Yes | Comma-separated research focus areas |
| `ROSA_ANALYTICAL_LENS` | Yes | Analytical frameworks and perspectives to apply |
| `ROSA_TONE` | Yes | Writing tone descriptors |
| `ROSA_CRON_SCHEDULE` | Yes | Cron expression for research runs |
| `ROSA_TIMEZONE` | Yes | Timezone for scheduling |
| `ROSA_WORD_COUNT` | Yes | Target word count range |
| `ROSA_LOCALE` | Yes | Spelling and language conventions |

## Telegram Integration

Connect Rosa to Telegram so you can chat with your assistant directly from the Telegram app.

### Setup

1. Open Telegram and start a chat with [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to name your bot
3. Save the bot token that BotFather returns
4. Pass it as an environment variable when running the container:

```bash
docker run -d \
  --name rosa \
  --restart unless-stopped \
  -e OPENAI_API_KEY="your-api-key" \
  -e TELEGRAM_BOT_TOKEN="your-telegram-bot-token" \
  -e TELEGRAM_ALLOW_FROM="your-telegram-user-id" \
  -v /opt/rosa/data:/root/.openclaw \
  -p 127.0.0.1:3000:3000 \
  svanosselaer/rosa-service:latest
```

On startup, the entrypoint automatically configures the Telegram channel in OpenClaw with group chats set to require `@mention`. When `TELEGRAM_ALLOW_FROM` is set, the DM policy is `allowlist` — only the listed Telegram user IDs can message the bot. Without it, the policy falls back to `pairing` (unknown users get a pairing code for the owner to approve).

To find your Telegram user ID, message the bot without `TELEGRAM_ALLOW_FROM` set — the pairing prompt will show it.

## Workspace Instructions

On startup, the entrypoint generates OpenClaw workspace files at `~/.openclaw/workspace/` using the `ROSA_*` environment variables and sets `agent.skipBootstrap: true` so OpenClaw uses the pre-seeded files directly:

| File | Content |
|---|---|
| `IDENTITY.md` | Name, vibe, and emoji |
| `SOUL.md` | Persona, tone, and boundaries |
| `AGENTS.md` | Operating instructions — research focus, analytical frameworks, research methodology, post format, and schedule |
| `USER.md` | Author name, timezone, and locale |

These files are injected into the agent's context at the start of every session, so Rosa has detailed craft guidance available immediately without needing to parse the blog on every run.

All `ROSA_*` variables are required — the container will fail on startup if any are missing. This makes the configuration explicit and avoids hidden assumptions about authorship, style, or scheduling.
