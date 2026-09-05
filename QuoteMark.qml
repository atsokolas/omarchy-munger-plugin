import QtQuick
import qs.Commons

// A single quotation mark, centred on its ink rather than on its line box.
//
// A quotation mark hangs at the very top of the em square, so the usual
// `anchors.centerIn` leaves it floating well above the middle of whatever it
// sits in — obvious next to a bar icon, glaring beside a panel title. This
// measures the tight bounding rect and places the painted box itself.
Item {
  id: root

  property string glyph: "“"
  property real markSize: Style.font.body
  property color color: Color.foreground
  property string fontFamily: Style.font.family
  property bool bold: true

  readonly property int renderedSize: Math.max(1, Math.round(markSize))
  readonly property rect ink: metrics.tightBoundingRect

  implicitWidth: Math.max(1, Math.ceil(ink.width))
  implicitHeight: Math.max(1, Math.ceil(ink.height))

  TextMetrics {
    id: metrics
    font.family: root.fontFamily
    font.pixelSize: root.renderedSize
    font.bold: root.bold
    text: root.glyph
  }

  Text {
    id: glyph
    text: root.glyph
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: root.renderedSize
    font.bold: root.bold
    renderType: Text.NativeRendering

    // tightBoundingRect is measured from the baseline origin: x runs right
    // from the pen position, y up (negative) from the baseline.
    x: root.width / 2 - root.ink.x - root.ink.width / 2
    y: root.height / 2 - glyph.baselineOffset - root.ink.y - root.ink.height / 2
  }
}
