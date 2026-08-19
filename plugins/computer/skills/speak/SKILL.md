---
name: speak
description: Turn on spoken responses, optionally in a named voice. The Stop hook speaks each of Claude's responses aloud via macOS `say`.
---

The user wants Claude's responses spoken aloud. They may name a voice: "$ARGUMENTS"

## No voice given

Run this command (it preserves any voice chosen earlier):

```
touch ~/.claude/speak-on
```

## Voice given

The flag file holds the voice name. The hook passes it to `say -v`.

1. List the available voices with `say -v '?'`.
2. Match the requested voice against the list, ignoring case.
3. If the voice exists, write its canonical name into the flag file:

   ```
   printf '%s' 'Samantha' > ~/.claude/speak-on
   ```

4. If the voice does not exist, do not guess. Enable speech with the default voice (`> ~/.claude/speak-on`), then tell the user the voice was not found and list a few similar or notable voices from the list.
5. To reset to the default voice, empty the file: `> ~/.claude/speak-on`.

## Confirm

Reply with one short confirmation sentence, in the style of the Enterprise computer (for example: "Speech interface online."). Name the voice if one was set. The Stop hook speaks the reply aloud, so keep it brief and free of code or markdown.
