"""Mine ~/.claude/projects session logs for agent failure modes, bucketed by model.

Two independent signals:
  - corrections, by regex over turns Omar actually typed
  - tool errors, structural, straight off is_error tool_results

User-role turns are not all human speech. Skill bodies, slash-command text, agent
system prompts, Stop-hook feedback and the harness "continue" resume prompt all
arrive with role=user and will swamp the correction counts if they are not
rejected first. INJECTED below is doing most of the real work in this script.

Writes summary + samples to $AUDIT_OUT (default ~/.claude/audit). Always read the
samples before believing a bucket: a bucket that looks alarming is usually a
regex catching machine text.
"""
import json, os, re, sys, collections

ROOT = os.path.expanduser("~/.claude/projects")
OUT = os.environ.get("AUDIT_OUT", os.path.expanduser("~/.claude/audit"))

# Anything matching these is machine-injected, not Omar speaking.
INJECTED = re.compile(
    r"^(continue|continue from where you left off\.?|proceed|go on)\s*$"
    r"|Base directory for this skill:"
    r"|^\[Base\] You are"
    r"|^You are (the|an?|operating)"
    r"|^Review target:"
    r"|Check the diff of the current branch against trunk"
    r"|^You write concise"
    r"|^Analyze this (image|file)"
    r"|^<.*>$"
    r"|^Caveat:"
    r"|^\[Request interrupted"
    r"|This session is being continued"
    r"|^Please write a (title|summary)"
    r"|^Summarize this"
    r"|autonomous fix loop"
    r"|^\s*$",
    re.I | re.S,
)

# Pasted third-party transcripts (Discord/Slack dumps) are context, not corrections.
PASTED = re.compile(r"— \d{1,2}:\d{2} (AM|PM)|^This is the start of the #", re.M)

BUCKETS = [
    ("instance_trap",  r"\bi mean\b|\bi meant\b|\bnot just (the|that|this|aws|one)\b|\bin general\b|\bthe whole\b.{0,20}\b(thing|app|codebase|flow|design|redesign)\b|\bevery(where| single)\b.{0,30}\bnot just\b|\bwhen i say\b"),
    ("unasked_edit",   r"\bi didn'?t ask\b|\bwhy did you\b|\bundo (that|it|this)\b|\brevert (that|it|this)\b|\bdon'?t touch\b|\bstop editing\b|\bwho told you\b|\bi never (asked|said)\b"),
    ("wrong_result",   r"\bthat'?s wrong\b|\bstill (broken|failing|doesn'?t|not)\b|\bdoesn'?t work\b|\bdidn'?t work\b|\bnot working\b|\bthat'?s not right\b|\bwrong\b.{0,15}\b(answer|approach|file)\b"),
    ("overbuild",      r"\btoo (much|complex|many|complicated)\b|\bover.?(engineer|built|kill)|\bsimpler\b|\bwe don'?t need\b|\byou don'?t need\b|\bscope creep\b|\bkeep it simple\b|\bwhy (so much|is this so)\b"),
    ("stopped_early",  r"\bkeep going\b|\byou didn'?t finish\b|\bnot done\b|\bfinish (it|the rest)\b|\bwhat about the (rest|others)\b|\bdon'?t stop\b|\byou only did\b|\bthat'?s only (one|part)\b"),
    ("no_verify",      r"\bdid you (actually )?(run|test|try|check)\b|\byou didn'?t (run|test|verify|check)\b|\breceipts?\b|\bprove it\b|\bshow me (the )?(output|proof|it)\b|\bare you sure\b"),
    ("destructive",    r"\byou (killed|deleted|dropped|nuked|wiped|removed)\b|\bdon'?t kill\b|\byou broke\b|\bthat was destructive\b|\bwhy did you delete\b"),
    ("taste",          r"\bugly\b|\blooks? (bad|terrible|like ai|generic|awful)\b|\bmake it (pretty|nicer|better looking)\b|\bthat'?s not (good )?design\b|\bhate (the|this|how)\b"),
    ("slop_called",    r"\bthis is slop\b|\bthat'?s slop\b|\bbandaid\b|\bband.aid\b|\bbreadcrumb\b|\bno-?op\b|\blandmine\b|\bvibed\b"),
]
COMPILED = [(n, re.compile(p, re.I)) for n, p in BUCKETS]


