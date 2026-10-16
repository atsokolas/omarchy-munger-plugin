import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

// One clock per shell. Every bar — one per monitor — reads this instance, so
// the day turns over once, and anything else on the shell that wants today's
// quote can ask for it here rather than reaching into the panel.
Item {
  id: root

  property var shell: null
  property var settings: ({})
  property bool active: true

  property date today: new Date()
  readonly property int todayDay: Model.dayNumber(today)
  readonly property var todayQuote: Model.quoteForDay(todayDay)

  // Wakes on the minute, so the quote turns over within a second of midnight
  // — in step with the other daily widgets.
  Timer {
    running: root.active
    interval: 60000 - Date.now() % 60000
    onTriggered: {
      interval = 60000 - Date.now() % 60000
      restart()
      var now = new Date()
      if (Model.dayNumber(now) !== root.todayDay) root.today = now
    }
  }

  // The theme's palette, read from colors.toml and kept current.
  readonly property string colorsPath: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
  property var palette: null

  FileView {
    path: root.colorsPath
    watchChanges: true
    printErrors: false
    onLoaded: root.palette = Model.parseColors(text())
    onLoadFailed: root.palette = null
    onFileChanged: reload()
  }
}
