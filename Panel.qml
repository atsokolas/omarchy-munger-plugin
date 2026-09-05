import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Munger — one Charlie Munger quote a day on the Omarchy bar.
//
// There is nothing to fetch, so there is no service: the deck ships with the
// plugin and the day picks from it. The bar shows today's quote; the panel
// shows it in full and lets you wander the rest of the deck.
Panel {
  id: root
  moduleName: "atsokolas.munger"
  ipcTarget: "atsokolas.munger"
  manageIpc: false

  // --- state ---------------------------------------------------------------

  // Rolled over by a timer rather than read fresh each paint, so the quote
  // changes on its own at local midnight without the panel being reopened.
  property date today: new Date()
  readonly property int todayDay: Model.dayNumber(today)

  // Browsing walks the deck in the order the days will serve it. `viewDay` is
  // only meaningful while `browsing`; leaving browse mode snaps back to today.
  property bool browsing: false
  property int viewDay: 0
  readonly property int activeDay: browsing ? viewDay : todayDay

  readonly property var quote: Model.quoteForDay(activeDay)
  readonly property var todayQuote: Model.quoteForDay(todayDay)

  readonly property bool showTeaser: Model.boolSetting(setting("showTeaser", false), false)
  readonly property int teaserLength: Model.numberSetting(setting("teaserLength", 34), 34, 12, 80)

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool vertical: bar ? bar.vertical : false

  // --- actions -------------------------------------------------------------

  function browseBy(delta) {
    if (delta === 0) return
    if (!browsing) {
      browsing = true
      viewDay = todayDay
    }
    viewDay = Model.stepIndex(viewDay, delta)
  }

  function backToToday() {
    browsing = false
  }

  // A shuffle that lands on today's quote is a shuffle that looks broken, so
  // keep drawing until the deck offers something else.
  function shuffle() {
    var total = Model.QUOTES.length
    if (total < 2) return
    var next = activeDay
    for (var attempt = 0; attempt < 12 && next === activeDay; attempt++)
      next = todayDay + 1 + Math.floor(Math.random() * (total - 1))
    browsing = true
    viewDay = next
  }

  function copyQuote() {
    var payload = Model.copyPayload(quote)
    if (payload === "") return
    Quickshell.execDetached(Model.copyCommand(payload))
    copiedTimer.restart()
  }

  function handleClose() {
    if (browsing) backToToday()
    else close()
  }

  // Leaving the panel should not leave you parked three days into the deck.
  onOpenedChanged: {
    if (!opened) {
      backToToday()
      return
    }
    today = new Date()
    revealAnimation.restart()
    Qt.callLater(function () { keyCatcher.forceActiveFocus() })
  }

  // The quote settles in whenever it changes — on open, on browse, at
  // midnight. Same timeline every time, so paging through feels of a piece.
  property real reveal: 1
  NumberAnimation {
    id: revealAnimation
    target: root
    property: "reveal"
    from: 0
    to: 1
    duration: 240
    easing.type: Easing.OutCubic
  }

  onQuoteChanged: if (opened) revealAnimation.restart()
  onTodayDayChanged: markPulse.restart()

  Timer {
    id: copiedTimer
    interval: 1600
    repeat: false
  }

  // One tick a minute is plenty to catch midnight, and costs nothing next to
  // waking on a timer scheduled for the exact second.
  Timer {
    interval: 60000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
      var now = new Date()
      if (Model.dayNumber(now) !== root.todayDay) root.today = now
    }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function next(): string { root.browseBy(1); return "ok" }
    function previous(): string { root.browseBy(-1); return "ok" }
    function shuffle(): string { root.shuffle(); return "ok" }
    function today(): string { root.backToToday(); return "ok" }
    function copy(): string { root.copyQuote(); return "ok" }
    // Prints the day's quote, so scripts and greeters can use the same deck.
    function quote(): string { return Model.copyPayload(root.todayQuote) }
    function status(): string {
      return JSON.stringify({
        day: root.todayDay,
        index: root.todayQuote.index,
        tag: root.todayQuote.tag,
        total: Model.QUOTES.length,
        browsing: root.browsing,
        showTeaser: root.showTeaser
      })
    }
  }

  // --- bar button ----------------------------------------------------------

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    labelVisible: false
    hasVisualContent: true
    // Measured from the painted content: the quotation mark is far narrower
    // than the label box a plain WidgetButton would size itself to.
    fixedWidth: button.vertical
      ? -1
      : Math.max(Style.bar.iconSlot, pill.contentWidth + button.scaledHorizontalMargin * 2)
    foreground: root.opened
      ? Color.accent
      : (root.bar ? root.bar.barForeground : Color.foreground)
    tooltipText: Model.tooltipText(root.todayQuote)

    onPressed: function (buttonCode) {
      if (buttonCode === Qt.MiddleButton) root.copyQuote()
      else if (buttonCode === Qt.RightButton) { root.open(); root.shuffle() }
      else root.toggle()
    }

    Item {
      id: pill
      anchors.fill: parent

      readonly property real gap: Style.space(6)
      readonly property bool teaserVisible: root.showTeaser && !button.vertical
      readonly property real contentWidth: teaserVisible
        ? mark.implicitWidth + gap + teaserText.implicitWidth
        : mark.implicitWidth

      QuoteMark {
        id: mark
        markSize: Style.bar.iconFont
        color: button.foreground
        fontFamily: button.fontFamily
        width: implicitWidth
        height: parent.height
        x: pill.teaserVisible ? button.scaledHorizontalMargin : (parent.width - implicitWidth) / 2

        // A small nod each time the quote turns over.
        transformOrigin: Item.Center
        SequentialAnimation on scale {
          id: markPulse
          running: false
          NumberAnimation { to: 1.22; duration: 140; easing.type: Easing.OutBack }
          NumberAnimation { to: 1.0; duration: 320; easing.type: Easing.OutCubic }
        }
      }

      Text {
        id: teaserText
        visible: pill.teaserVisible
        x: mark.x + mark.implicitWidth + pill.gap
        anchors.verticalCenter: parent.verticalCenter
        text: Model.teaser(root.todayQuote.text, root.teaserLength)
        color: button.foreground
        font.family: button.fontFamily
        font.pixelSize: button.fontSize
        renderType: Text.NativeRendering
      }
    }
  }

  // --- panel ---------------------------------------------------------------

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(440))
    contentHeight: panel.fittedContentHeight(content.implicitHeight, Style.space(520))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function (dx, dy) {
        if (dy !== 0) root.browseBy(dy)
        else if (dx !== 0) root.browseBy(dx)
      }
      onActivateRequested: root.copyQuote()
      onCloseRequested: root.handleClose()
      onTabRequested: function (direction) { root.switchPanel(direction) }
      onTextKey: function (text) {
        var key = String(text || "").toLowerCase()
        if (key === "c") root.copyQuote()
        else if (key === "s") root.shuffle()
        else if (key === "t") root.backToToday()
      }

      ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: Style.space(12)

        // ---- header
        Item {
          Layout.fillWidth: true
          implicitHeight: Math.max(heroMark.implicitHeight, heroLabels.implicitHeight, headerButtons.implicitHeight)

          QuoteMark {
            id: heroMark
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            markSize: Style.font.display
            color: root.foreground
            fontFamily: root.fontFamily
          }

          Column {
            id: heroLabels
            anchors.left: heroMark.right
            anchors.leftMargin: Style.space(14)
            anchors.right: headerButtons.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: Model.APP_NAME
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: copiedTimer.running
                ? "Copied to clipboard"
                : Model.positionLine(root.browsing, root.quote.index, Model.QUOTES.length, root.today)
              color: copiedTimer.running ? Color.accent : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
            }
          }

          Row {
            id: headerButtons
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            PanelActionButton {
              visible: root.browsing
              iconText: "󰃭"
              tooltipText: "Back to today (t)"
              foreground: root.foreground
              fontFamily: root.fontFamily
              onClicked: root.backToToday()
            }

            PanelActionButton {
              iconText: "󰒝"
              tooltipText: "Another one (s)"
              foreground: root.foreground
              fontFamily: root.fontFamily
              onClicked: root.shuffle()
            }

            PanelActionButton {
              iconText: "󰆏"
              tooltipText: "Copy (c)"
              foreground: root.foreground
              fontFamily: root.fontFamily
              onClicked: root.copyQuote()
            }
          }
        }

        PanelSeparator { Layout.fillWidth: true; foreground: root.foreground }

        // ---- the quote
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          implicitHeight: quoteBlock.implicitHeight + Style.space(16)

          Column {
            id: quoteBlock
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(12)
            opacity: root.reveal
            transform: Translate { y: (1 - root.reveal) * Style.space(8) }

            Text {
              width: parent.width
              text: root.quote.text
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Math.max(Style.font.body,
                                       Math.round(Style.font.title * Model.quoteFontScale(root.quote.text)))
              wrapMode: Text.WordWrap
              lineHeight: 1.35
              lineHeightMode: Text.ProportionalHeight
            }

            Text {
              width: parent.width
              text: Model.attributionLine(root.quote)
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
            }
          }
        }

        // ---- footer
        Text {
          Layout.fillWidth: true
          text: "j/k browse · s another · c copy" + (root.browsing ? " · t today" : "")
          color: Qt.darker(root.foreground, 2.1)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }
  }
}
