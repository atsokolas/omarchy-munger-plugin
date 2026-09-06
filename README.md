# Munger

One Charlie Munger quote a day, on the Omarchy bar.

Charlie sits in the bar — drawn, not photographed: the broad face, the hair
that is left, and the big round spectacles. Hover him for the day's quote, click
him for the quote in full, and browse the rest of the deck from there. Nothing is
fetched: the deck ships with the plugin, so it works offline and costs nothing
to run.

He blinks now and then. Copy a quote and he winks; shuffle and he raises his
eyebrows.

## Install

```bash
omarchy plugin add https://github.com/atsokolas/omarchy-munger-plugin.git --enable
```

That clones the plugin into `~/.config/omarchy/plugins/atsokolas.munger`,
validates it against the shell's manifest schema, and puts it on the bar. Move
it if it did not land where you want:

```bash
omarchy bar move atsokolas.munger --section right --before omarchy.network
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

QML holds only presentation. `CharlieIcon.qml` draws him on a Canvas from one
path in a unit square, so the same drawing serves the bar at 14px and the panel
at 40; below 18px the eyebrows and nose are left out so what remains still reads.

### Glyphs

This machine's JetBrainsMono Nerd Font maps the MDI block at different
codepoints than the published v3 cheat sheets, so every glyph here was render
checked before use:

| Glyph | Codepoint | Used for |
|---|---|---|
| `“` `”` | U+201C, U+201D | the marks around the quote in the panel |
| `󰆏` | U+F018F | copy |
| `󰒝` | U+F049D | shuffle |
| `󰃭` | U+F00ED | back to today |

`❝` (U+275D) is **not** in the font and renders blank — do not swap the marks
for ornamental ones without checking:

```bash
magick -size 700x160 xc:'#1a1b26' -font /usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf \
  -pointsize 70 -fill white -annotate +20+105 'GLYPH' /tmp/t.png
```

After editing anything here, run `omarchy restart shell` before believing what
you see — the in-process hot reload will happily keep serving the previous QML
and the previously imported `Model.js`.

## The quotes

48 quotes, tagged by theme. The tags are our own grouping, not his. Where a
quote's provenance is a matter of record — the 1994 USC talk, the 2007 USC law
school commencement, the 1986 Harvard School address, and a few others — the
entry carries a `src` that the panel shows under the attribution; the rest go
without rather than guess. Add or remove entries in the `QUOTES` array in
`Model.js` — the tests check that every entry has text and a tag, that there are
no duplicates, and that nothing is too long to read in the panel.

## The day

A small `Service.qml` holds the day — one clock per shell rather than one per
bar — so every monitor turns over together, and anything else on the shell (the
Front Page, say) can read `todayQuote` through `shell.serviceFor("atsokolas.munger")`.

## Remove

```bash
omarchy plugin disable atsokolas.munger
omarchy plugin remove atsokolas.munger --yes
```

## License

MIT.
