import QtQuick
import QtTest
import "../../qml" as Desktop

TestCase {
    id: testCase
    name: "UsageCard"
    when: windowShown
    QtObject {
        id: desktop
        property var settings: ({quotaDisplay: "remaining", resetDisplay: "countdown",
            showPace: true, warningColors: true, notifyThreshold: 10})
        signal changed()
    }
    property var card: null
    Component { id: cardComponent; Desktop.UsageCard {} }

    function labelItem(item, text) {
        if (item.text === text) return item;
        for (var i = 0; i < item.children.length; ++i) {
            var found = labelItem(item.children[i], text);
            if (found) return found;
        }
        return null;
    }
    function shown(text) { return card && labelItem(card.contentItem, text) !== null; }
    function cardX(label) { return card.mapFromItem(label, 0, 0).x; }
    function cardY(label) { return card.mapFromItem(label, 0, 0).y; }

    function test_extraDetailSectionsFlowBesideTheFirst() {
        card = createTemporaryObject(cardComponent, testCase, {
            visible: true,
            entry: {provider: "zai", accountLabel: "", plan: "lite", error: "", credits: null,
                windows: [{label: "7 day", remaining: 60, resetsAt: "2030-01-01T00:00:00Z", pace: ""}],
                details: [
                    {title: "Quota details", rows: [{label: "Credit quota", value: "39.9% used"}]},
                    {title: "Hourly tokens", rows: [{label: "GLM-5.3-flash", value: "71.4M"}]},
                    {title: "Daily tokens", rows: [{label: "GLM-5.3-flash", value: "341M"}]}],
                extraUsage: {period: "October 2026", used: 0.47, balance: 4.87, limit: 0}}});
        verify(card);
        tryVerify(function() { return shown("Hourly tokens") && shown("Daily tokens"); });
        var first = labelItem(card.contentItem, "Quota details");
        var hourly = labelItem(card.contentItem, "Hourly tokens");
        var daily = labelItem(card.contentItem, "Daily tokens");
        verify(first && hourly && daily);
        verify(cardX(hourly) > cardX(first), 'the extra sections sit beside the first section');
        verify(cardX(daily) > cardX(first));
        verify(cardY(daily) > cardY(hourly), 'the extra sections stack in one column');
        verify(shown("October 2026: Spent $0.47 · Balance $4.87"));
        verify(shown("91% left"), 'the billing percentage follows the funded pool share');
    }

    function test_billingLineWithoutAPoolRendersNoBar() {
        card = createTemporaryObject(cardComponent, testCase, {
            visible: true,
            entry: {provider: "acme", accountLabel: "", plan: "", error: "", credits: null,
                windows: [], details: [],
                extraUsage: {period: "", used: 1, limit: 0}}});
        verify(card);
        tryVerify(function() { return shown("Spent $1.00"); });
        verify(!shown("% left"), 'no percentage label without a computable pool');
    }
}
