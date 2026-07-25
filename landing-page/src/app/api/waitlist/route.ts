import { createHash } from 'node:crypto';
import { NextResponse } from 'next/server';

export const runtime = 'nodejs';

type WaitlistRole = 'scribe' | 'institution' | 'seeker';

interface WaitlistSubmission {
  name: string;
  email: string;
  role: WaitlistRole;
  intent?: string;
}

const VALID_ROLES: WaitlistRole[] = ['scribe', 'institution', 'seeker'];

const GOOGLE_SHEETS_WEBHOOK_URL = process.env.GOOGLE_SHEETS_WEBHOOK_URL;
const MAILING_SERVICE_WEBHOOK_URL = process.env.MAILING_SERVICE_WEBHOOK_URL;
const MAILCHIMP_API_KEY = process.env.MAILCHIMP_API_KEY;
const MAILCHIMP_SERVER_PREFIX = process.env.MAILCHIMP_SERVER_PREFIX;
const MAILCHIMP_AUDIENCE_ID = process.env.MAILCHIMP_AUDIENCE_ID;

function isValidEmail(email: string): boolean {
  if (!email || email.length > 254 || email.includes(' ')) {
    return false;
  }

  const atIndex = email.indexOf('@');
  const lastAtIndex = email.lastIndexOf('@');

  if (atIndex <= 0 || atIndex !== lastAtIndex) {
    return false;
  }

  const domain = email.slice(atIndex + 1);
  const dotIndex = domain.indexOf('.');

  if (dotIndex <= 0 || dotIndex === domain.length - 1) {
    return false;
  }

  return !domain.includes('..');
}

function sanitizeSubmission(body: unknown): WaitlistSubmission | null {
  if (!body || typeof body !== 'object') {
    return null;
  }

  const raw = body as Record<string, unknown>;
  const role = typeof raw.role === 'string' ? raw.role.trim().toLowerCase() : '';

  if (!VALID_ROLES.includes(role as WaitlistRole)) {
    return null;
  }

  const name = typeof raw.name === 'string' ? raw.name.trim() : '';
  const email = typeof raw.email === 'string' ? raw.email.trim().toLowerCase() : '';
  const intent = typeof raw.intent === 'string' ? raw.intent.trim() : '';

  if (!name || name.length > 120 || !isValidEmail(email)) {
    return null;
  }

  return {
    name,
    email,
    role: role as WaitlistRole,
    intent: intent || undefined,
  };
}

async function appendToGoogleSheets(submission: WaitlistSubmission): Promise<void> {
  if (!GOOGLE_SHEETS_WEBHOOK_URL) {
    throw new Error('Google Sheets webhook is not configured.');
  }

  const response = await fetch(GOOGLE_SHEETS_WEBHOOK_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ...submission,
      source: 'landing-page',
      submittedAt: new Date().toISOString(),
    }),
  });

  if (!response.ok) {
    throw new Error(`Google Sheets request failed with status ${response.status}.`);
  }
}

function hasMailchimpConfig(): boolean {
  return Boolean(MAILCHIMP_API_KEY && MAILCHIMP_SERVER_PREFIX && MAILCHIMP_AUDIENCE_ID);
}

async function upsertMailchimpMember(submission: WaitlistSubmission): Promise<void> {
  if (!hasMailchimpConfig()) {
    throw new Error('Mailchimp is not configured.');
  }

  const subscriberHash = createHash('md5').update(submission.email).digest('hex');
  const endpoint = `https://${MAILCHIMP_SERVER_PREFIX}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${subscriberHash}`;
  const firstName = submission.name.split(/\s+/)[0]?.slice(0, 80) ?? '';

  const response = await fetch(endpoint, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Basic ${Buffer.from(`scribes:${MAILCHIMP_API_KEY}`).toString('base64')}`,
    },
    body: JSON.stringify({
      email_address: submission.email,
      status_if_new: 'subscribed',
      status: 'subscribed',
      merge_fields: {
        FNAME: firstName,
      },
      tags: ['scribes_waitlist', `role_${submission.role}`],
    }),
  });

  if (!response.ok) {
    throw new Error(`Mailchimp request failed with status ${response.status}.`);
  }
}

async function notifyMailingWebhook(submission: WaitlistSubmission): Promise<void> {
  if (!MAILING_SERVICE_WEBHOOK_URL) {
    throw new Error('Mailing service webhook is not configured.');
  }

  const response = await fetch(MAILING_SERVICE_WEBHOOK_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ...submission,
      source: 'landing-page',
      submittedAt: new Date().toISOString(),
    }),
  });

  if (!response.ok) {
    throw new Error(`Mailing webhook request failed with status ${response.status}.`);
  }
}

export async function POST(request: Request) {
  let payload: unknown;

  try {
    payload = await request.json();
  } catch {
    return NextResponse.json({ error: 'Invalid request body.' }, { status: 400 });
  }

  const submission = sanitizeSubmission(payload);

  if (!submission) {
    return NextResponse.json(
      { error: 'Please provide a valid name, email, and role.' },
      { status: 400 }
    );
  }

  const integrationCalls: Promise<void>[] = [];

  if (GOOGLE_SHEETS_WEBHOOK_URL) {
    integrationCalls.push(appendToGoogleSheets(submission));
  }

  if (hasMailchimpConfig()) {
    integrationCalls.push(upsertMailchimpMember(submission));
  } else if (MAILING_SERVICE_WEBHOOK_URL) {
    integrationCalls.push(notifyMailingWebhook(submission));
  }

  if (integrationCalls.length === 0) {
    return NextResponse.json(
      { error: 'Waitlist integrations are not configured on the server.' },
      { status: 503 }
    );
  }

  const results = await Promise.allSettled(integrationCalls);
  const successful = results.filter((result) => result.status === 'fulfilled').length;

  if (successful === 0) {
    return NextResponse.json(
      { error: 'Could not save your request right now. Please try again shortly.' },
      { status: 502 }
    );
  }

  return NextResponse.json(
    {
      ok: true,
      warning:
        successful < results.length
          ? 'Part of the waitlist sync failed, but your request was received.'
          : undefined,
    },
    { status: 200 }
  );
}
