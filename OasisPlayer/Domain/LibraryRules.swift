import Foundation

enum LibraryRules {
    static func validateDirectAudioURL(_ value: String) -> URL? {
        guard let url = URL(string: value), let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme), !url.pathExtension.isEmpty else { return nil }
        return url
    }

    static func fallbackMetadata(for url: URL) -> TrackMetadata {
        TrackMetadata(title: url.deletingPathExtension().lastPathComponent, artist: "Artista Desconhecido", album: "Álbum Desconhecido", artworkData: nil)
    }
}
