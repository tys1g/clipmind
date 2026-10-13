import Testing
@testable import clipmind

struct ContentDetectorTests {
    @Test(arguments: [
        "#fff",
        "#1e90ff",
        "#1E90FFCC",
        "rgb(30, 144, 255)",
        "rgba(0,0,0,0.5)",
        "HSLA(210, 100%, 56%, 0.5)",
    ])
    func color(_ input: String) {
        #expect(ContentDetector.detect(input) == .color)
    }

    @Test(arguments: [
        "https://github.com/waste3d/clipmind",
        "http://localhost:8080/api",
        "www.example.com",
        "ftp://files.example.com/a.zip",
        "  https://example.com  \n",
    ])
    func link(_ input: String) {
        #expect(ContentDetector.detect(input) == .link)
    }

    @Test(arguments: [
        "nikolay@example.com",
        "first.last+tag@mail.co.uk",
    ])
    func email(_ input: String) {
        #expect(ContentDetector.detect(input) == .email)
    }

    @Test(arguments: [
        "+7 999 123-45-67",
        "8 (999) 123-45-67",
        "89991234567",
        "+1 555 0100",
    ])
    func phone(_ input: String) {
        #expect(ContentDetector.detect(input) == .phone)
    }

    @Test(arguments: [
        "/usr/local/bin",
        "~/Documents/notes.txt",
        "./src/main.go",
        "../config.yaml",
    ])
    func path(_ input: String) {
        #expect(ContentDetector.detect(input) == .path)
    }

    @Test(arguments: [
        "git checkout main",
        "$ npm install",
        "go run ./cmd/server",
        "docker compose up -d",
        "sudo systemctl restart nginx",
    ])
    func shellCommand(_ input: String) {
        #expect(ContentDetector.detect(input) == .code)
    }

    @Test(arguments: [
        "func hello() {\n    print(\"hi\")\n}",
        "package main\n\nimport \"fmt\"\n\nfunc main() {\n\tfmt.Println(1)\n}",
        "const x = () => {\n  return 1;\n}",
    ])
    func multilineCode(_ input: String) {
        #expect(ContentDetector.detect(input) == .code)
    }

    @Test(arguments: [
        "",
        "привет",
        "git",
        "go to the store",
        "2026-10-13",
        "192.168.1.1",
        "#hashtag",
        "user@localhost",
        "Встреча в 15:00",
        "Купить молоко\nПозвонить маме",
        "Привет, {name}!\nДо встречи",
    ])
    func plainText(_ input: String) {
        #expect(ContentDetector.detect(input) == .text)
    }

    @Test func everyTypeHasIconAndLabel() {
        for type in ContentType.allCases {
            #expect(!type.symbol.isEmpty)
            #expect(!type.label.isEmpty)
        }
    }
}
