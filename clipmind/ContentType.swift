import Foundation

enum ContentType: String, Codable, CaseIterable {
    case text, link, email, phone, color, path, code

    var symbol: String {
        switch self {
        case .text:  "text.alignleft"
        case .link:  "link"
        case .email: "envelope"
        case .phone: "phone"
        case .color: "paintpalette"
        case .path:  "folder"
        case .code:  "chevron.left.forwardslash.chevron.right"
        }
    }

    var label: String {
        switch self {
        case .text:  "Текст"
        case .link:  "Ссылка"
        case .email: "Email"
        case .phone: "Телефон"
        case .color: "Цвет"
        case .path:  "Путь"
        case .code:  "Код"
        }
    }
}

enum ContentDetector {
    static func detect(_ raw: String) -> ContentType {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return .text }

        let isSingleLine = !text.contains(where: \.isNewline)
        guard isSingleLine else {
            return looksLikeCode(text) ? .code : .text
        }

        if isColor(text) { return .color }
        if isLink(text) { return .link }
        if isEmail(text) { return .email }
        if isPhone(text) { return .phone }
        if isPath(text) { return .path }
        if isShellCommand(text) { return .code }
        return .text
    }

    static func isColor(_ s: String) -> Bool {
        if s.wholeMatch(of: #/#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})/#) != nil {
            return true
        }
        let functional = #/(?i)(?:rgba?|hsla?)\(\s*[\d.]+%?\s*,\s*[\d.]+%?\s*,\s*[\d.]+%?\s*(?:,\s*[\d.]+\s*)?\)/#
        return s.wholeMatch(of: functional) != nil
    }

    static func isLink(_ s: String) -> Bool {
        guard !s.contains(" ") else { return false }
        if s.lowercased().hasPrefix("www.") { return true }
        guard let url = URL(string: s),
              let scheme = url.scheme?.lowercased(),
              url.host != nil else { return false }
        return ["http", "https", "ftp"].contains(scheme)
    }

    static func isEmail(_ s: String) -> Bool {
        s.wholeMatch(of: #/[^\s@]+@[^\s@]+\.[A-Za-z]{2,}/#) != nil
    }

    static func isPhone(_ s: String) -> Bool {
        guard s.wholeMatch(of: #/\+?[\d\s\-()]+/#) != nil else { return false }
        let digits = s.filter(\.isNumber).count
        // С плюсом — международный формат, без плюса требуем минимум 10 цифр,
        // чтобы даты вроде 2026-10-13 не считались телефоном.
        return s.hasPrefix("+") ? (7...15).contains(digits) : (10...15).contains(digits)
    }

    static func isPath(_ s: String) -> Bool {
        guard !s.contains("://"), s.count > 1 else { return false }
        return ["/", "~/", "./", "../"].contains { s.hasPrefix($0) }
    }

    private static let shellCommands: Set<String> = [
        "git", "npm", "npx", "yarn", "pnpm", "docker", "kubectl", "brew", "sudo",
        "cd", "ls", "curl", "wget", "ssh", "scp", "pip", "pip3", "python3",
        "swift", "xcodebuild", "grep", "rm", "mv", "cp", "mkdir", "chmod", "chown",
        "tar", "systemctl", "journalctl",
    ]
    private static let goSubcommands: Set<String> = ["run", "build", "test", "mod", "get", "install"]

    static func isShellCommand(_ s: String) -> Bool {
        if s.hasPrefix("$ ") { return true }
        let words = s.split(separator: " ")
        guard words.count >= 2 else { return false }
        let first = String(words[0])
        if first == "go" { return goSubcommands.contains(String(words[1])) }
        return shellCommands.contains(first)
    }

    static func looksLikeCode(_ text: String) -> Bool {
        let signals = [
            "{", "}", ";", "=>", "->", "()", "func ", "def ", "class ", "import ",
            "return ", "const ", "let ", "var ", "if (", "</", "/>", "#include", "package ",
        ]
        let hits = signals.filter { text.contains($0) }.count
        let indented = text
            .split(whereSeparator: \.isNewline)
            .filter { $0.hasPrefix("  ") || $0.hasPrefix("\t") }
            .count
        return hits >= 3 || (hits >= 2 && indented >= 1)
    }
}
