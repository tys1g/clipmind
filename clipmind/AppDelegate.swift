import AppKit
import Carbon.HIToolbox

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = HistoryStore()
    private var monitor: ClipboardMonitor!
    private var panel: PanelController!
    private var statusItem: NSStatusItem!
    private var hotKey: HotKey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel = PanelController(store: store)

        monitor = ClipboardMonitor { [weak self] text, sourceApp in
            self?.store.add(text, sourceApp: sourceApp)
        }
        monitor.start()

        hotKey = HotKey(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey)) { [weak self] in
            self?.panel.toggle()
        }

        setupStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.saveNow()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "doc.on.clipboard",
            accessibilityDescription: "Clipmind"
        )

        let menu = NSMenu()
        menu.addItem(withTitle: "Открыть историю  ⌘⇧V", action: #selector(openPanel), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Очистить историю…", action: #selector(clearHistory), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Выйти", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    @objc private func openPanel() {
        panel.show()
    }

    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Очистить всю историю?"
        alert.informativeText = "Это действие нельзя отменить."
        alert.addButton(withTitle: "Очистить")
        alert.addButton(withTitle: "Отмена")
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            store.clear()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
