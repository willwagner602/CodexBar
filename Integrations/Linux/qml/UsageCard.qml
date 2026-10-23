import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Shared/Usage.js" as Usage

Frame {
    id: root
    required property var entry
    property color accent: palette.highlight
    readonly property int cardFontSize: 10
    padding: 14
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + topPadding + bottomPadding
    ColumnLayout {
        id: content
        width: parent.width
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            Label { text: Usage.providerName(root.entry.provider); font.bold: true; font.pixelSize: 13; Layout.fillWidth: true; wrapMode: Text.Wrap }
            Label { text: root.entry.plan || ""; font.pixelSize: root.cardFontSize; opacity: 0.65; Layout.maximumWidth: root.width / 2; wrapMode: Text.Wrap; textFormat: Text.PlainText }
        }
        Label {
            text: root.entry.accountLabel || ""
            font.pixelSize: root.cardFontSize
            visible: text !== ""
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
        }
        Label { text: root.entry.error || ""; font.pixelSize: root.cardFontSize; visible: text !== ""; Layout.fillWidth: true; wrapMode: Text.Wrap }
        ColumnLayout {
            visible: Usage.hasBilling(root.entry)
            Layout.fillWidth: true
            spacing: 4
            Label { text: "Billing"; font.pixelSize: root.cardFontSize; font.bold: true; visible: root.visible }
            Label {
                text: Usage.billingText(root.entry.extraUsage, true)
                font.pixelSize: root.cardFontSize
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }
        Repeater {
            model: Usage.cardWindows(root.entry.windows)
            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: modelData.label; font.pixelSize: root.cardFontSize; Layout.fillWidth: true; wrapMode: Text.Wrap; textFormat: Text.PlainText }
                    Label { text: Usage.quotaValue(modelData.remaining, desktop.settings.quotaDisplay) + "% " + (desktop.settings.quotaDisplay === "used" ? "used" : "left"); font.pixelSize: root.cardFontSize; font.bold: true }
                }
                ProgressBar { Layout.fillWidth: true; from: 0; to: 100; value: Usage.quotaValue(modelData.remaining, desktop.settings.quotaDisplay); palette.highlight: desktop.settings.warningColors && modelData.remaining <= desktop.settings.notifyThreshold ? "#d97732" : root.accent }
                Label { text: Usage.resetText(modelData.resetsAt, clock.now, desktop.settings.resetDisplay); font.pixelSize: root.cardFontSize; opacity: 0.65; Layout.fillWidth: true; wrapMode: Text.Wrap }
                Label { text: modelData.pace || ""; visible: desktop.settings.showPace && text !== ""; font.pixelSize: root.cardFontSize; Layout.fillWidth: true; wrapMode: Text.Wrap; opacity: 0.7 }
            }
        }
        Label { text: "Credits: " + root.entry.credits; font.pixelSize: root.cardFontSize; visible: root.entry.credits !== null && root.entry.credits !== undefined }
        Repeater {
            model: root.entry.details || []
            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                Label { text: modelData.title; visible: text !== ""; font.pixelSize: root.cardFontSize; font.bold: true }
                Repeater {
                    model: modelData.rows
                    Label {
                        required property var modelData
                        Layout.fillWidth: true
                        font.pixelSize: root.cardFontSize
                        text: modelData.label + ": " + modelData.value + (modelData.secondaryValue ? " · " + modelData.secondaryValue : "")
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                    }
                }
                UsageChart { Layout.fillWidth: true; chart: modelData.chart; accent: root.accent }
            }
        }
    }
    Timer { id: clock; property double now: Date.now(); interval: 30000; running: root.visible; repeat: true; onTriggered: now = Date.now() }
}
