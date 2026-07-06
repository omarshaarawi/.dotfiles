---
name: x
description: Read tweets from X (Twitter) from any project — search by query or operator (from:, min_faves:, since:), pull a user's timeline, or fetch a tweet by id/URL. Two backends: TwitterAPI.io (clean JSON, tiny per-read cost) and a logged-in browser session via agent-browser (no key, no cost). Use when asked to "read tweets", "search X/Twitter", "what is <handle> tweeting", "get this tweet", "check X for <topic>", or when an x.com/twitter.com status URL appears. Read-only.
---

# x

Standalone tweet reader for any project. Two backends behind one CLI:

- **API** (default) — [TwitterAPI.io](https://twitterapi.io), third-party read API.
  Clean structured JSON, a fraction of a cent per read, needs a key. Same
  provider `social-arb` uses (`lib/social_arb/sources/x.ex`).
- **Browser** (`--browser`) — drives a real logged-in X session via
  `agent-browser` using saved cookies. No key, no per-read cost. Use it when the
  API key is out of credits (it currently is), or for reads the API doesn't cover.

## Commands

```bash
python3 ~/.claude/skills/x/x.py search "<query>" [--top] [--limit N] [--json|--raw] [--browser]
python3 ~/.claude/skills/x/x.py user   <handle>  [--replies] [--limit N] [--json|--raw] [--browser]
python3 ~/.claude/skills/x/x.py tweet  <id|url> [<id|url> ...] [--json|--raw]   # API only
```

- `search` — advanced search. `--top` ranks by engagement instead of recency.
- `user` — a handle's recent posts. `--replies` includes replies.
- `tweet` — one or more tweets by id or status URL (API backend).
- Output: human-readable by default (author · date · engagement · text · url).
  `--json` = normalized objects; `--raw` = untouched backend objects.
- `--browser` routes `search`/`user` through the saved X session instead of the
  API. `--scrolls N` bounds how far it scrolls (default 8).

## Search operators (passed straight through)

`from:elonmusk` `to:naval` `min_faves:50` `min_retweets:10`
`since:2026-06-01 until:2026-06-30` `-filter:replies` `filter:media`
`"exact phrase"` `OR` — e.g. `'"halal finance" OR sukuk min_faves:20'`

## Backends

### API key (for the default backend)

Resolved in order (first hit wins):

1. `$TWITTERAPI_KEY`
2. `~/.config/x-skill/key` (chmod 600)
3. `TWITTERAPI_KEY=` in `~/git/social-arb/.env`

Pay-per-use; API pagination capped at 10 requests/command. Returns HTTP 402 when
out of credits — the error hint tells you to switch to `--browser`.

### Browser session (for `--browser`)

Cookies live in `~/.agent-browser/x-state.json` (Playwright storage state with
`auth_token` + `ct0`). Reads run headless in an `agent-browser` session named
`xread`. Login itself must happen in a **real Chrome** — X bot-blocks login
inside the automation browser ("We've temporarily limited your login"), but
authenticated reads work fine headless once the cookies exist.

**Re-auth when the session expires** (redirects to /login, or reads come back empty):

```bash
# 1. Launch a real Chrome with a debug port + dedicated profile
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.agent-browser/chrome-x-profile" \
  --no-first-run --no-default-browser-check "https://x.com/login" &

# 2. Log in BY HAND in that window (password + 2FA). Reach the home timeline.
# 3. Attach and save the session:
agent-browser --cdp 9222 state save "$HOME/.agent-browser/x-state.json"
```

The dedicated Chrome profile at `~/.agent-browser/chrome-x-profile` stays logged
in on disk, so re-saving later usually just needs the two commands above.
