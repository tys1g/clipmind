import SwiftUI

struct ClipListView: View {
    @Bindable var model: PanelModel
    let onPick: (ClipItem) -> Void
    @FocusState private var searchFocused: Bool

    var body: some View {
        let results = model.results

        VStack(spacing: 0) {
            searchField
            Divider()
            if results.isEmpty {
                emptyState
            } else {
                list(results)
            }
            Divider()
            footer
        }
        .frame(minWidth: 480, minHeight: 320)
        .background(.regularMaterial)
        .onChange(of: model.focusRequest) { _, _ in searchFocused = true }
        .onAppear { searchFocused = true }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Поиск по истории…", text: $model.query)
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .focused($searchFocused)
        }
        .padding(.horizontal, 14)
        .padding(.top, 30) 
        .padding(.bottom, 12)
    }

    private func list(_ results: [ClipItem]) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, item in
                        ClipRow(item: item, index: index, isSelected: index == model.selected)
                            .id(item.id)
                            .contentShape(Rectangle())
                            .onTapGesture { onPick(item) }
                    }
                }
                .padding(6)
            }
            .onChange(of: model.selected) { _, newValue in
                guard results.indices.contains(newValue) else { return }
                proxy.scrollTo(results[newValue].id)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text(model.query.isEmpty ? "История пуста — скопируй что-нибудь" : "Ничего не найдено")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack(spacing: 14) {
            hint("↵", "вставить")
            hint("⌘1–9", "быстро")
            hint("⌘P", "закрепить")
            hint("⌘⌫", "удалить")
            hint("esc", "закрыть")
            Spacer()
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Text(key).fontWeight(.semibold)
            Text(label)
        }
    }
}

struct ClipRow: View {
    let item: ClipItem
    let index: Int
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TypeBadge(item: item, isSelected: isSelected)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .lineLimit(2)
                    .font(.system(size: 13))
                HStack(spacing: 6) {
                    if let app = item.sourceApp { Text(app) }
                    Text(item.lastUsedAt, style: .relative)
                    if item.lineCount > 1 { Text("· \(item.lineCount) стр.") }
                }
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
            }
            Spacer(minLength: 8)
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.orange)
            }
            if index < 9 {
                Text("⌘\(index + 1)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
            }
        }
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
    }
}

struct TypeBadge: View {
    let item: ClipItem
    let isSelected: Bool

    var body: some View {
        Group {
            if item.type == .color, let color = Color(hex: item.text) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(.white.opacity(0.4), lineWidth: 1))
                    .frame(width: 14, height: 14)
            } else {
                Image(systemName: item.type.symbol)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.9) : Color.secondary)
            }
        }
        .frame(width: 18, height: 18)
        .padding(.top, 1)
        .help(item.type.label)
    }
}

extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.hasPrefix("#") else { return nil }
        s.removeFirst()
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() } 
        guard s.count == 6 || s.count == 8, let value = UInt64(s, radix: 16) else { return nil }

        let hasAlpha = s.count == 8
        let r = Double((value >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let g = Double((value >> (hasAlpha ? 16 : 8)) & 0xFF) / 255
        let b = Double((value >> (hasAlpha ? 8 : 0)) & 0xFF) / 255
        let a = hasAlpha ? Double(value & 0xFF) / 255 : 1
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
