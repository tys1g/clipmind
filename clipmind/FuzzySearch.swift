import Foundation

enum FuzzySearch {
    static let maxScanLength = 4000

    static func normalize(_ s: String) -> String {
        s.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    }

    static func score(query: String, in text: String) -> Int? {
        let q = normalize(query.trimmingCharacters(in: .whitespaces))
        if q.isEmpty { return 0 }
        let t = normalize(String(text.prefix(maxScanLength)))

        if let range = t.range(of: q) {
            let position = t.distance(from: t.startIndex, to: range.lowerBound)
            var score = 1000 - min(position, 500)
            if isWordStart(t, at: range.lowerBound) { score += 100 }
            return score
        }

        let words = q.split(separator: " ").map(String.init)
        if words.count > 1, words.allSatisfy({ t.contains($0) }) {
            return 500
        }

        return subsequenceScore(query: q.replacingOccurrences(of: " ", with: ""), text: t)
    }

    static func filter(_ items: [ClipItem], query: String) -> [ClipItem] {
        if query.trimmingCharacters(in: .whitespaces).isEmpty { return items }
        return items.enumerated()
            .compactMap { index, item in
                score(query: query, in: item.text).map { (index, item, $0) }
            }
            .sorted { $0.2 != $1.2 ? $0.2 > $1.2 : $0.0 < $1.0 }
            .map { $0.1 }
    }

    static func subsequenceScore(query: String, text: String) -> Int? {
        let q = Array(query)
        let t = Array(text)
        guard !q.isEmpty, q.count <= t.count else { return nil }

        var qi = 0
        var score = 0
        var lastMatch = -2
        for (ti, ch) in t.enumerated() where qi < q.count {
            guard ch == q[qi] else { continue }
            score += 10
            if ti == lastMatch + 1 { score += 15 }
            if ti == 0 || (!t[ti - 1].isLetter && !t[ti - 1].isNumber) {
                score += 20
            }
            lastMatch = ti
            qi += 1
        }
        guard qi == q.count else { return nil }
        return min(score, 400) 
    }

    private static func isWordStart(_ s: String, at index: String.Index) -> Bool {
        guard index > s.startIndex else { return true }
        let prev = s[s.index(before: index)]
        return !prev.isLetter && !prev.isNumber
    }
}
