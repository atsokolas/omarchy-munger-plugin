# Munger

One Charlie Munger quote a day, on the Omarchy bar.

A quotation mark sits in the bar. Hover it for the day's quote, click it for the
quote in full, and browse the rest of the deck from there. Nothing is fetched:
the deck ships with the plugin, so it works offline and costs nothing to run.

## Install

The plugin lives at `~/.config/omarchy/plugins/atsokolas.munger/`. Add it to a
bar section in `~/.config/omarchy/shell.json`:

```json
{ "id": "atsokolas.munger" }
```

or from the shell:

```bash
omarchy bar move atsokolas.munger --section right
```

## Interactions

| Where | Action | Result |
|---|---|---|
| Bar | left click | open/close the panel |
| Bar | right click | open on a random quote |
| Bar | middle click | copy the day's quote |
| Panel | `j` / `k`, arrows | walk the deck |
| Panel | `s` | another one, at random |
| Panel | `c`, Enter | copy to the clipboard |
| Panel | `t` | back to today |
| Panel | Esc | back to today, then close |

## Settings

Both live on the widget's `shell.json` entry, and both are editable from the
bar widget settings panel.

| Key | Default | What it does |
|---|---|---|
| `showTeaser` | `false` | Put a trimmed line of the quote on the bar next to the mark |
| `teaserLength` | `34` | How much of it fits before it is cut at a word boundary |

```json
{ "id": "atsokolas.munger", "showTeaser": true, "teaserLength": 44 }
```

## IPC

```bash
omarchy-shell atsokolas.munger quote      # print today's quote
omarchy-shell atsokolas.munger status     # JSON: day, deck position, settings
omarchy-shell atsokolas.munger copy       # copy the showing quote
omarchy-shell atsokolas.munger shuffle    # open on a random one
omarchy-shell atsokolas.munger next|previous|today
omarchy-shell atsokolas.munger open|close|toggle
```

`quote` prints the same line the bar is showing, so a login greeter or a
`fastfetch` hook can share the deck.

## How the day picks

The deck is shuffled into a fresh reading order for every pass through it, seeded
by the cycle number. Each quote comes up exactly once per pass — no repeats until
you have seen all 48 — and the next pass reshuffles, so the sequence never becomes
familiar. The day number comes from the local calendar date via `Date.UTC`, so the
quote turns over at local midnight and holds steady across DST changes.

## Development

Pure logic lives in `Model.js` — the deck, the shuffle, trimming, formatting,
the clipboard command — and is covered by Node tests:

```bash
./tests/run
```

QML holds only presentation. `QuoteMark.qml` exists because a quotation mark
hangs at the top of the em square: it measures the tight bounding rect and
centres the painted ink instead of the line box.

### Glyphs

This machine's JetBrainsMono Nerd Font maps the MDI block at different
codepoints than the published v3 cheat sheets, so every glyph here was render
checked before use:

| Glyph | Codepoint | Used for |
|---|---|---|
| `“` | U+201C | the mark, in the bar and the panel |
| `󰆏` | U+F018F | copy |
| `󰒝` | U+F049D | shuffle |
| `󰃭` | U+F00ED | back to today |

`❝` (U+275D) is **not** in the font and renders blank — do not swap the mark
for an ornamental one without checking:

```bash
magick -size 700x160 xc:'#1a1b26' -font /usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf \
  -pointsize 70 -fill white -annotate +20+105 'GLYPH' /tmp/t.png
```

After editing anything here, run `omarchy restart shell` before believing what
you see — the in-process hot reload will happily keep serving the previous QML
and the previously imported `Model.js`.

## The quotes

48 quotes, tagged by theme. They are widely circulated Munger lines rather than
citations to a particular talk or letter; the tags are our own grouping, not his.
Add or remove entries in the `QUOTES` array in `Model.js` — the tests check that
every entry has text and a tag, that there are no duplicates, and that nothing is
too long to read in the panel.

## License

MIT.
