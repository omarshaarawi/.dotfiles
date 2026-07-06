---
name: loom-extract
description: "Extract keyframes + OCR from a silent Loom video (or local mp4) for use as Claude Code context. Trigger when the user shares a Loom URL, references a UI bug captured in a screen recording, or points at a folder produced by this tool (contains manifest.json + frames/)."
allowed-tools: Bash(uv run *), Bash(cd *), Bash(loom-extract *), Read, Glob
---

# loom-extract

Pipeline that turns a silent Loom video into Claude-readable artifacts: keyframes (PNG), OCR text, structured manifest, human-readable timeline. Built for **debugging UI bugs** captured in Looms with no audio.

The CLI is at `/Users/Shaarawi/git/loom-extractor`. The tool itself does **zero API calls** — output is consumed in-thread by whichever Claude Code session needs it.

## When to use

- User pastes a Loom URL (e.g. `https://www.loom.com/share/...`) and wants you to look at it
- User describes a UI bug seen in a screen recording
- User references a folder produced by this tool (it will contain `manifest.json`, `timeline.md`, and a `frames/` directory)

## Running the extractor

```bash
cd /Users/Shaarawi/git/loom-extractor && uv run loom-extract <URL_OR_PATH>
```

Options:
- `--out DIR` — output root (default: `out/`)
- `--threshold 0.08` — scene-change sensitivity (lower = more frames kept)
- `--fps N` — regular fps sampling instead of scene detection
- `--width 1280` — max frame width; frames wider than this get downscaled
- `--dump-urls` — also write `urls.txt`, a navigation-only trace
- `--no-ocr` — skip OCR pass

Output lands in `<out>/<video-name>/` containing:
- `frames/NNNN_HH-MM-SS.png` — keyframes (downscaled to ≤1280px wide), named by index + timestamp
- `summary.md` — **read this first**: one line per frame with timestamp, detected URL, and a short OCR snippet
- `urls.txt` — *only if `--dump-urls` was passed*: navigation-only trace, consecutive frames on the same URL collapsed into time ranges. Tiny (~1-2KB) and ideal for tracing user routing through an app.
- `manifest.json` — full structured metadata + complete OCR text per frame (large; read only when summary is insufficient)
- `timeline.md` — human-readable, embeds frames inline (for the user, not for you)

If the user passes a Loom URL, the extractor downloads it via `yt-dlp` to `<target>/video.mp4` and reuses it on subsequent runs.

## Output schema

```json
{
  "source": "https://loom.com/share/<id>",
  "extracted_at": "2026-04-28T19:11:00+00:00",
  "frame_count": 42,
  "frames": [
    {
      "index": 1,
      "filename": "frames/0001_00-00-03.png",
      "timestamp_s": 3.0,
      "timestamp_hms": "0:03",
      "scene_score": 0.157,
      "ocr_text": "Sign In\nForgot password?"
    }
  ]
}
```

Filenames are stable across runs as long as the input is the same — safe to reference from notes or other threads.

## How to consume the output

When the user references an extraction folder or asks about a UI bug from a Loom:

1. **Read `summary.md` first.** It is one line per frame with timestamp, detected URL, and a short OCR snippet — token-cheap and usually enough to find the relevant frames.
2. **View only the relevant PNGs** from `frames/`. Claude is multimodal and should look at the actual image, not just the OCR text. OCR is a hint, not ground truth.
3. **Fall back to `manifest.json`** only when summary.md is too sparse and you need full per-frame OCR. The manifest is large (every frame's full OCR) — read it via filtered scripts (jq, python) rather than `Read` whenever possible.
4. **Cross-reference timestamps** with anything the user describes ("the bug happens around 0:42" → find the frame whose timestamp is closest in summary.md).
5. `timeline.md` is for the user to scan with their eyes (embeds frames inline). Don't read it yourself unless asked — summary.md gives you the same info more cheaply.

**Token budget rule of thumb:** for a typical Loom (3-5 min, 30-50 keyframes), reading summary.md + viewing 3-6 targeted frames is ~5-10k tokens. If you find yourself viewing more than 10 frames, stop and ask the user which moment they care about.

## Tuning when results are off

- **Too few frames kept** (missed the bug moment): rerun with `--threshold 0.04` or `--threshold 0.02`.
- **Too many near-duplicate frames**: rerun with `--threshold 0.15`.
- **Subtle changes missed entirely** (e.g. a single border color flip): rerun with `--fps 2` to force regular sampling, then visually scan.
- **OCR garbage on a frame**: trust the image, not the text. Low-contrast UI text or icons commonly produce noisy OCR.
