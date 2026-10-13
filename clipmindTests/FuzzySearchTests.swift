import Testing
@testable import clipmind

struct FuzzySearchTests {
    private func texts(_ items: [ClipItem]) -> [String] {
        items.map(\.text)
    }

    @Test func emptyQueryReturnsAllInOrder() {
        let items = ["a", "b"].map { ClipItem(text: $0) }
        #expect(texts(FuzzySearch.filter(items, query: "  ")) == ["a", "b"])
    }

    @Test(arguments: [
        ("ПРИВЕТ", "ну привет"),
        ("елка", "Ёлка новогодняя"),
        ("cafe", "Café de Paris"),
        ("nginx конфиг", "конфиг для nginx"),
        ("gtco", "git checkout main"),
    ])
    func matches(query: String, text: String) {
        #expect(FuzzySearch.score(query: query, in: text) != nil)
    }

    @Test(arguments: [
        ("xyz", "git checkout main"),
        ("docker", "kubectl get pods"),
        ("abc", "ab"),
    ])
    func doesNotMatch(query: String, text: String) {
        #expect(FuzzySearch.score(query: query, in: text) == nil)
    }

    @Test func exactBeatsFuzzy() throws {
        let exact = try #require(FuzzySearch.score(query: "git", in: "git status"))
        let fuzzy = try #require(FuzzySearch.score(query: "git", in: "go install tool"))
        #expect(exact > fuzzy)
    }

    @Test func earlierMatchRanksHigher() {
        let items = ["some text with token", "token at start"].map { ClipItem(text: $0) }
        #expect(texts(FuzzySearch.filter(items, query: "token")) == ["token at start", "some text with token"])
    }

    @Test func tiesKeepRecencyOrder() {
        let items = ["abc 1", "abc 2", "abc 3"].map { ClipItem(text: $0) }
        #expect(texts(FuzzySearch.filter(items, query: "abc")) == ["abc 1", "abc 2", "abc 3"])
    }

    @Test func nonMatchesFiltered() {
        let items = ["docker ps", "kubectl get pods"].map { ClipItem(text: $0) }
        #expect(texts(FuzzySearch.filter(items, query: "dock")) == ["docker ps"])
    }
}