def norm_model(m):
    if not m:
        return "unknown"
    for tag, name in [
        ("fable", "fable-5"), ("opus-5", "opus-5"), ("opus-4-8", "opus-4.8"),
        ("opus-4-1", "opus-4.1"), ("opus-4", "opus-4"),
        ("sonnet-5", "sonnet-5"), ("sonnet-4-5", "sonnet-4.5"), ("sonnet-4", "sonnet-4"),
        ("haiku-4-5", "haiku-4.5"), ("haiku", "haiku"),
        ("3-7-sonnet", "sonnet-3.7"), ("3-5-sonnet", "sonnet-3.5"),
    ]:
        if tag in m:
            return name
    return m


def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(
            p.get("text", "") for p in content
            if isinstance(p, dict) and p.get("type") == "text"
        )
    return ""


def classify_bash_error(s):
    s = s.lower()
    pairs = [
        ("command not found",        r"command not found|: not found"),
        ("no such file or directory", r"no such file or directory"),
        ("permission denied",         r"permission denied|eacces"),
        ("timeout / killed",          r"timed? ?out|killed|sigterm|sigkill"),
        ("git/jj state conflict",     r"\bjj\b.*error|not a git repo|nothing to commit|merge conflict|would be overwritten|no such revision|immutable"),
        ("test/build failure",        r"test.{0,10}fail|build failed|compilation error|type error|tsc |exit code [1-9]"),
        ("port already in use",       r"address already in use|eaddrinuse|port .* in use"),
        ("missing dependency/module", r"cannot find module|modulenotfounderror|no module named|unresolved import"),
        ("bad flag/usage",            r"unknown option|invalid option|unrecognized argument|usage:|invalid flag"),
        ("network/auth",              r"401|403|unauthorized|forbidden|could not resolve host|connection refused|etimedout"),
        ("interactive/blocked cmd",   r"interactive|not supported in this environment|requires a tty|blocked"),
    ]
    for name, rx in pairs:
        if re.search(rx, s):
            return name
    return "other"


human_by_model = collections.Counter()
corr_by_model = collections.Counter()
bucket_by_model = collections.defaultdict(collections.Counter)
bucket_total = collections.Counter()
tool_calls_by_model = collections.Counter()
tool_err_by_model = collections.Counter()
bash_err_kind = collections.Counter()
bash_err_kind_by_model = collections.defaultdict(collections.Counter)
err_by_tool = collections.Counter()
proj_corr = collections.Counter()
samples = collections.defaultdict(list)
bash_samples = collections.defaultdict(list)
rejected = 0

files = [os.path.join(r, f) for r, _, fs in os.walk(ROOT) for f in fs if f.endswith(".jsonl")]
print(f"scanning {len(files)} files...", file=sys.stderr)

