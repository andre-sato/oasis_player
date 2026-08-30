import SwiftUI
import SwiftData

@main
struct OasisPlayerApp: App {
    private let container: ModelContainer = {
        let schema = Schema([Track.self, Artist.self, Album.self, Playlist.self, PlaylistTrack.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(container)
    }
}
