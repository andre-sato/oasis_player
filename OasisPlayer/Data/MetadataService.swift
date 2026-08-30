import AVFoundation
import Foundation

struct MetadataService {
    func read(from url: URL) async -> TrackMetadata {
        let asset = AVURLAsset(url: url)
        let common = (try? await asset.load(.commonMetadata)) ?? []
        func value(_ key: AVMetadataKey) -> String? { common.first(where: { $0.commonKey == key })?.stringValue }
        let fallback = LibraryRules.fallbackMetadata(for: url)
        let artwork = common.first(where: { $0.commonKey == .commonKeyArtwork })?.dataValue
        return TrackMetadata(title: value(.commonKeyTitle) ?? fallback.title, artist: value(.commonKeyArtist) ?? fallback.artist, album: value(.commonKeyAlbumName) ?? fallback.album, artworkData: artwork)
    }
    func duration(of url: URL) async -> Double { (try? await AVURLAsset(url: url).load(.duration).seconds) ?? 0 }
}
