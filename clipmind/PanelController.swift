import AppKit
import SwiftUI

@MainActor
final class PanelController {
    private let panel = FloatingPanel()
    private let store: HistoryStore
    private let model: PanelModel
    private var keyMonitor: Any?

    init(store: HistoryStore) {
        self.store = store
        self.model = PanelModel(store: store)

        let view = ClipListView(model: model) { [weak self] item in
            self?.pick(item)
        }
        panel.contentView = NSHostingView(rootView: view)
        panel.onClose = { [weak self] in self?.hide() }
    }

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func show() {
        model.reset()
        positionOnActiveScreen()
        panel.makeKeyAndOrderFront(nil)
        installKeyMonitor()
    }

    func hide() {
        guard panel.isVisible else { return }
        removeKeyMonitor()
        panel.orderOut(nil)
    }

    private func pick(_ item: ClipItem) {
        hide()
        Paster.paste(item.text)
    }

    private func positionOnActiveScreen() {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return }
        let size = panel.frame.size
        panel.setFrameOrigin(NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.minY + visible.height * 0.62 - size.height / 2
        ))
    }

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isKeyWindow else { return event }
            return self.handle(event) ? nil : event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
    }

    private func handle(_ event: NSEvent) -> Bool {
        let command = event.modifierFlags.contains(.command)

        switch Int(event.keyCode) {
        case 125:                                   // ↓
            model.move(1)
            return true
        case 126:                                   // ↑
            model.move(-1)
            return true
        case 36, 76:                                // Return, Enter
            if let item = model.selectedItem { pick(item) }
            return true
        case 53:                                    // Esc
            hide()
            return true
        case 51 where command:                      // ⌘⌫
            if let item = model.selectedItem {
                store.remove(id: item.id)
                model.clampSelection()
            }
            return true
        default:
            break
        }

        if command,
           let chars = event.charactersIgnoringModifiers,
           let digit = Int(chars), (1...9).contains(digit) {
            let results = model.results
            if results.indices.contains(digit - 1) {
                pick(results[digit - 1])
                return true
            }
        }
        return false
    }
}
