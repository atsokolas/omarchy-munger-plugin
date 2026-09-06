import QtQuick
import qs.Commons

// Charlie, drawn: a broad face, hair only at the sides, and the big round
// spectacles that are the whole likeness. One path in a unit square, so the
// same drawing serves the bar at 14px and the panel at 40. He blinks now and
// then, winks when you copy, and raises his eyebrows at a shuffle.
Item {
  id: root

  property real iconSize: Style.font.icon
  property color iconColor: Color.foreground
  // Idle blinking. Off in the panel header while it is closed, to save paint.
  property bool lively: true
  property bool wink: false

  // Drawn state. 0..1 each; the timers below move them.
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
    PauseAnimation { duration: 70 }
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

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var thickness = Math.max(1, root.iconSize / 13)
      var span = Math.min(width, height) - thickness
      var detailed = root.iconSize >= 18
      var closed = root.blink > 0.5
      var smile = root.wink ? 1 : 0.45

      ctx.save()
      ctx.translate((width - span) / 2, (height - span) / 2)
      ctx.scale(span, span)
      ctx.beginPath()

      // The face: wide at the cheeks, a full chin.
      ctx.moveTo(0.5, 0.06)
      ctx.bezierCurveTo(0.86, 0.06, 0.92, 0.42, 0.84, 0.68)
      ctx.bezierCurveTo(0.78, 0.90, 0.62, 0.98, 0.5, 0.98)
      ctx.bezierCurveTo(0.38, 0.98, 0.22, 0.90, 0.16, 0.68)
      ctx.bezierCurveTo(0.08, 0.42, 0.14, 0.06, 0.5, 0.06)

      // Ears, and the hair that is left, above them.
      ctx.moveTo(0.14, 0.50); ctx.bezierCurveTo(0.04, 0.48, 0.04, 0.66, 0.15, 0.66)
      ctx.moveTo(0.86, 0.50); ctx.bezierCurveTo(0.96, 0.48, 0.96, 0.66, 0.85, 0.66)
      if (detailed) {
        ctx.moveTo(0.15, 0.44); ctx.quadraticCurveTo(0.06, 0.34, 0.17, 0.24)
        ctx.moveTo(0.85, 0.44); ctx.quadraticCurveTo(0.94, 0.34, 0.83, 0.24)
      }

      // The spectacles.
      var r = 0.145
      ctx.moveTo(0.35 + r, 0.52); ctx.arc(0.35, 0.52, r, 0, Math.PI * 2, false)
      ctx.moveTo(0.65 + r, 0.52); ctx.arc(0.65, 0.52, r, 0, Math.PI * 2, false)
      ctx.moveTo(0.35 + r, 0.51); ctx.lineTo(0.65 - r, 0.51)
      ctx.moveTo(0.35 - r, 0.50); ctx.lineTo(0.15, 0.48)
      ctx.moveTo(0.65 + r, 0.50); ctx.lineTo(0.85, 0.48)

      if (detailed) {
        // Eyebrows, lifted by `brows`.
        var browY = 0.33 - root.brows * 0.05
        ctx.moveTo(0.24, browY + 0.02); ctx.quadraticCurveTo(0.35, browY - 0.03, 0.46, browY + 0.02)
        ctx.moveTo(0.54, browY + 0.02); ctx.quadraticCurveTo(0.65, browY - 0.03, 0.76, browY + 0.02)
        // Nose.
        ctx.moveTo(0.5, 0.60); ctx.lineTo(0.47, 0.71); ctx.lineTo(0.53, 0.72)
      }
      if (root.iconSize >= 14) {
        // The mouth: a half-smile at rest, a whole one for a wink.
        ctx.moveTo(0.37, 0.82); ctx.quadraticCurveTo(0.5, 0.82 + smile * 0.09, 0.63, 0.82)
      }

      // Closed eyes are lids; open ones are dots, filled below.
      if (closed || root.wink) ctx.moveTo(0.29, 0.53), ctx.lineTo(0.41, 0.53)
      if (closed) ctx.moveTo(0.59, 0.53), ctx.lineTo(0.71, 0.53)
      ctx.restore()

      ctx.lineWidth = thickness
      ctx.lineJoin = "round"
      ctx.lineCap = "round"
      ctx.strokeStyle = root.iconColor
      ctx.stroke()

      if (!closed) {
        ctx.save()
        ctx.translate((width - span) / 2, (height - span) / 2)
        ctx.scale(span, span)
        ctx.beginPath()
        if (!root.wink) { ctx.moveTo(0.38, 0.53); ctx.arc(0.35, 0.53, 0.03, 0, Math.PI * 2, false) }
        ctx.moveTo(0.68, 0.53); ctx.arc(0.65, 0.53, 0.03, 0, Math.PI * 2, false)
        ctx.restore()
        ctx.fillStyle = root.iconColor
        ctx.fill()
      }
    }
  }
}
