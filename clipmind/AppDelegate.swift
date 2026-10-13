import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var monitor: ClipboardMonitor!
    private let store = HistoryStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        monitor = ClipboardMonitor { [weak self] text, sourceApp in
                    self?.store.add(text, sourceApp: sourceApp)
                    print("📋 в истории: \(self?.store.items.count ?? 0)")
                }
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
        menu.addItem(withTitle: "Выйти", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
        
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
