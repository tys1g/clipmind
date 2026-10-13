import Foundation
import Observation

@MainActor
@Observable
final class HistoryStore {
    private(set) var items: [ClipItem] = []

    @ObservationIgnored private var history: History
    @ObservationIgnored private let file = HistoryFile.defaultLocation()
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    init() {
        history = file.load()
        items = history.items
    }

    func add(_ text: String, sourceApp: String?) {
        guard history.add(text, sourceApp: sourceApp) else { return }
        commit()
    }

    func remove(id: UUID) {
        history.remove(id: id)
        commit()
    }

    func clear() {
        history.clear()
        commit()
    }

    func saveNow() {
        saveTask?.cancel()
        saveTask = nil
        do {
            try file.save(history)
        } catch {
            print("⚠️ Не удалось сохранить историю: \(error)")
        }
    }

    private func commit() {
        items = history.items
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self?.saveNow()
        }
    }
}
