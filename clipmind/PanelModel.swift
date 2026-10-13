import Foundation
import Observation

@MainActor
@Observable
final class PanelModel {
    var query = "" {
        didSet { selected = 0 }
    }
    var selected = 0
    private(set) var focusRequest = 0

    static let visibleLimit = 200

    @ObservationIgnored private let store: HistoryStore

    init(store: HistoryStore) {
        self.store = store
    }

    var results: [ClipItem] {
        Array(FuzzySearch.filter(store.items, query: query).prefix(Self.visibleLimit))
    }

    var selectedItem: ClipItem? {
        let results = results
        return results.indices.contains(selected) ? results[selected] : nil
    }

    func reset() {
        query = ""
        selected = 0
        focusRequest += 1
    }

    func move(_ delta: Int) {
        let count = results.count
        guard count > 0 else { return }
        selected = min(max(selected + delta, 0), count - 1)
    }

    func clampSelection() {
        selected = min(selected, max(results.count - 1, 0))
    }
}
