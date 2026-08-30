import XCTest
@testable import OasisPlayer

final class LibraryRulesTests: XCTestCase {
    func testAcceptsDirectHTTPAudioURL() {
        XCTAssertEqual(LibraryRules.validateDirectAudioURL("https://example.com/music/track.mp3")?.absoluteString, "https://example.com/music/track.mp3")
    }

    func testRejectsPageAndInvalidURLs() {
        XCTAssertNil(LibraryRules.validateDirectAudioURL("https://example.com/album"))
        XCTAssertNil(LibraryRules.validateDirectAudioURL("file:///private/song.mp3"))
    }

    func testUsesFilenameAndLocalizedFallbacks() {
        let metadata = LibraryRules.fallbackMetadata(for: URL(fileURLWithPath: "/tmp/faixa_01.mp3"))
        XCTAssertEqual(metadata.title, "faixa_01")
        XCTAssertEqual(metadata.artist, "Artista Desconhecido")
        XCTAssertEqual(metadata.album, "Álbum Desconhecido")
    }
}
