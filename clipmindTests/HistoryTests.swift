import Foundation
import Testing
@testable import clipmind

struct HistoryTests {
    @Test func newItemsGoOnTop() {
        var h = History()
        h.add("one")
        h.add("two")
        #expect(h.items.map(\.text) == ["two", "one"])
    }

    @Test func duplicateMovesToTopAndCountsUses() {
        var h = History()
        h.add("one")
        h.add("two")
        h.add("one")
        #expect(h.items.map(\.text) == ["one", "two"])
        #expect(h.items[0].useCount == 2)
    }

    @Test func emptyAndWhitespaceIgnored() {
        var h = History()
        #expect(h.add("") == false)
        #expect(h.add("   \n\t") == false)
        #expect(h.items.isEmpty)
    }

    @Test func limitDropsOldest() {
        var h = History(limit: 3)
        for i in 1...5 { h.add("\(i)") }
        #expect(h.items.map(\.text) == ["5", "4", "3"])
    }

    @Test func removeAndClear() {
        var h = History()
        h.add("a")
        h.add("b")
        h.remove(id: h.items[0].id)
        #expect(h.items.map(\.text) == ["a"])
        h.clear()
        #expect(h.items.isEmpty)
    }

    @Test func saveAndLoadRoundTrip() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("history.json")
        let file = HistoryFile(url: url)

        var h = History()
        h.add("привет", sourceApp: "Telegram")
        h.add("hello")
        try file.save(h)

        let loaded = file.load()
        #expect(loaded.items.map(\.text) == ["hello", "привет"])
        #expect(loaded.items[1].sourceApp == "Telegram")
    }

    @Test func loadMissingFileGivesEmptyHistory() {
        let file = HistoryFile(url: URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString).json"))
        #expect(file.load().items.isEmpty)
    }

    @Test func titleIsFirstNonEmptyLine() {
        #expect(ClipItem(text: "\n\n  hello world \nsecond").title == "hello world")
    }
}
