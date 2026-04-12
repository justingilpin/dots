pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.utils
import qs.modules.bar.popouts as BarPopouts

// TOP BAR: This wrapper manages a horizontal bar anchored to the TOP of the screen.
// It slides downward (grows implicitHeight) from the top edge when revealed.
//
// Ported from left-side vertical bar — key conceptual swaps:
//   left  → top      (bar edge)
//   width → height   (bar dimension)
//   x     → y        (position axis)
//   implicitWidth → implicitHeight  (animation property)
//   clampedWidth  → clampedHeight   (referenced in Regions.qml + Interactions.qml)
//   contentWidth  → contentHeight   (full expanded size)

Item {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen

    readonly property bool disabled: Strings.testRegexList(Config.bar.excludedScreens, screen.name)

    // clampedHeight replaces clampedWidth — used in Regions.qml and Interactions.qml
    readonly property int clampedHeight: Math.max(Config.border.minThickness, implicitHeight)
    readonly property int padding: Math.max(Appearance.padding.smaller, Config.border.thickness)
    // contentHeight replaces contentWidth — full expanded height of the bar strip
    readonly property int contentHeight: Config.bar.sizes.innerWidth + padding * 2
    readonly property int exclusiveZone: !disabled && (Config.bar.persistent || visibilities.bar) ? contentHeight : Config.border.thickness
    readonly property bool shouldBeVisible: !fullscreen && !disabled && (Config.bar.persistent || visibilities.bar || isHovered)
    property bool isHovered

    function closeTray(): void {
        (content.item as Bar)?.closeTray();
    }

    // checkPopout takes x (horizontal cursor position) instead of y for horizontal bar
    function checkPopout(x: real): void {
        (content.item as Bar)?.checkPopout(x);
    }

    // handleWheel takes x instead of y for position-based scroll zone detection
    function handleWheel(x: real, angleDelta: point): void {
        (content.item as Bar)?.handleWheel(x, angleDelta);
    }

    clip: true
    visible: height > 0
    // Collapsed state: just the thin border strip height
    implicitHeight: fullscreen ? 0 : Config.border.thickness

    states: State {
        name: "visible"
        when: root.shouldBeVisible

        PropertyChanges {
            root.implicitHeight: root.contentHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content

        // Bar content sits at the bottom of the expanding wrapper so it slides into view
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        active: root.shouldBeVisible || root.visible

        sourceComponent: Bar {
            height: root.contentHeight
            screen: root.screen
            visibilities: root.visibilities
            popouts: root.popouts // qmllint disable incompatible-type
            fullscreen: root.fullscreen
        }
    }
}
