pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.modules.bar.popouts // Need to import this module so the Wrapper type is the same as others

// TOP BAR POPOUTS: Panel that holds bar hover-popouts (battery, network, etc.).
// For the top bar these slide DOWN from below the bar, centered on the hovered item's
// x position (currentCenter is now a horizontal coordinate, not vertical).
//
// Ported from left-bar version — key conceptual swaps:
//   slides LEFT  → slides UP (hidden state)
//   implicitWidth clipped → implicitHeight clipped
//   x computed from currentCenter (vertical) → x computed from currentCenter (horizontal)
//   y computed = item center  → y = 0 (always at top of panels area, just below bar)
//   anchors.verticalCenter+left → anchors.top+horizontalCenter
//   Behavior on x → Behavior on y  (detach animation)
//   Behavior on y → Behavior on x  (position-track animation)

Item {
    id: root

    required property ShellScreen screen
    required property real borderThickness

    readonly property alias content: content
    // offsetScale: 0 = fully visible, 1 = fully hidden (slid off above)
    property real offsetScale: content.isDetached || content.hasCurrent ? 0 : 1

    visible: width > 0 && height > 0
    clip: true

    // Width follows content fully (no horizontal clipping for top-bar popouts)
    implicitWidth: content.implicitWidth
    // Height clips as the popout slides up out of view
    implicitHeight: content.implicitHeight * (1 - offsetScale)

    // x: centre on the hovered bar item, clamped to stay on screen
    x: {
        if (content.isDetached)
            return (parent.width - content.nonAnimWidth) / 2;

        const off = content.currentCenter - borderThickness - content.nonAnimWidth / 2;
        const diff = parent.width - Math.floor(off + content.nonAnimWidth);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }
    // y: always at the top of the panels area (just below bar) unless detached to centre
    y: content.isDetached ? (parent.height - content.nonAnimHeight) / 2 : 0

    Behavior on offsetScale {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    // y animates when detaching/returning to screen centre
    Behavior on y {
        Anim {
            duration: content.animLength
            easing.bezierCurve: content.animCurve
        }
    }

    // x tracks the hovered item's horizontal position while visible
    Behavior on x {
        enabled: root.offsetScale < 1

        Anim {
            duration: content.animLength
            easing.bezierCurve: content.animCurve
        }
    }

    Wrapper {
        id: content

        screen: root.screen
        offsetScale: root.offsetScale

        anchors.top: parent.top
        // Slides upward off-screen when hidden (offsetScale = 1)
        anchors.topMargin: (-content.nonAnimHeight - 5) * root.offsetScale
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
