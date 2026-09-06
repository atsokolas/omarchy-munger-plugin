// Pure helpers for the Munger Omarchy plugin. QML imports this file; Node
// tests require the same exports at the bottom.

var APP_NAME = "Munger"
var ATTRIBUTION = "Charlie Munger"
// U+201C renders in JetBrainsMono Nerd Font; the ornamental quote marks
// (U+275D) and the Nerd Font MDI quote glyphs do not. See the font notes in
// README.md before swapping this.
var QUOTE_MARK = "“"

// The deck. `src` names where a quote was said when that is a matter of
// record; the rest go without rather than guess. Order here is irrelevant —
// the daily pick shuffles a fresh permutation for every cycle through the
// deck, so this array is just
// storage. Tags are our own grouping, not Munger's.
var QUOTES = [
  { text: "The big money is not in the buying and selling, but in the waiting.", tag: "Patience" },
  { text: "Show me the incentive and I will show you the outcome.", tag: "Incentives" },
  { text: "It is remarkable how much long-term advantage people like us have gotten by trying to be consistently not stupid, instead of trying to be very intelligent.", tag: "Judgment" },
  { text: "Invert, always invert: turn a situation or problem upside down. Look at it backward.", tag: "Inversion", src: "After the mathematician Carl Jacobi" },
  { text: "Knowing what you don't know is more useful than being brilliant.", tag: "Judgment" },
  { text: "The first rule of compounding: never interrupt it unnecessarily.", tag: "Compounding" },
  { text: "Spend each day trying to be a little wiser than you were when you woke up.", tag: "Learning", src: "USC Gould School of Law commencement, 2007" },
  { text: "In my whole life, I have known no wise people who didn't read all the time — none, zero.", tag: "Learning" },
  { text: "Take a simple idea and take it seriously.", tag: "Focus" },
  { text: "You must know the big ideas in the big disciplines and use them routinely — all of them, not just a few.", tag: "Thinking", src: "A Lesson on Elementary, Worldly Wisdom · USC, 1994" },
  { text: "All I want to know is where I'm going to die, so I'll never go there.", tag: "Inversion" },
  { text: "A great business at a fair price is superior to a fair business at a great price.", tag: "Investing" },
  { text: "Mimicking the herd invites regression to the mean.", tag: "Independence" },
  { text: "We have three baskets for investing: yes, no, and too tough to understand.", tag: "Investing" },
  { text: "Those who keep learning will keep rising in life.", tag: "Learning" },
  { text: "I did not intend to get rich. I just wanted to get independent.", tag: "Independence" },
  { text: "Acquire worldly wisdom and adjust your behavior accordingly.", tag: "Learning" },
  { text: "To the man with only a hammer, every problem looks like a nail.", tag: "Thinking", src: "A Lesson on Elementary, Worldly Wisdom · USC, 1994" },
  { text: "The desire to get rich fast is pretty dangerous.", tag: "Temperament" },
  { text: "Envy is a really stupid sin, because it's the only one you could never possibly have any fun at.", tag: "Temperament" },
  { text: "You don't have to pee on an electric fence to learn not to do it.", tag: "Learning" },
  { text: "It's not supposed to be easy. Anyone who finds it easy is stupid.", tag: "Temperament" },
  { text: "Opportunity comes to the prepared mind.", tag: "Preparation", src: "After Louis Pasteur" },
  { text: "The way to get what you want is to deserve what you want.", tag: "Character", src: "USC Gould School of Law commencement, 2007" },
  { text: "People calculate too much and think too little.", tag: "Thinking" },
  { text: "Live within your income and save so that you can invest.", tag: "Money" },
  { text: "There is no better teacher than history in determining the future.", tag: "Learning" },
  { text: "The wise ones bet heavily when the world offers them that opportunity.", tag: "Conviction", src: "A Lesson on Elementary, Worldly Wisdom · USC, 1994" },
  { text: "Simplicity has a way of improving performance by enabling us to better understand what we are doing.", tag: "Simplicity" },
  { text: "Remember that reputation and integrity are your most valuable assets — and can be lost in a heartbeat.", tag: "Character" },
  { text: "A majority of life's errors are caused by forgetting what one is really trying to do.", tag: "Focus" },
  { text: "I constantly see people rise in life who are not the smartest, sometimes not even the most diligent, but they are learning machines.", tag: "Learning", src: "USC Gould School of Law commencement, 2007" },
  { text: "Understanding both the power of compound interest and the difficulty of getting it is the heart and soul of understanding a lot of things.", tag: "Compounding" },
  { text: "The iron rule of nature is: you get what you reward for.", tag: "Incentives", src: "The Psychology of Human Misjudgment" },
  { text: "Someone will always be getting richer faster than you. This is not a tragedy.", tag: "Temperament" },
  { text: "It's waiting that helps you as an investor, and a lot of people just can't stand to wait.", tag: "Patience" },
  { text: "You have to keep learning, or you're going to be left behind.", tag: "Learning" },
  { text: "Every mischance in life is an opportunity to behave well and learn something.", tag: "Adversity", src: "Harvard School commencement, 1986" },
  { text: "Assume life will be really tough, and then ask if you can handle it. If the answer is yes, you've won.", tag: "Adversity" },
  { text: "Choose clients as you would choose friends.", tag: "Character" },
  { text: "Extreme specialization is the way to succeed.", tag: "Focus", src: "Daily Journal annual meeting, 2017" },
  { text: "The great lesson in microeconomics is to discriminate between when technology is going to help you and when it's going to kill you.", tag: "Business", src: "A Lesson on Elementary, Worldly Wisdom · USC, 1994" },
  { text: "You need patience, discipline, and an agility to take losses and adversity without going crazy.", tag: "Temperament" },
  { text: "If you're not confused, you don't understand it very well.", tag: "Thinking" },
  { text: "Wisdom acquisition is a moral duty.", tag: "Learning", src: "USC Gould School of Law commencement, 2007" },
  { text: "It's so simple: you spend less than you earn, invest shrewdly, avoid toxic people and toxic activities, and try to keep learning all your life.", tag: "Money" },
  { text: "In business we often find that the winning system goes almost ridiculously far in maximizing or minimizing one or a few variables.", tag: "Business", src: "A Lesson on Elementary, Worldly Wisdom · USC, 1994" },
  { text: "You should never, when facing some unbelievable tragedy, let one tragedy increase into two or three through a failure of will.", tag: "Adversity", src: "Harvard School commencement, 1986" }
]

var DAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var MONTH_NAMES = ["January", "February", "March", "April", "May", "June",
                   "July", "August", "September", "October", "November", "December"]

// ---------------------------------------------------------------- the deck

// Days since the Unix epoch for a local calendar date. Going through Date.UTC
// on the local Y/M/D keeps every hour of a day — DST transitions included —
// on the same number, so the quote changes at local midnight and not before.
function dayNumber(date) {
  // `new Date(null)` is the epoch rather than an error, which would silently
  // hand a missing date the quote for 1 January 1970 — or 31 December 1969
  // west of Greenwich. Reject the empty cases before constructing.
  if (date === null || date === undefined || date === "") return 0
  var d = date instanceof Date ? date : new Date(date)
  if (!d || isNaN(d.getTime())) return 0
  return Math.floor(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / 86400000)
}

// Lehmer/minstd. Deliberately small: every intermediate stays well under
// 2^53, so QML's JS engine and Node agree bit for bit.
function seededRandom(seed) {
  var state = Math.abs(Math.floor(seed)) % 2147483646 + 1
  return function () {
    state = (state * 16807) % 2147483647
    return (state - 1) / 2147483646
  }
}

// A shuffled reading order for one pass through the deck. Every quote comes
// up exactly once per cycle — no repeats until you've seen them all — and a
// new cycle reshuffles, so the sequence never becomes familiar.
function cycleOrder(cycle, count) {
  var total = Math.max(1, Math.floor(count))
  var order = []
  for (var i = 0; i < total; i++) order.push(i)
  var rand = seededRandom((Math.abs(Math.floor(cycle)) % 1000000 + 1) * 2654435761 % 2147483647)
  for (var j = total - 1; j > 0; j--) {
    var k = Math.floor(rand() * (j + 1))
    var swap = order[j]
    order[j] = order[k]
    order[k] = swap
  }
  return order
}

function quoteIndexForDay(day, count) {
  var total = Math.max(1, Math.floor(count))
  var d = Math.floor(day)
  var cycle = Math.floor(d / total)
  var position = d - cycle * total
  return cycleOrder(cycle, total)[position]
}

function quoteAt(index) {
  if (!QUOTES.length) return { text: "", tag: "", index: 0 }
  var total = QUOTES.length
  var i = Math.floor(index) % total
  if (i < 0) i += total
  var entry = QUOTES[i]
  return { text: entry.text, tag: entry.tag, src: entry.src || "", index: i }
}

function quoteForDay(day) {
  return quoteAt(quoteIndexForDay(day, QUOTES.length))
}

function quoteForDate(date) {
  return quoteForDay(dayNumber(date))
}

