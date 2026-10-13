import Foundation

struct History: Codable, Equatable {
    private(set) var items: [ClipItem]
    var limit: Int

    init(items: [ClipItem] = [], limit: Int = 500) {
        self.items = items
        self.limit = limit
    }

    private var pinnedCount: Int {
        items.firstIndex { !$0.isPinned } ?? items.count
    }

    @discardableResult
    mutating func add(_ text: String, sourceApp: String? = nil, now: Date = Date()) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        if let index = items.firstIndex(where: { $0.text == text }) {
            var existing = items.remove(at: index)
            existing.lastUsedAt = now
            existing.useCount += 1
            if let sourceApp {
                existing.sourceApp = sourceApp
            }
            items.insert(existing, at: existing.isPinned ? 0 : pinnedCount)
        } else {
            items.insert(ClipItem(text: text, createdAt: now, sourceApp: sourceApp), at: pinnedCount)
            trimToLimit()
        }
        return true
    }

    mutating func togglePin(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        var item = items.remove(at: index)
        item.isPinned.toggle()
        items.insert(item, at: item.isPinned ? 0 : pinnedCount)
    }

    mutating func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    mutating func clear() {
        items.removeAll { !$0.isPinned }
    }

    private mutating func trimToLimit() {
        let unpinned = items.count - pinnedCount
        if unpinned > limit {
            items.removeLast(unpinned - limit)
        }
    }
}

struct HistoryFile {
    let url: URL
    
    /// ~/Library/Application Support/Clipmind/history.json
    static func defaultLocation() -> HistoryFile {
        let base = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!
        return HistoryFile(url: base.appendingPathComponent("Clipmind/history.json"))
    }
    
    /// if we can't get a file - return history, not error
    func load() -> History {
        guard let data = try? Data(contentsOf: url) else {
            return History()
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(History.self, from: data)) ?? History()
    }
    func save(_ history: History) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(history)
        
        // .atomic: writing in temp file, soon changes. history alive after app down
        try data.write(to: url, options: [.atomic])
    }
}
