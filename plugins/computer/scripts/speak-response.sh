#!/bin/bash
# Stop hook: speak Claude's latest response aloud via macOS `say`.
# Gated on a flag file so it can be toggled mid-session:
#   on:  touch ~/.claude/speak-on   (or /computer:speak)
#   off: rm ~/.claude/speak-on      (or /computer:mute)
[ -f "$HOME/.claude/speak-on" ] || exit 0

HOOK_INPUT="$(cat)" export HOOK_INPUT

python3 - <<'PYEOF'
import hashlib
import json
import os
import re
import subprocess
import sys
import time

hook_input = json.loads(os.environ.get("HOOK_INPUT", "{}"))
transcript_path = hook_input.get("transcript_path", "")
session_id = hook_input.get("session_id", "")
if not transcript_path:
    sys.exit(0)

STATE_PATH = os.path.expanduser("~/.claude/speak-last.json")


def last_spoken_uuid():
    try:
        with open(STATE_PATH) as f:
            state = json.load(f)
    except (OSError, json.JSONDecodeError):
        return None
    if state.get("session_id") != session_id:
        return None
    return state.get("uuid")


def record_spoken(uuid):
    try:
        with open(STATE_PATH, "w") as f:
            json.dump({"session_id": session_id, "uuid": uuid}, f)
    except OSError:
        pass


def is_user_prompt(entry):
    # A real user prompt, as opposed to a tool_result or meta entry.
    if entry.get("type") != "user" or entry.get("isMeta"):
        return False
    content = entry.get("message", {}).get("content", [])
    if isinstance(content, str):
        return True
    if isinstance(content, list):
        return not any(isinstance(b, dict) and b.get("type") == "tool_result"
                       for b in content)
    return False


def latest_reply_to_current_prompt():
    # Returns (uuid, blocks) of the last assistant text entry that appears
    # AFTER the last real user prompt. Anchoring on the prompt (which is
    # always flushed before the Stop hook fires) prevents speaking a stale
    # reply from the previous turn when the newest reply has not been
    # flushed to the transcript yet.
    uuid, text_blocks = None, []
    try:
        with open(transcript_path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if entry.get("isSidechain"):
                    continue
                if is_user_prompt(entry):
                    uuid, text_blocks = None, []
                    continue
                if entry.get("type") != "assistant":
                    continue
                content = entry.get("message", {}).get("content", [])
                blocks = [b.get("text", "") for b in content
                          if isinstance(b, dict) and b.get("type") == "text"]
                if any(b.strip() for b in blocks):
                    text_blocks = blocks
                    joined = "\n".join(blocks)
                    uuid = entry.get("uuid") or hashlib.sha256(
                        joined.encode("utf-8")).hexdigest()
    except OSError:
        return None, []
    return uuid, text_blocks


# The Stop hook can fire before the newest reply is flushed to the
# transcript. Poll until a reply to the current prompt appears, then
# require the same result on two consecutive reads so a multi-part
# reply that is still flushing settles before we speak it.
already_spoken = last_spoken_uuid()
uuid, text_blocks = None, []
for attempt in range(20):
    new_uuid, new_blocks = latest_reply_to_current_prompt()
    if new_uuid and new_uuid != already_spoken:
        if new_uuid == uuid:
            break
        uuid, text_blocks = new_uuid, new_blocks
    time.sleep(0.25)
if not uuid or uuid == already_spoken:
    sys.exit(0)
record_spoken(uuid)

text = "\n".join(text_blocks)

# Fenced code blocks become a short spoken placeholder.
text = re.sub(r"```.*?```", " Code omitted. ", text, flags=re.DOTALL)
text = re.sub(r"```.*", " Code omitted. ", text, flags=re.DOTALL)
# Inline code: keep the word, drop the backticks.
text = text.replace("`", "")
# Links: keep the label, drop the URL.
text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
# Drop table separator rows, then table pipes.
text = re.sub(r"^\s*\|[\s:|-]+\|\s*$", "", text, flags=re.MULTILINE)
text = text.replace("|", " ")
# Headers, emphasis, list bullets, blockquotes.
text = re.sub(r"^#{1,6}\s*", "", text, flags=re.MULTILINE)
text = re.sub(r"[*_]{1,3}", "", text)
text = re.sub(r"^\s*[-*+]\s+", "", text, flags=re.MULTILINE)
text = re.sub(r"^\s*>\s*", "", text, flags=re.MULTILINE)
# Collapse whitespace.
text = re.sub(r"\s+", " ", text).strip()

if not text:
    sys.exit(0)

# The flag file may name a voice; an empty file means the system default.
voice = ""
try:
    with open(os.path.expanduser("~/.claude/speak-on")) as f:
        voice = f.read().strip()
except OSError:
    pass

# Stop any in-progress speech so responses never overlap.
subprocess.run(["killall", "say"], capture_output=True)
command = ["say", "-v", voice] if voice else ["say"]
result = subprocess.run(command, input=text.encode("utf-8"))
if result.returncode != 0 and voice:
    # Unknown voice: fall back to the system default.
    subprocess.run(["say"], input=text.encode("utf-8"))
PYEOF
