const test = require("node:test")
const assert = require("node:assert/strict")
const Model = require("../Model.js")

test("the deck is non-empty and every entry has text and a tag", () => {
  assert.ok(Model.QUOTES.length > 20)
  for (const quote of Model.QUOTES) {
    assert.equal(typeof quote.text, "string")
    assert.ok(quote.text.length > 10, `too short: ${quote.text}`)
    assert.ok(quote.tag && quote.tag.length > 0, `missing tag: ${quote.text}`)
  }
})

test("the deck has no duplicates", () => {
  const seen = new Set(Model.QUOTES.map((q) => q.text))
  assert.equal(seen.size, Model.QUOTES.length)
})

test("dayNumber is stable across a whole local day", () => {
  const morning = new Date(2026, 8, 5, 0, 0, 0)
  const night = new Date(2026, 8, 5, 23, 59, 59)
  assert.equal(Model.dayNumber(morning), Model.dayNumber(night))
  assert.equal(Model.dayNumber(new Date(2026, 8, 6, 0, 0, 0)), Model.dayNumber(morning) + 1)
})

test("dayNumber survives a DST boundary without skipping or repeating", () => {
  // Europe/London springs forward on 2026-03-29.
  const before = Model.dayNumber(new Date(2026, 2, 28, 12, 0, 0))
  const during = Model.dayNumber(new Date(2026, 2, 29, 12, 0, 0))
  const after = Model.dayNumber(new Date(2026, 2, 30, 12, 0, 0))
  assert.equal(during, before + 1)
  assert.equal(after, during + 1)
})

test("dayNumber falls back to 0 on junk", () => {
  assert.equal(Model.dayNumber("not a date"), 0)
  assert.equal(Model.dayNumber(null), 0)
})

test("a cycle order is a permutation of the deck", () => {
  const total = Model.QUOTES.length
  for (const cycle of [0, 1, 7, 412]) {
    const order = Model.cycleOrder(cycle, total)
    assert.equal(order.length, total)
    assert.deepEqual([...order].sort((a, b) => a - b), [...Array(total).keys()])
  }
})

test("consecutive cycles shuffle differently", () => {
  const total = Model.QUOTES.length
  assert.notDeepEqual(Model.cycleOrder(0, total), Model.cycleOrder(1, total))
  assert.notDeepEqual(Model.cycleOrder(5, total), Model.cycleOrder(6, total))
})

test("cycle order is deterministic", () => {
  const total = Model.QUOTES.length
  assert.deepEqual(Model.cycleOrder(9, total), Model.cycleOrder(9, total))
})

test("every quote is served exactly once per pass through the deck", () => {
  const total = Model.QUOTES.length
  // Cycles are aligned to day numbers, so start the window on a boundary —
  // that is the run over which the no-repeats guarantee actually holds.
  const start = Math.ceil(Model.dayNumber(new Date(2026, 8, 5)) / total) * total
  const seen = new Set()
  for (let i = 0; i < total; i++) seen.add(Model.quoteIndexForDay(start + i, total))
  assert.equal(seen.size, total)
})

test("a run of days never repeats a quote inside the same cycle", () => {
  const total = Model.QUOTES.length
  const start = Model.dayNumber(new Date(2026, 8, 5))
  for (let i = 0; i < 400; i++) {
    const day = start + i
    const cycle = Math.floor(day / total)
    for (let back = 1; back < total; back++) {
      if (Math.floor((day - back) / total) !== cycle) break
      assert.notEqual(
        Model.quoteIndexForDay(day, total),
        Model.quoteIndexForDay(day - back, total),
        `repeat ${back} days apart at day ${day}`
      )
    }
  }
})

test("negative day numbers stay in range", () => {
  const total = Model.QUOTES.length
  for (const day of [-1, -47, -1000]) {
    const index = Model.quoteIndexForDay(day, total)
    assert.ok(index >= 0 && index < total, `out of range: ${index}`)
  }
})

test("quoteForDate is the same all day and changes overnight", () => {
  const morning = Model.quoteForDate(new Date(2026, 8, 5, 7, 30))
  const evening = Model.quoteForDate(new Date(2026, 8, 5, 22, 15))
  const tomorrow = Model.quoteForDate(new Date(2026, 8, 6, 7, 30))
  assert.deepEqual(morning, evening)
  assert.notEqual(tomorrow.index, morning.index)
})

test("quoteAt wraps in both directions", () => {
  const total = Model.QUOTES.length
  assert.equal(Model.quoteAt(total).index, 0)
  assert.equal(Model.quoteAt(-1).index, total - 1)
})