// Step through the deck in the order the days will actually serve it, so
// browsing forward from today shows tomorrow's quote next.
function stepIndex(fromDay, delta) {
  return Math.floor(fromDay) + Math.floor(delta)
}

// ------------------------------------------------------------- presentation

// Trim at a word boundary so the bar never shows half a word. Ellipsis only
// when something was actually dropped.
function teaser(text, maxChars) {
  var s = String(text || "").replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "")
  var max = Math.max(4, Math.floor(maxChars || 40))
  if (s.length <= max) return s
  var cut = s.slice(0, max)
  var space = cut.lastIndexOf(" ")
  if (space > max * 0.5) cut = cut.slice(0, space)
  return cut.replace(/[\s,;:.\-—]+$/, "") + "…"
}

function tooltipText(quote) {
  var text = quote && quote.text ? String(quote.text) : ""
  if (text === "") return APP_NAME
  return QUOTE_MARK + text + "”\n— " + ATTRIBUTION
}

function dateLine(date) {
  var d = date instanceof Date ? date : new Date(date)
  if (!d || isNaN(d.getTime())) return ""
  return DAY_NAMES[d.getDay()] + ", " + d.getDate() + " " + MONTH_NAMES[d.getMonth()]
}

// The header's second line: which quote you're looking at, and whether it is
// the one the day handed you.
function positionLine(browsing, index, total, date) {
  if (!browsing) return dateLine(date)
  return "Quote " + (Math.floor(index) + 1) + " of " + Math.max(1, Math.floor(total))
}

function attributionLine(quote) {
  var tag = quote && quote.tag ? String(quote.tag) : ""
  return tag === "" ? "— " + ATTRIBUTION : "— " + ATTRIBUTION + " · " + tag
}

// The wall label's second line: where it was said, when that is known.
function sourceLine(quote) {
  return quote && quote.src ? String(quote.src) : ""
}

function escapeHtml(text) {
  return String(text || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
}

// The panel sets the quotation between its marks, with the marks in the dim
// colour so they read as punctuation rather than as part of the line.
function quoteHtml(text, markColor) {
  var mark = function(glyph) { return '<font color="' + String(markColor || "") + '">' + glyph + '</font>' }
  return mark(QUOTE_MARK) + escapeHtml(text) + mark("”")
}

// Long quotes need to give up some size to stay inside the card. Three steps
// is enough; anything finer just looks unsteady as you page through.
function quoteFontScale(text) {
  var length = String(text || "").length
  if (length > 150) return 0.78
  if (length > 90) return 0.88
  return 1.0
}

// --------------------------------------------------------------- clipboard

function shellQuote(value) {
  return "'" + String(value === undefined || value === null ? "" : value).replace(/'/g, "'\\''") + "'"
}

function copyCommand(text) {
  return ["bash", "-c", "printf %s " + shellQuote(text) + " | wl-copy"]
}

function copyPayload(quote) {
  var text = quote && quote.text ? String(quote.text) : ""
  if (text === "") return ""
  return QUOTE_MARK + text + "” — " + ATTRIBUTION
}

// ---------------------------------------------------------------- settings

function boolSetting(value, fallback) {
  if (value === undefined || value === null) return fallback === true
  return value === true || value === "true"
}

function numberSetting(value, fallback, min, max) {
  var n = Number(value)
  if (!isFinite(n)) n = Number(fallback)
  if (!isFinite(n)) n = min
  return Math.max(min, Math.min(max, Math.round(n)))
}

if (typeof module !== "undefined") {
  module.exports = {
    APP_NAME: APP_NAME,
    ATTRIBUTION: ATTRIBUTION,
    QUOTE_MARK: QUOTE_MARK,
    QUOTES: QUOTES,
    dayNumber: dayNumber,
    seededRandom: seededRandom,
    cycleOrder: cycleOrder,
    quoteIndexForDay: quoteIndexForDay,
    quoteAt: quoteAt,
    quoteForDay: quoteForDay,
    quoteForDate: quoteForDate,
    stepIndex: stepIndex,
    teaser: teaser,
    tooltipText: tooltipText,
    dateLine: dateLine,
    positionLine: positionLine,
    attributionLine: attributionLine,
    sourceLine: sourceLine,
    escapeHtml: escapeHtml,
    quoteHtml: quoteHtml,
    quoteFontScale: quoteFontScale,
    shellQuote: shellQuote,
    copyCommand: copyCommand,
    copyPayload: copyPayload,
    boolSetting: boolSetting,
    numberSetting: numberSetting
  }
}
