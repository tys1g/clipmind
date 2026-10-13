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
    var type: ContentType
    var isPinned: Bool
    
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
        self.type = ContentDetector.detect(text)
        self.isPinned = false
    }
    
    init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decode(UUID.self, forKey: .id)
            text = try c.decode(String.self, forKey: .text)
            createdAt = try c.decode(Date.self, forKey: .createdAt)
            lastUsedAt = try c.decode(Date.self, forKey: .lastUsedAt)
            sourceApp = try c.decodeIfPresent(String.self, forKey: .sourceApp)
            useCount = try c.decode(Int.self, forKey: .useCount)
            type = try c.decodeIfPresent(ContentType.self, forKey: .type) ?? ContentDetector.detect(text)
            isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        }
    
    var title: String {
        let firstLine = text.split(whereSeparator: \.isNewline).first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return firstLine.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
    }
    var lineCount: Int {
        text.split(whereSeparator: \.isNewline).count
    }
}