test("stepIndex walks days", () => {
  assert.equal(Model.stepIndex(20000, 1), 20001)
  assert.equal(Model.stepIndex(20000, -3), 19997)
})

test("teaser trims at a word boundary and marks the cut", () => {
  const trimmed = Model.teaser("Show me the incentive and I will show you the outcome.", 24)
  assert.ok(trimmed.endsWith("…"))
  assert.ok(trimmed.length <= 25)
  assert.ok(!trimmed.includes("incentiv…"))
})

test("teaser leaves short text alone", () => {
  assert.equal(Model.teaser("Invert, always invert.", 40), "Invert, always invert.")
})

test("teaser collapses whitespace and tolerates empties", () => {
  assert.equal(Model.teaser("  a   b  ", 40), "a b")
  assert.equal(Model.teaser(null, 40), "")
})

test("tooltip carries the quote and the attribution", () => {
  const tip = Model.tooltipText({ text: "Invert, always invert." })
  assert.ok(tip.includes("Invert, always invert."))
  assert.ok(tip.includes("Charlie Munger"))
  assert.equal(Model.tooltipText(null), "Munger")
})

test("dateLine reads as a date", () => {
  assert.equal(Model.dateLine(new Date(2026, 8, 5)), "Saturday, 5 September")
  assert.equal(Model.dateLine("nope"), "")
})

test("positionLine switches between the date and the deck position", () => {
  assert.equal(Model.positionLine(false, 3, 48, new Date(2026, 8, 5)), "Saturday, 5 September")
  assert.equal(Model.positionLine(true, 3, 48, new Date(2026, 8, 5)), "Quote 4 of 48")
})

test("attribution appends the tag when there is one", () => {
  assert.equal(Model.attributionLine({ tag: "Patience" }), "— Charlie Munger · Patience")
  assert.equal(Model.attributionLine({}), "— Charlie Munger")
})

test("long quotes step down in size", () => {
  assert.equal(Model.quoteFontScale("short"), 1.0)
  assert.equal(Model.quoteFontScale("x".repeat(100)), 0.88)
  assert.equal(Model.quoteFontScale("x".repeat(200)), 0.78)
})

test("every quote in the deck stays within the smallest size step", () => {
  for (const quote of Model.QUOTES) {
    assert.ok(quote.text.length < 220, `unreadably long: ${quote.text}`)
  }
})

test("shellQuote survives apostrophes", () => {
  assert.equal(Model.shellQuote("don't"), "'don'\\''t'")
  assert.equal(Model.shellQuote(null), "''")
})

test("copyCommand pipes the exact text to wl-copy", () => {
  const command = Model.copyCommand("It's not supposed to be easy.")
  assert.equal(command[0], "bash")
  assert.equal(command[1], "-c")
  assert.ok(command[2].endsWith("| wl-copy"))
  assert.ok(command[2].includes("'\\''"))
})

test("copyPayload wraps the quote with its attribution", () => {
  assert.equal(
    Model.copyPayload({ text: "Invert, always invert." }),
    "“Invert, always invert.” — Charlie Munger"
  )
  assert.equal(Model.copyPayload(null), "")
})

test("settings readers fall back sanely", () => {
  assert.equal(Model.boolSetting(undefined, true), true)
  assert.equal(Model.boolSetting(null, false), false)
  assert.equal(Model.boolSetting("true", false), true)
  assert.equal(Model.boolSetting(false, true), false)
  assert.equal(Model.numberSetting(undefined, 34, 12, 80), 34)
  assert.equal(Model.numberSetting("120", 34, 12, 80), 80)
  assert.equal(Model.numberSetting(-5, 34, 12, 80), 12)
})

test("sources are attached only where the deck records one", () => {
  const withSource = Model.QUOTES.filter(q => q.src)
  assert.ok(withSource.length >= 10)
  for (const q of Model.QUOTES) if (q.src) assert.ok(q.src.length > 8, q.text)
  const hammer = Model.QUOTES.findIndex(q => q.text.startsWith("To the man with only a hammer"))
  assert.match(Model.sourceLine(Model.quoteAt(hammer)), /USC, 1994$/)
  assert.equal(Model.sourceLine(Model.quoteAt(Model.QUOTES.findIndex(q => !q.src))), "")
  assert.equal(Model.sourceLine(null), "")
})

test("the panel sets the quotation between marks in the dim colour", () => {
  assert.equal(Model.quoteHtml("Show me the incentive.", "#777"),
    '<font color="#777">“</font>Show me the incentive.<font color="#777">”</font>')
  assert.equal(Model.escapeHtml("a < b & c"), "a &lt; b &amp; c")
  assert.ok(Model.quoteHtml("x < y", "#000").includes("x &lt; y"))
})
