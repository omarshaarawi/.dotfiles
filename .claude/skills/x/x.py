#!/usr/bin/env python3
"""
x: read tweets from X (Twitter) from any project.

Two backends:
  - API (default): TwitterAPI.io, third-party read API. Clean JSON, costs a
    fraction of a cent per read, needs a key. Same provider social-arb uses.
  - Browser (--browser): drives a real logged-in X session via agent-browser
    using saved cookies. No API key, no per-read cost. Use this when the API
    key is out of credits, or for reads the API doesn't cover.

API key resolution order (first hit wins):
  1. $TWITTERAPI_KEY
  2. ~/.config/x-skill/key            (chmod 600; dedicated to this skill)
  3. ~/git/social-arb/.env            (TWITTERAPI_KEY=...; current source of truth)

Browser session:
  Cookies live in ~/.agent-browser/x-state.json (Playwright storage state with
  auth_token + ct0). Re-auth when it expires: relaunch a real Chrome with a
  debug port, log in by hand, then `agent-browser --cdp 9222 state save
  ~/.agent-browser/x-state.json`. (X bot-blocks login inside the automation
  browser, so login must happen in a real Chrome; reads work fine headless.)

Usage:
  x.py search "<query>" [--top] [--limit N] [--json|--raw] [--browser]
  x.py user   <handle>  [--replies] [--limit N] [--json|--raw] [--browser]
  x.py tweet  <id|url>  [<id|url> ...] [--json|--raw]

Search query supports X operators, e.g.:
  x.py search 'from:elonmusk starship'
  x.py search '"halal finance" min_faves:50 -filter:replies'
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path

BASE_URL = "https://api.twitterapi.io"
PAGE_CAP = 10  # hard ceiling on paginated API requests per command (cost guard)

STATE_FILE = Path.home() / ".agent-browser" / "x-state.json"
BROWSE_SESSION = "xread"

# Pull each rendered tweet (article) out of the DOM. Returns a JSON string, which
# agent-browser then JSON-encodes again — so callers decode twice.
EXTRACT_JS = r"""JSON.stringify([...document.querySelectorAll('article[data-testid="tweet"]')].map(a => {
  const t = a.querySelector('[data-testid="tweetText"]');
  const tm = a.querySelector('time');
  const link = tm ? tm.closest('a') : null;
  const grp = a.querySelector('[role="group"]');
  const nm = a.querySelector('[data-testid="User-Name"]');
  let h = ''; if (nm) { const m = nm.innerText.match(/@\w+/); h = m ? m[0] : ''; }
  return {handle: h, time: tm ? tm.getAttribute('datetime') : '', url: link ? link.href : '',
          text: t ? t.innerText : '', stats: grp ? grp.getAttribute('aria-label') : ''};
}))"""


# --- key resolution (API backend only) --------------------------------------

def resolve_key() -> str:
    env = os.environ.get("TWITTERAPI_KEY")
    if env:
        return env.strip()

    dedicated = Path.home() / ".config" / "x-skill" / "key"
    if dedicated.is_file():
        val = dedicated.read_text().strip()
        if val:
            return val

    env_file = Path.home() / "git" / "social-arb" / ".env"
    if env_file.is_file():
        for line in env_file.read_text().splitlines():
            line = line.strip()
            if line.startswith("TWITTERAPI_KEY="):
                val = line.split("=", 1)[1].strip().strip("'\"")
                if val:
                    return val

    sys.exit(
        "No TwitterAPI.io key found. Set one of:\n"
        "  export TWITTERAPI_KEY=...\n"
        "  ~/.config/x-skill/key   (chmod 600)\n"
        "  TWITTERAPI_KEY= line in ~/git/social-arb/.env\n"
        "Or read via the logged-in browser session with --browser."
    )


# --- API backend ------------------------------------------------------------

def api_get(path: str, params: dict[str, str], key: str) -> dict:
    url = f"{BASE_URL}{path}?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"X-API-Key": key})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        detail = e.read().decode(errors="replace")
        hint = "  (out of credits — retry with --browser)" if e.code == 402 else ""
        sys.exit(f"HTTP {e.code} from {path}: {detail}{hint}")
    except urllib.error.URLError as e:
        sys.exit(f"Network error calling {path}: {e.reason}")

    if body.get("status") == "error":
        sys.exit(f"API error from {path}: {body.get('message', 'unknown')}")
    return body


def paginate(path: str, base_params: dict[str, str], limit: int, key: str) -> list[dict]:
    tweets: list[dict] = []
    cursor = ""
    pages = 0
    while len(tweets) < limit and pages < PAGE_CAP:
        params = dict(base_params)
        if cursor:
            params["cursor"] = cursor
        body = api_get(path, params, key)
        batch = body.get("tweets") or []
        tweets.extend(batch)
        pages += 1
        if not batch or not body.get("has_next_page") or not body.get("next_cursor"):
            break
        cursor = body["next_cursor"]
    return tweets[:limit]


def normalize_api(t: dict) -> dict:
    author = t.get("author") or {}
    return {
        "url": t.get("url"),
        "author": author.get("userName"),
        "created_at": t.get("createdAt"),
        "text": t.get("text"),
        "likes": t.get("likeCount") or 0,
        "retweets": t.get("retweetCount") or 0,
        "replies": t.get("replyCount") or 0,
        "quotes": t.get("quoteCount") or 0,
        "views": t.get("viewCount") or 0,
        "is_reply": t.get("isReply") or False,
        "conversation_id": t.get("conversationId"),
    }


# --- browser backend --------------------------------------------------------

def _ab(*args: str, stdin: str | None = None) -> str:
    try:
        proc = subprocess.run(
            ["agent-browser", "--session-name", BROWSE_SESSION, *args],
            input=stdin, capture_output=True, text=True, timeout=90,
        )
    except FileNotFoundError:
        sys.exit("agent-browser not found on PATH — install it or use the API backend.")
    return proc.stdout.strip()


def _parse_eval(out: str) -> list:
    """agent-browser prints progress lines plus a (double-encoded) JSON payload.
    Scan from the bottom for the first line that decodes to a list."""
    for line in reversed(out.splitlines()):
        line = line.strip()
        if not line:
            continue
        try:
            v = json.loads(line)
            if isinstance(v, str):
                v = json.loads(v)
            if isinstance(v, list):
                return v
        except (json.JSONDecodeError, ValueError):
            continue
    return []


def browse(url: str, scrolls: int, limit: int) -> list[dict]:
    if not STATE_FILE.is_file():
        sys.exit(
            f"No saved X session at {STATE_FILE}. Log in via a real Chrome and save state "
            "(see this file's docstring)."
        )
    _ab("state", "load", str(STATE_FILE))
    _ab("open", url)
    _ab("wait", "3500")
    seen: dict[str, dict] = {}
    for _ in range(scrolls):
        arr = _parse_eval(_ab("eval", "--stdin", stdin=EXTRACT_JS))
        for t in arr:
            u = t.get("url", "")
            if u and u not in seen and t.get("text"):
                seen[u] = t
        if len(seen) >= limit:
            break
        _ab("scroll", "down", "1600")
        _ab("wait", "1800")
    return list(seen.values())[:limit]


def _parse_stats(s: str) -> dict:
    # aria-label like "12 replies, 34 reposts, 567 likes, 8 bookmarks, 9012 views"
    out = {}
    for key, label in [("replies", "repl"), ("retweets", "repost"),
                       ("likes", "like"), ("views", "view")]:
        m = re.search(r"([\d,]+)\s+" + label, s or "", re.I)
        out[key] = int(m.group(1).replace(",", "")) if m else 0
    return out


def normalize_browse(t: dict) -> dict:
    st = _parse_stats(t.get("stats", ""))
    return {
        "url": t.get("url"),
        "author": (t.get("handle", "") or "").lstrip("@") or None,
        "created_at": t.get("time"),
        "text": t.get("text"),
        "quotes": 0,
        "is_reply": None,
        "conversation_id": None,
        **st,
    }


# --- formatting -------------------------------------------------------------

def fmt_count(n: int) -> str:
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}m".replace(".0m", "m")
    if n >= 1_000:
        return f"{n / 1_000:.1f}k".replace(".0k", "k")
    return str(n)


def fmt_date(raw: str) -> str:
    if not raw:
        return "?"
    if "T" in raw and raw.endswith("Z"):  # ISO from browser
        return raw[:16].replace("T", " ")
    for parse in (parsedate_to_datetime,
                  lambda s: datetime.strptime(s, "%a %b %d %H:%M:%S %z %Y")):
        try:
            return parse(raw).astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M")
        except (ValueError, TypeError):
            continue
    return raw


def render(norm: list[dict]) -> str:
    if not norm:
        return "(no tweets)"
    blocks = []
    for n in norm:
        head = (
            f"@{n['author']} · {fmt_date(n['created_at'])} · "
            f"♥{fmt_count(n['likes'])} ↺{fmt_count(n['retweets'])} "
            f"💬{fmt_count(n['replies'])} · {fmt_count(n['views'])} views"
        )
        blocks.append(f"{head}\n{n['text']}\n{n['url']}")
    return "\n\n".join(blocks)


def emit(raw: list[dict], norm: list[dict], args: argparse.Namespace) -> None:
    if args.raw:
        print(json.dumps(raw, indent=2, ensure_ascii=False))
    elif args.json:
        print(json.dumps(norm, indent=2, ensure_ascii=False))
    else:
        print(render(norm))


# --- commands ---------------------------------------------------------------

TWEET_ID_RE = re.compile(r"(?:status(?:es)?/)(\d+)")


def extract_id(token: str) -> str:
    m = TWEET_ID_RE.search(token)
    if m:
        return m.group(1)
    digits = re.sub(r"\D", "", token)
    if digits:
        return digits
    sys.exit(f"Could not extract a tweet id from: {token}")


def cmd_search(args: argparse.Namespace) -> None:
    if args.browser:
        f = "top" if args.top else "live"
        url = f"https://x.com/search?q={urllib.parse.quote(args.query)}&f={f}"
        raw = browse(url, args.scrolls, args.limit)
        emit(raw, [normalize_browse(t) for t in raw], args)
        return
    params = {"query": args.query, "queryType": "Top" if args.top else "Latest"}
    raw = paginate("/twitter/tweet/advanced_search", params, args.limit, resolve_key())
    emit(raw, [normalize_api(t) for t in raw], args)


def cmd_user(args: argparse.Namespace) -> None:
    handle = args.handle.lstrip("@")
    if args.browser:
        raw = browse(f"https://x.com/{handle}", args.scrolls, args.limit)
        if not args.replies:
            raw = [t for t in raw if (t.get("handle", "") or "").lower() == f"@{handle}".lower()]
        raw = raw[:args.limit]
        emit(raw, [normalize_browse(t) for t in raw], args)
        return
    params = {"userName": handle, "includeReplies": "true" if args.replies else "false"}
    raw = paginate("/twitter/user/last_tweets", params, args.limit, resolve_key())
    emit(raw, [normalize_api(t) for t in raw], args)


def cmd_tweet(args: argparse.Namespace) -> None:
    ids = ",".join(extract_id(tok) for tok in args.refs)
    body = api_get("/twitter/tweets", {"tweet_ids": ids}, resolve_key())
    raw = body.get("tweets") or []
    emit(raw, [normalize_api(t) for t in raw], args)


# --- cli --------------------------------------------------------------------

def main() -> None:
    p = argparse.ArgumentParser(prog="x", description="Read tweets from X")
    sub = p.add_subparsers(dest="cmd", required=True)

    def add_output_flags(sp: argparse.ArgumentParser) -> None:
        sp.add_argument("--json", action="store_true", help="normalized JSON output")
        sp.add_argument("--raw", action="store_true", help="raw backend objects")

    def add_browser_flags(sp: argparse.ArgumentParser) -> None:
        sp.add_argument("--browser", action="store_true",
                        help="read via the logged-in browser session (no API key/cost)")
        sp.add_argument("--scrolls", type=int, default=8,
                        help="max scroll passes in --browser mode (default 8)")

    s = sub.add_parser("search", help="advanced search (supports X operators)")
    s.add_argument("query")
    s.add_argument("--top", action="store_true", help="rank by Top instead of Latest")
    s.add_argument("--limit", type=int, default=20, help="max tweets (default 20)")
    add_output_flags(s)
    add_browser_flags(s)
    s.set_defaults(func=cmd_search)

    u = sub.add_parser("user", help="a user's recent tweets")
    u.add_argument("handle", help="@handle or handle")
    u.add_argument("--replies", action="store_true", help="include replies")
    u.add_argument("--limit", type=int, default=20, help="max tweets (default 20)")
    add_output_flags(u)
    add_browser_flags(u)
    u.set_defaults(func=cmd_user)

    t = sub.add_parser("tweet", help="fetch tweet(s) by id or URL (API only)")
    t.add_argument("refs", nargs="+", help="tweet ids or status URLs")
    add_output_flags(t)
    t.set_defaults(func=cmd_tweet)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
