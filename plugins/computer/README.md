# computer

Spoken responses, like the ship's computer. A `Stop` hook reads each of Claude's responses aloud via macOS `say`.

The hook strips markdown before it speaks: fenced code blocks become the phrase "Code omitted", and inline code, links, tables, headers, and list markers are reduced to plain prose. It also silences any speech still in progress, so responses never overlap.

Speech is off by default. The hook only speaks while the flag file `~/.claude/speak-on` exists, so you can toggle it mid-session without touching any settings.

Requires macOS (`say`) and `python3`.

## Skills

### speak

Turn on spoken responses (`touch ~/.claude/speak-on`). Name a voice to use it; the flag file holds the voice name, and an empty file means the system default. Run `say -v '?'` to see the available voices.

**Usage:**

- `/computer:speak` — enable speech (keeps any voice chosen earlier)
- `/computer:speak Samantha` — enable speech in the named voice

### mute

Turn off spoken responses and silence any speech in progress (`rm ~/.claude/speak-on; killall say`).

**Usage:** `/computer:mute`
