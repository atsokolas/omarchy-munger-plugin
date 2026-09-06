import QtQuick
import qs.Commons

// Charlie, drawn: the high bald dome, the jowls, the hair that is left at the
// temples, and the big rounded-square spectacles that are the whole likeness.
// One set of paths in a unit square serves two drawings — a filled bust for
// the bar, where an outline at 14px is a smudge, and a line portrait for the
// panel. He blinks now and then, winks when you copy, and raises his eyebrows
// at a shuffle.
Item {
  id: root

  property real iconSize: Style.font.icon
  property color iconColor: Color.foreground
  // The bar's ground, for the lenses knocked out of the bust.
  property color background: Color.bar.background
  // Idle blinking. Off in the panel header while it is closed, to save paint.
  property bool lively: true
  property bool wink: false

  readonly property bool bust: iconSize < 24

  // Drawn state, 0..1 each; the timers below move them.
  property real blink: 0
  property real brows: 0

  implicitWidth: iconSize
  implicitHeight: iconSize
  width: iconSize
  height: iconSize

  function raiseBrows() { browsAnimation.restart() }

  SequentialAnimation {
    id: browsAnimation
    NumberAnimation { target: root; property: "brows"; to: 1; duration: 120; easing.type: Easing.OutQuad }
    PauseAnimation { duration: 420 }
    NumberAnimation { target: root; property: "brows"; to: 0; duration: 260; easing.type: Easing.InOutQuad }
  }

  SequentialAnimation {
    id: blinkAnimation
    NumberAnimation { target: root; property: "blink"; to: 1; duration: 60 }
    PauseAnimation { duration: 80 }
    NumberAnimation { target: root; property: "blink"; to: 0; duration: 80 }
  }

  // A blink every few seconds, never on a beat.
  Timer {
    running: root.lively && root.visible
    interval: 3200 + Math.random() * 5000
    repeat: true
    onTriggered: {
      interval = 3200 + Math.random() * 5000
      if (!root.wink) blinkAnimation.restart()
    }
  }

  onBlinkChanged: canvas.requestPaint()
  onBrowsChanged: canvas.requestPaint()
  onWinkChanged: canvas.requestPaint()
  onIconColorChanged: canvas.requestPaint()
  onBackgroundChanged: canvas.requestPaint()

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // ---- the parts, in unit coordinates ------------------------------------

    function head(c) {
      c.moveTo(0.5, 0.04)
      c.bezierCurveTo(0.82, 0.04, 0.92, 0.28, 0.90, 0.52)
      c.bezierCurveTo(0.90, 0.74, 0.78, 0.95, 0.5, 0.96)
      c.bezierCurveTo(0.22, 0.95, 0.10, 0.74, 0.10, 0.52)
      c.bezierCurveTo(0.08, 0.28, 0.18, 0.04, 0.5, 0.04)
      c.closePath()
    }

    function ears(c) {
      c.moveTo(0.11, 0.45); c.bezierCurveTo(0.00, 0.43, 0.00, 0.65, 0.12, 0.65)
      c.moveTo(0.89, 0.45); c.bezierCurveTo(1.00, 0.43, 1.00, 0.65, 0.88, 0.65)
    }

    function tufts(c) {
      c.moveTo(0.13, 0.28); c.bezierCurveTo(0.04, 0.33, 0.04, 0.46, 0.11, 0.50); c.bezierCurveTo(0.08, 0.42, 0.09, 0.34, 0.13, 0.28); c.closePath()
      c.moveTo(0.87, 0.28); c.bezierCurveTo(0.96, 0.33, 0.96, 0.46, 0.89, 0.50); c.bezierCurveTo(0.92, 0.42, 0.91, 0.34, 0.87, 0.28); c.closePath()
    }

    function lenses(c, inset) {
      var d = inset || 0
      c.roundedRect(0.17 + d, 0.41 + d, 0.31 - d * 2, 0.24 - d * 2, 0.08 - d, 0.08 - d)
      c.roundedRect(0.52 + d, 0.41 + d, 0.31 - d * 2, 0.24 - d * 2, 0.08 - d, 0.08 - d)
    }

    function eyes(c, leftOpen, rightOpen) {
      if (leftOpen) { c.moveTo(0.348, 0.53); c.arc(0.32, 0.53, 0.028, 0, Math.PI * 2, false) }
      if (rightOpen) { c.moveTo(0.708, 0.53); c.arc(0.68, 0.53, 0.028, 0, Math.PI * 2, false) }
    }

    function mouth(c, smile) {
      c.moveTo(0.39, 0.83); c.quadraticCurveTo(0.5, 0.83 + smile * 0.05, 0.61, 0.83)
    }

    // ---- painting ----------------------------------------------------------

    function unit(ctx, span) {
      ctx.translate((width - span) / 2, (height - span) / 2)
      ctx.scale(span, span)
    }

    function fillPath(ctx, span, color, draw) {
      ctx.save(); unit(ctx, span); ctx.beginPath(); draw(ctx); ctx.restore()
      ctx.fillStyle = color
      ctx.fill()
    }

    function strokePath(ctx, span, color, width, draw) {
      ctx.save(); unit(ctx, span); ctx.beginPath(); draw(ctx); ctx.restore()
      ctx.lineWidth = width
      ctx.lineJoin = "round"
      ctx.lineCap = "round"
      ctx.strokeStyle = color
      ctx.stroke()
    }

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var closed = root.blink > 0.5
      var ink = root.iconColor

      if (root.bust) {
        // The bar: a filled bust, the lenses knocked out and glazed.
        var span = Math.min(width, height)
        var glass = Qt.rgba(ink.r, ink.g, ink.b, closed ? 0.9 : 0.42)
        fillPath(ctx, span, ink, function(c) { head(c); ears(c); tufts(c) })
        fillPath(ctx, span, root.background, function(c) { lenses(c, 0) })
        fillPath(ctx, span, glass, function(c) { lenses(c, 0.035) })
        if (!closed) fillPath(ctx, span, ink, function(c) { eyes(c, !root.wink, true) })
        strokePath(ctx, span, root.background, Math.max(1, span / 16), function(c) {
          c.moveTo(0.47, 0.48); c.lineTo(0.53, 0.48)
          if (root.iconSize >= 17) mouth(c, root.wink ? 1 : 0.5)
        })
        return
      }

      // The panel: a line portrait.
      var thickness = Math.max(1, root.iconSize / 15)
      var portrait = Math.min(width, height) - thickness
      strokePath(ctx, portrait, ink, thickness, function(c) {
        head(c); ears(c); lenses(c, 0)
        c.moveTo(0.47, 0.48); c.lineTo(0.53, 0.48)                       // bridge
        c.moveTo(0.16, 0.47); c.lineTo(0.10, 0.45)                       // arms
        c.moveTo(0.84, 0.47); c.lineTo(0.90, 0.45)
        var lift = root.brows * 0.05                                     // brows
        c.moveTo(0.20, 0.37 - lift); c.lineTo(0.43, 0.33 - lift)
        c.moveTo(0.57, 0.33 - lift); c.lineTo(0.80, 0.37 - lift)
        c.moveTo(0.50, 0.60); c.lineTo(0.47, 0.72); c.lineTo(0.53, 0.73) // nose
        mouth(c, root.wink ? 1.4 : 0.8)
        if (closed || root.wink) { c.moveTo(0.26, 0.53); c.lineTo(0.38, 0.53) }
        if (closed) { c.moveTo(0.62, 0.53); c.lineTo(0.74, 0.53) }
      })
      fillPath(ctx, portrait, ink, function(c) {
        tufts(c)
        if (!closed) eyes(c, !root.wink, true)
      })
    }
  }
}
