import Foundation
import SwiftData

@Model final class Track {
    @Attribute(.unique) var id: UUID
    var title: String
    var artistName: String
    var albumTitle: String
    var filePath: String
    var duration: Double
    var fileSizeBytes: Int64
    var dateAdded: Date
    var artworkPath: String?
    var isAvailable: Bool
    var playCount: Int
    var lastPlayedAt: Date?

    init(id: UUID = UUID(), title: String, artistName: String, albumTitle: String, filePath: String, duration: Double, fileSizeBytes: Int64, artworkPath: String? = nil) {
        self.id = id; self.title = title; self.artistName = artistName; self.albumTitle = albumTitle
        self.filePath = filePath; self.duration = duration; self.fileSizeBytes = fileSizeBytes
        self.dateAdded = .now; self.artworkPath = artworkPath; self.isAvailable = true; self.playCount = 0
    }
}

@Model final class Artist {
    @Attribute(.unique) var id: UUID
    var name: String
    var coverImagePath: String?
    init(id: UUID = UUID(), name: String, coverImagePath: String? = nil) { self.id = id; self.name = name; self.coverImagePath = coverImagePath }
}

@Model final class Album {
    @Attribute(.unique) var id: UUID
    var title: String
    var artistName: String
    var releaseYear: Int?
    var coverImagePath: String?
    init(id: UUID = UUID(), title: String, artistName: String, releaseYear: Int? = nil, coverImagePath: String? = nil) { self.id = id; self.title = title; self.artistName = artistName; self.releaseYear = releaseYear; self.coverImagePath = coverImagePath }
}

@Model final class Playlist {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \PlaylistTrack.playlist) var entries: [PlaylistTrack]
    init(id: UUID = UUID(), name: String) { self.id = id; self.name = name; self.createdAt = .now; self.entries = [] }
}

@Model final class PlaylistTrack {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int
    var track: Track?
    var playlist: Playlist?
    init(id: UUID = UUID(), track: Track, sortOrder: Int) { self.id = id; self.track = track; self.sortOrder = sortOrder }
}

enum SupportedAudioFormat: String, CaseIterable {
    case mp3, m4a, aac, wav, aiff, flac
    static func accepts(_ url: URL) -> Bool { Self(rawValue: url.pathExtension.lowercased()) != nil }
}

struct TrackMetadata: Sendable {
    var title: String
    var artist: String
    var album: String
    var artworkData: Data?
}
