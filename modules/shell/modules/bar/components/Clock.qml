pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.services
import qs.config

// TOP BAR: horizontal clock pill — fixed height, dynamic width.
// Previously fixed width / dynamic height for the left-side bar.
// Column → Row; time shown on a single line instead of stacked lines.

StyledRect {
    id: root

    readonly property color colour: Colours.palette.m3tertiary
    readonly property int padding: Config.bar.clock.background ? Appearance.padding.normal : Appearance.padding.small

    implicitHeight: Config.bar.sizes.innerWidth
    implicitWidth: layout.implicitWidth + root.padding * 2

    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, Config.bar.clock.background ? Colours.tPalette.m3surfaceContainer.a : 0)
    radius: Appearance.rounding.full

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        Loader {
            asynchronous: true
            anchors.verticalCenter: parent.verticalCenter

            active: Config.bar.clock.showIcon
            visible: active

            sourceComponent: MaterialIcon {
                text: "calendar_month"
                color: root.colour
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            visible: Config.bar.clock.showDate

            // Date on a single line: "Mon 7"
            text: Time.format("ddd d")
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.sans
            color: root.colour
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.bar.clock.showDate
            width: visible ? 1 : 0
            height: parent.height * 0.6
            color: root.colour
            opacity: 0.2
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter

            // Time on a single line: "14:30" or "02:30 PM"
            text: Time.format(Config.services.useTwelveHourClock ? "hh:mm A" : "hh:mm")
            font.pointSize: Appearance.font.size.smaller
            font.family: Appearance.font.family.mono
            color: root.colour
        }
    }
}
