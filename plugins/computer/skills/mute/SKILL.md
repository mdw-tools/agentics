---
name: mute
description: Turn off spoken responses and silence any speech in progress.
---

The user wants spoken responses turned off.

Run this command:

```
rm -f ~/.claude/speak-on; killall say 2>/dev/null; true
```

Then reply with one short confirmation sentence (it is not spoken — the flag is already off).
