/**
 * Ciao Kids — Claude tutor proxy (Cloudflare Worker).
 *
 * Why this exists: the app is a public web app (GitHub Pages), so the Anthropic
 * API key can NEVER live in it. This tiny Worker holds the key as a Cloudflare
 * secret and forwards chat requests to Claude, returning only the tutor's reply.
 *
 * Setup (Cloudflare dashboard):
 *   1. Workers & Pages -> Create -> Worker -> paste this file -> Deploy.
 *   2. Settings -> Variables -> add an ENCRYPTED secret:
 *        ANTHROPIC_API_KEY = sk-ant-...   (your key from console.anthropic.com)
 *   3. (Optional) add a plaintext variable MODEL to override the model
 *        MODEL = claude-haiku-4-5   // 5x cheaper than the default opus
 *   4. Copy the Worker URL (https://<name>.<sub>.workers.dev) into the app.
 *
 * The request body from the app is:
 *   { "messages": [{ "role": "user"|"assistant", "content": "..." }],
 *     "childAge": 8, "topic": "Greetings" }
 * The response is: { "reply": "<tutor text>" }
 */

// Origins allowed to call this Worker. Add your custom domain here if you add one.
const ALLOWED_ORIGINS = ['https://cuzo12.github.io'];

// Default model. Opus 4.8 is the most capable; set a MODEL variable to override
// (e.g. claude-haiku-4-5 for ~5x lower cost — plenty for short kid dialogue).
const DEFAULT_MODEL = 'claude-opus-4-8';

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin') || '';
    const cors = corsHeaders(origin);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }
    if (request.method !== 'POST') {
      return json({ error: 'Use POST.' }, 405, cors);
    }
    if (!env.ANTHROPIC_API_KEY) {
      return json({ error: 'Server not configured: missing ANTHROPIC_API_KEY.' }, 500, cors);
    }

    let body;
    try {
      body = await request.json();
    } catch (_) {
      return json({ error: 'Invalid JSON.' }, 400, cors);
    }

    const childAge = clampAge(body.childAge);
    const topic = typeof body.topic === 'string' ? body.topic : 'everyday Italian';
    const messages = sanitizeMessages(body.messages);
    if (messages.length === 0) {
      return json({ error: 'No messages.' }, 400, cors);
    }

    const anthropicReq = {
      model: env.MODEL || DEFAULT_MODEL,
      max_tokens: 320,
      system: systemPrompt(childAge, topic),
      messages,
    };

    let apiResp;
    try {
      apiResp = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'x-api-key': env.ANTHROPIC_API_KEY,
          'anthropic-version': '2023-06-01',
        },
        body: JSON.stringify(anthropicReq),
      });
    } catch (_) {
      return json({ error: 'Could not reach the tutor. Try again.' }, 502, cors);
    }

    if (!apiResp.ok) {
      const detail = await apiResp.text();
      return json({ error: 'Tutor error.', status: apiResp.status, detail }, 502, cors);
    }

    const data = await apiResp.json();

    // A safety classifier may decline (HTTP 200 with stop_reason "refusal").
    // Guard before reading content and return a gentle, kid-safe message.
    if (data.stop_reason === 'refusal') {
      return json({ reply: "Parliamo di italiano! (Let's talk about Italian!) 😊" }, 200, cors);
    }

    const reply = (data.content || [])
      .filter((b) => b.type === 'text')
      .map((b) => b.text)
      .join('')
      .trim();

    return json({ reply: reply || 'Riprova! (Try again!)' }, 200, cors);
  },
};

/** Builds the tutor persona + guardrails. This is the safety boundary. */
function systemPrompt(childAge, topic) {
  return [
    `You are Giulia, a warm, patient, funny Italian girl tutor for a child aged ${childAge}.`,
    `You are helping them practice Italian, currently around the topic: "${topic}".`,
    '',
    'Rules — follow them exactly:',
    `- Speak mostly in SIMPLE Italian suited to a ${childAge}-year-old, with a short English hint in (parentheses) after new or hard phrases.`,
    '- Keep every reply VERY short: 1–2 sentences. Ask one small question to keep the chat going.',
    '- When the child makes a mistake, never say "wrong" — gently model the correct version: "Quasi! Si dice… (Almost! You say…)" and invite them to try again.',
    '- Be encouraging and playful. Use at most one emoji.',
    '- Stay strictly on learning Italian. If the child goes off-topic or says anything not age-appropriate, kindly steer back to Italian practice.',
    '- Never ask for or store personal information (full name, address, school, passwords). Never discuss unsafe or adult topics.',
    '- You are talking to a young child. Keep everything kind, safe, and simple.',
  ].join('\n');
}

function sanitizeMessages(raw) {
  if (!Array.isArray(raw)) return [];
  const out = [];
  for (const m of raw) {
    if (!m || (m.role !== 'user' && m.role !== 'assistant')) continue;
    const content = typeof m.content === 'string' ? m.content.slice(0, 2000) : '';
    if (!content.trim()) continue;
    out.push({ role: m.role, content });
  }
  // The Anthropic API requires the first message to be from the user.
  while (out.length > 0 && out[0].role !== 'user') out.shift();
  return out.slice(-20); // cap history length
}

function clampAge(age) {
  const n = Number.parseInt(age, 10);
  if (Number.isNaN(n)) return 8;
  return Math.min(15, Math.max(5, n));
}

function corsHeaders(origin) {
  const allow = ALLOWED_ORIGINS.includes(origin) || origin.startsWith('http://localhost')
    ? origin
    : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allow,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'content-type',
    'Vary': 'Origin',
  };
}

function json(obj, status, cors) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'content-type': 'application/json', ...cors },
  });
}
