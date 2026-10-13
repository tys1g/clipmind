import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var monitor: ClipboardMonitor!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        monitor = ClipboardMonitor { text, sourceApp in
            print("📋 [\(sourceApp ?? "?")] \(text.prefix(80))")
        }
        monitor.start()
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
