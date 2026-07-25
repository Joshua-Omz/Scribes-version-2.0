# Scribes Landing Page

## Run locally

```bash
npm install
npm run dev
```

## Waitlist integrations

Create `landing-page/.env.local` and configure at least:

```bash
GOOGLE_SHEETS_WEBHOOK_URL=https://script.google.com/macros/s/your-script-id/exec
```

For mailing service integration, configure one option:

### Option A: Mailchimp (recommended)

```bash
MAILCHIMP_API_KEY=your-mailchimp-api-key
MAILCHIMP_SERVER_PREFIX=us21
MAILCHIMP_AUDIENCE_ID=your-audience-id
```

### Option B: Custom mailing webhook

```bash
MAILING_SERVICE_WEBHOOK_URL=https://your-mailing-service-webhook
```

The waitlist endpoint (`POST /api/waitlist`) now:
- Receives role, name, email, and optional intent from the landing page form
- Pushes submissions to Google Sheets
- Syncs subscribers to Mailchimp (or the custom mailing webhook)
