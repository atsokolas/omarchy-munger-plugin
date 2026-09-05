import QtQuick
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
}