for n, fp in enumerate(files):
    if n % 500 == 0:
        print(f"  {n}/{len(files)}", file=sys.stderr)
    proj = os.path.basename(os.path.dirname(fp))
    cur_model = "unknown"
    tnames, tmodel = {}, {}
    try:
        fh = open(fp, errors="ignore")
    except OSError:
        continue
    with fh:
        for line in fh:
            if '"type"' not in line:
                continue
            try:
                o = json.loads(line)
            except Exception:
                continue
            t, msg = o.get("type"), o.get("message")
            if not isinstance(msg, dict):
                continue

            if t == "assistant":
                m = norm_model(msg.get("model"))
                if m in ("<synthetic>", "unknown"):
                    continue
                cur_model = m
                for p in msg.get("content", []) or []:
                    if isinstance(p, dict) and p.get("type") == "tool_use":
                        tnames[p.get("id")] = p.get("name", "?")
                        tmodel[p.get("id")] = m
                        tool_calls_by_model[m] += 1
                continue

            if t != "user":
                continue
            content = msg.get("content")

            if isinstance(content, list):
                for p in content:
                    if isinstance(p, dict) and p.get("type") == "tool_result" and p.get("is_error"):
                        tid = p.get("tool_use_id")
                        name = tnames.get(tid, "?")
                        m = tmodel.get(tid, cur_model)
                        tool_err_by_model[m] += 1
                        err_by_tool[name] += 1
                        if name == "Bash":
                            body = p.get("content")
                            if isinstance(body, list):
                                body = " ".join(
                                    x.get("text", "") for x in body if isinstance(x, dict)
                                )
                            body = (body or "")[:600]
                            kind = classify_bash_error(body)
                            bash_err_kind[kind] += 1
                            bash_err_kind_by_model[m][kind] += 1
                            if len(bash_samples[kind]) < 12:
                                bash_samples[kind].append(" ".join(body.split())[:200])

            if o.get("isSidechain") or o.get("userType") != "external":
                continue
            txt = text_of(content).strip()
            if not txt or INJECTED.match(txt) or INJECTED.search(txt[:200]) or PASTED.search(txt[:400]):
                rejected += 1
                continue
            if len(txt) > 2500:  # pasted docs/logs, not a spoken correction
                rejected += 1
                continue

            human_by_model[cur_model] += 1
            hit = False
            for name, rx in COMPILED:
                if rx.search(txt):
                    bucket_by_model[cur_model][name] += 1
                    bucket_total[name] += 1
                    hit = True
                    if len(samples[name]) < 60:
                        samples[name].append({"model": cur_model, "proj": proj,
                                              "text": " ".join(txt.split())[:300]})
            if hit:
                corr_by_model[cur_model] += 1
                proj_corr[proj] += 1

MIN = 100
summary = {
    "files_scanned": len(files),
    "injected_turns_rejected": rejected,
    "human_turns_by_model": dict(human_by_model.most_common()),
    "corrections_per_100_human_turns": {
        m: round(corr_by_model[m] / human_by_model[m] * 100, 1)
        for m in human_by_model if human_by_model[m] >= MIN
    },
    "bucket_totals": dict(bucket_total.most_common()),
    "bucket_per_100_by_model": {
        m: {b: round(c / human_by_model[m] * 100, 1) for b, c in bucket_by_model[m].most_common()}
        for m in human_by_model if human_by_model[m] >= MIN
    },
    "tool_calls_by_model": dict(tool_calls_by_model.most_common()),
    "tool_error_rate_pct": {
        m: round(tool_err_by_model[m] / tool_calls_by_model[m] * 100, 1)
        for m in tool_calls_by_model if tool_calls_by_model[m] >= 500
    },
    "top_erroring_tools": dict(err_by_tool.most_common(12)),
    "bash_error_kinds": dict(bash_err_kind.most_common()),
    "bash_error_kinds_by_model": {
        m: dict(c.most_common(6)) for m, c in bash_err_kind_by_model.items()
        if tool_calls_by_model.get(m, 0) >= 500
    },
    "top_projects_by_corrections": dict(proj_corr.most_common(10)),
}

os.makedirs(OUT, exist_ok=True)
json.dump(summary, open(f"{OUT}/summary.json", "w"), indent=2)
json.dump(samples, open(f"{OUT}/correction-samples.json", "w"), indent=2)
json.dump(bash_samples, open(f"{OUT}/bash-error-samples.json", "w"), indent=2)
print(f"\nwrote summary.json, correction-samples.json, bash-error-samples.json to {OUT}", file=sys.stderr)
print(json.dumps(summary, indent=2))
