pragma ComponentBehavior: Bound

import "popouts" as BarPopouts
import "components"
import "components/workspaces"
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.config

// TOP BAR: Horizontal RowLayout running left→right across the top of the screen.
// Ported from vertical ColumnLayout (left bar) — key swaps:
//   ColumnLayout  → RowLayout
//   vPadding      → hPadding  (now left/right padding instead of top/bottom)
//   fillHeight    → fillWidth  (spacer expands horizontally)
//   AlignHCenter  → AlignVCenter
//   topMargin/bottomMargin → leftMargin/rightMargin
//   checkPopout(y) → checkPopout(x)  (horizontal cursor position)
//   handleWheel(y) → handleWheel(x)  (left/right half determines volume vs brightness)

RowLayout {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen
    // hPadding: horizontal padding at the left and right ends of the bar
    readonly property int hPadding: Appearance.padding.large

    function closeTray(): void {
        if (!Config.bar.tray.compact)
            return;

        for (let i = 0; i < repeater.count; i++) {
            const loader = repeater.itemAt(i) as WrappedLoader;
            if (loader?.enabled && loader.id === "tray") {
                (loader.item as Tray).expanded = false;
            }
        }
    }

    // checkPopout: x is the horizontal cursor position along the bar
    function checkPopout(x: real): void {
        const ch = childAt(x, height / 2) as WrappedLoader;

        if (ch?.id !== "tray")
            closeTray();

        if (!ch) {
            popouts.hasCurrent = false;
            return;
        }

        const id = ch.id;
        const left = ch.x;

        if (id === "statusIcons" && Config.bar.popouts.statusIcons) {
            const items = (ch.item as StatusIcons).items;
            const icon = items.childAt(mapToItem(items, x, 0).x, items.height / 2);
            if (icon) {
                popouts.currentName = icon.name;
                // currentCenter is now the x-center of the hovered icon
                popouts.currentCenter = Qt.binding(() => icon.mapToItem(root, icon.implicitWidth / 2, 0).x);
                popouts.hasCurrent = true;
            }
        } else if (id === "tray" && Config.bar.popouts.tray) {
            const tray = ch.item as Tray;
            if (!Config.bar.tray.compact || (tray.expanded && !tray.expandIcon.contains(mapToItem(tray.expandIcon, x, tray.implicitHeight / 2)))) {
                const index = Math.floor(((x - left - tray.padding * 2 + tray.spacing) / tray.layout.implicitWidth) * tray.items.count);
                const trayItem = tray.items.itemAt(index);
                if (trayItem) {
                    popouts.currentName = `traymenu${index}`;
                    popouts.currentCenter = Qt.binding(() => trayItem.mapToItem(root, trayItem.implicitWidth / 2, 0).x);
                    popouts.hasCurrent = true;
                } else {
                    popouts.hasCurrent = false;
                }
            } else {
                popouts.hasCurrent = false;
                tray.expanded = true;
            }
        } else if (id === "activeWindow" && Config.bar.popouts.activeWindow && Config.bar.activeWindow.showOnHover) {
            popouts.currentName = id.toLowerCase();
            popouts.currentCenter = (ch.item as Item).mapToItem(root, (ch.item as Item).implicitWidth / 2, 0).x ?? 0;
            popouts.hasCurrent = true;
        }
    }

    // handleWheel: x is horizontal cursor position; left half = volume, right half = brightness
    function handleWheel(x: real, angleDelta: point): void {
        const ch = childAt(x, height / 2) as WrappedLoader;
        if (ch?.id === "workspaces" && Config.bar.scrollActions.workspaces) {
            const mon = (Config.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor);
            const specialWs = mon?.lastIpcObject.specialWorkspace.name;
            if (specialWs?.length > 0)
                Hypr.dispatch(`togglespecialworkspace ${specialWs.slice(8)}`);
            else if (angleDelta.y < 0 || (Config.bar.workspaces.perMonitorWorkspaces ? mon.activeWorkspace?.id : Hypr.activeWsId) > 1)
                Hypr.dispatch(`workspace r${angleDelta.y > 0 ? "-" : "+"}1`);
        } else if (x < screen.width / 2 && Config.bar.scrollActions.volume) {
            // Volume scroll on the left half of the bar
            if (angleDelta.y > 0)
                Audio.incrementVolume();
            else if (angleDelta.y < 0)
                Audio.decrementVolume();
        } else if (Config.bar.scrollActions.brightness) {
            // Brightness scroll on the right half of the bar
            const monitor = Brightness.getMonitorForScreen(screen);
            if (angleDelta.y > 0)
                monitor.setBrightness(monitor.brightness + Config.services.brightnessIncrement);
            else if (angleDelta.y < 0)
                monitor.setBrightness(monitor.brightness - Config.services.brightnessIncrement);
        }
    }

    spacing: Appearance.spacing.normal

    Repeater {
        id: repeater

        model: Config.bar.entries

        DelegateChooser {
            role: "id"

            DelegateChoice {
                roleValue: "spacer"
                delegate: WrappedLoader {
                    Layout.fillWidth: enabled   // expands horizontally in RowLayout
                }
            }
            DelegateChoice {
                roleValue: "logo"
                delegate: WrappedLoader {
                    sourceComponent: OsIcon {}
                }
            }
            DelegateChoice {
                roleValue: "workspaces"
                delegate: WrappedLoader {
                    sourceComponent: Workspaces {
                        screen: root.screen
                        fullscreen: root.fullscreen
                    }
                }
            }
            DelegateChoice {
                roleValue: "activeWindow"
                delegate: WrappedLoader {
                    Layout.fillWidth: true      // takes remaining horizontal space
                    visible: !root.fullscreen
                    sourceComponent: ActiveWindow {
                        bar: root
                        monitor: Brightness.getMonitorForScreen(root.screen)
                    }
                }
            }
            DelegateChoice {
                roleValue: "tray"
                delegate: WrappedLoader {
                    visible: !root.fullscreen
                    sourceComponent: Tray {}
                }
            }
            DelegateChoice {
                roleValue: "clock"
                delegate: WrappedLoader {
                    visible: !root.fullscreen
                    sourceComponent: Clock {}
                }
            }
            DelegateChoice {
                roleValue: "statusIcons"
                delegate: WrappedLoader {
                    visible: !root.fullscreen
                    sourceComponent: StatusIcons {}
                }
            }
            DelegateChoice {
                roleValue: "power"
                delegate: WrappedLoader {
                    sourceComponent: Power {
                        visibilities: root.visibilities
                    }
                }
            }
        }
    }

    component WrappedLoader: Loader {
        required enabled
        required property string id
        required property int index

        function findFirstEnabled(): Item {
            const count = repeater.count;
            for (let i = 0; i < count; i++) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        function findLastEnabled(): Item {
            for (let i = repeater.count - 1; i >= 0; i--) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        asynchronous: true
        Layout.alignment: Qt.AlignVCenter   // centre items vertically in the horizontal bar

        // Left/right padding on the first and last enabled items
        Layout.leftMargin: findFirstEnabled() === this ? root.hPadding : 0
        Layout.rightMargin: findLastEnabled() === this ? root.hPadding : 0

        visible: enabled
        active: enabled
    }
}
