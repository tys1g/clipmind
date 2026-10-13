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
