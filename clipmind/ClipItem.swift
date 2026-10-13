import Foundation


struct ClipItem: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    // first copy time
    var createdAt: Date
    // last pasting time
    var lastUsedAt: Date
    var sourceApp: String?
    var useCount: Int
    
    init(
        id: UUID = UUID(),
        text: String,
        createdAt: Date = Date(),
        sourceApp: String? = nil
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.sourceApp = sourceApp
        self.lastUsedAt = createdAt
        self.useCount = 1
    }
    
    var title: String {
        let firstLine = text.split(whereSeparator: \.isNewline).first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return firstLine.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
    }
    var lineCount: Int {
        text.split(whereSeparator: \.isNewline).count
    }
}
