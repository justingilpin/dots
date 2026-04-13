pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components
import qs.config
import qs.services

Scope {
    id: root

    property bool visible: false

    function toggle(): void { root.visible = !root.visible; }
    function open():   void { root.visible = true; }
    function close():  void { root.visible = false; }

    // qmllint disable unresolved-type
    CustomShortcut {
    // qmllint enable unresolved-type
        name: "cheatsheet"
        description: "Toggle keybind cheatsheet"
        onPressed: root.toggle()
    }

    Loader {
        active: root.visible

        sourceComponent: PanelWindow {
            id: win

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "caelestia:cheatsheet"
            exclusiveZone: -1
            color: "transparent"

            HyprlandFocusGrab {
                active: root.visible
                windows: [win]
                onCleared: root.close()
            }

            // Dim backdrop
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }
            }

            // Card
            Rectangle {
                id: card
                anchors.centerIn: parent
                color: Colours.palette.m3surfaceContainer
                radius: Appearance.rounding.large
                implicitWidth: cardLayout.implicitWidth + Appearance.padding.large * 4
                implicitHeight: cardLayout.implicitHeight + Appearance.padding.large * 4

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        root.close();
                }

                ColumnLayout {
                    id: cardLayout
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.large

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: "keyboard"
                            color: Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.large
                        }
                        StyledText {
                            text: "Keybinds"
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.large
                            font.weight: 600
                        }
                        Item { Layout.fillWidth: true }
                        StyledText {
                            text: "Esc / click outside to close"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colours.palette.m3outlineVariant
                        opacity: 0.5
                    }

                    // Three columns
                    RowLayout {
                        spacing: Appearance.spacing.large * 2
                        Layout.alignment: Qt.AlignTop

                        // ── Column 1 ─────────────────────────────────────────
                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            spacing: Appearance.spacing.large

                            KeySection {
                                title: "Apps"
                                binds: [
                                    { keys: "Super + Return",     action: "Terminal (alacritty)" },
                                    { keys: "Super + B",          action: "Browser (firefox)" },
                                    { keys: "Super + E",          action: "File manager (thunar)" },
                                    { keys: "Super + R",          action: "Launcher" },
                                ]
                            }

                            KeySection {
                                title: "Windows"
                                binds: [
                                    { keys: "Super + Shift + C",  action: "Close window" },
                                    { keys: "Super + F",          action: "Fullscreen" },
                                    { keys: "Super + V",          action: "Toggle float" },
                                    { keys: "Super + P",          action: "Pseudo tile" },
                                    { keys: "Super + Space",      action: "Toggle split" },
                                    { keys: "Super + M",          action: "Exit Hyprland" },
                                ]
                            }

                            KeySection {
                                title: "Focus"
                                binds: [
                                    { keys: "Super + H",          action: "Focus left" },
                                    { keys: "Super + L",          action: "Focus right" },
                                    { keys: "Super + K",          action: "Focus up" },
                                    { keys: "Super + J",          action: "Focus down" },
                                ]
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1
                            color: Colours.palette.m3outlineVariant
                            opacity: 0.5
                        }

                        // ── Column 2 ─────────────────────────────────────────
                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            spacing: Appearance.spacing.large

                            KeySection {
                                title: "Resize"
                                binds: [
                                    { keys: "Super + Shift + L",  action: "Expand right" },
                                    { keys: "Super + Shift + H",  action: "Expand left" },
                                    { keys: "Super + Shift + K",  action: "Expand up" },
                                    { keys: "Super + Shift + J",  action: "Expand down" },
                                    { keys: "Super + LMB drag",   action: "Move window" },
                                    { keys: "Super + RMB drag",   action: "Resize window" },
                                ]
                            }

                            KeySection {
                                title: "Workspaces"
                                binds: [
                                    { keys: "Super + 1–10",       action: "Switch to workspace" },
                                    { keys: "Super + Shift + 1–10", action: "Move window to workspace" },
                                    { keys: "Super + S",          action: "Toggle scratchpad" },
                                    { keys: "Super + Shift + S",  action: "Move to scratchpad" },
                                    { keys: "Super + scroll",     action: "Cycle workspaces" },
                                ]
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1
                            color: Colours.palette.m3outlineVariant
                            opacity: 0.5
                        }

                        // ── Column 3 ─────────────────────────────────────────
                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            spacing: Appearance.spacing.large

                            KeySection {
                                title: "Shell Panels"
                                binds: [
                                    { keys: "Super + Tab",        action: "Show all panels" },
                                    { keys: "Super + D",          action: "Dashboard" },
                                    { keys: "Super + \\",         action: "Sidebar" },
                                    { keys: "Ctrl + Space",       action: "Control center" },
                                    { keys: "Super + Shift + E",  action: "Session menu" },
                                ]
                            }

                            KeySection {
                                title: "Shell System"
                                binds: [
                                    { keys: "Super + Shift + Q",  action: "Restart Quickshell" },
                                    { keys: "Super + /",          action: "This cheatsheet" },
                                    { keys: "Bar scroll (left)",  action: "Volume" },
                                    { keys: "Bar scroll (right)", action: "Brightness" },
                                    { keys: "Bar scroll (ws)",    action: "Switch workspace" },
                                ]
                            }

                            KeySection {
                                title: "Hardware Keys"
                                binds: [
                                    { keys: "Brightness ↑/↓",    action: "Screen brightness" },
                                    { keys: "Volume ↑/↓",        action: "Speaker volume" },
                                    { keys: "Mute",               action: "Toggle mute" },
                                    { keys: "Mic Mute",           action: "Toggle mic" },
                                    { keys: "Play/Next/Prev",     action: "Media control" },
                                    { keys: "Print",              action: "Screenshot (full)" },
                                    { keys: "Ctrl + Print",       action: "Screenshot (area)" },
                                ]
                            }
                        }
                    }
                }
            }

            component KeySection: ColumnLayout {
                required property string title
                required property var binds

                spacing: Appearance.spacing.small

                StyledText {
                    text: title
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600
                }

                Repeater {
                    model: binds

                    RowLayout {
                        required property var modelData
                        spacing: Appearance.spacing.normal

                        Rectangle {
                            implicitWidth: keyLabel.implicitWidth + Appearance.padding.normal * 2
                            implicitHeight: keyLabel.implicitHeight + Appearance.padding.small
                            color: Colours.palette.m3surfaceContainerHigh
                            radius: Appearance.rounding.small

                            StyledText {
                                id: keyLabel
                                anchors.centerIn: parent
                                text: modelData.keys
                                color: Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.smaller
                                font.family: Appearance.font.family.mono
                            }
                        }

                        StyledText {
                            text: modelData.action
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }
            }
        }
    }
}
