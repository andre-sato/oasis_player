import SwiftUI
import SwiftData

struct RootView: View {
    @State private var player = AudioPlayerService()
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Início", systemImage: "house.fill") }
            LibraryView().tabItem { Label("Biblioteca", systemImage: "music.note.list") }
            ImportView().tabItem { Label("Importar", systemImage: "arrow.down.circle.fill") }
        }
        .environment(player)
        .safeAreaInset(edge: .bottom) { if player.currentTrack != nil { MiniPlayerView() } }
    }
}

struct HomeView: View {
    @Query(sort: \Track.dateAdded, order: .reverse) private var tracks: [Track]
    var body: some View { NavigationStack { List { Section("Adicionadas recentemente") { ForEach(tracks.prefix(8)) { TrackRow(track: $0) } } } .navigationTitle("Oasis") } }
}

struct LibraryView: View {
    @Query(sort: \Track.title) private var tracks: [Track]
    var body: some View { NavigationStack { List(tracks) { TrackRow(track: $0) } .overlay { if tracks.isEmpty { ContentUnavailableView("Sua biblioteca está vazia", systemImage: "music.note", description: Text("Importe um arquivo ou faça download por URL direta.")) } } .navigationTitle("Biblioteca") } }
}

struct TrackRow: View {
    let track: Track
    @Environment(AudioPlayerService.self) private var player
    var body: some View {
        Button { player.play(track) } label: { HStack { Image(systemName: "music.note").frame(width: 36, height: 36).background(.quaternary, in: RoundedRectangle(cornerRadius: 8)); VStack(alignment: .leading) { Text(track.title).foregroundStyle(.primary); Text(track.artistName).font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Text(format(track.duration)).font(.caption).foregroundStyle(.secondary) } }
        .contextMenu { Button("Adicionar à fila", systemImage: "text.line.first.and.arrowtriangle.forward") { player.queue.append(track) }; Button("Excluir", systemImage: "trash", role: .destructive) {} }
    }
    private func format(_ seconds: Double) -> String { String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60) }
}

struct MiniPlayerView: View {
    @Environment(AudioPlayerService.self) private var player
    @State private var showsNowPlaying = false
    var body: some View {
        Button { showsNowPlaying = true } label: { HStack { Image(systemName: "music.note").frame(width: 36, height: 36).background(.quaternary, in: RoundedRectangle(cornerRadius: 7)); VStack(alignment: .leading) { Text(player.currentTrack?.title ?? "").lineLimit(1); Text(player.currentTrack?.artistName ?? "").font(.caption).foregroundStyle(.secondary) }; Spacer(); Button { player.togglePlayback() } label: { Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.title3) }.buttonStyle(.borderless); Button { player.next() } label: { Image(systemName: "forward.fill") }.buttonStyle(.borderless) }.padding(.horizontal).padding(.vertical, 8) }
        .buttonStyle(.plain).background(.ultraThinMaterial).sheet(isPresented: $showsNowPlaying) { NowPlayingView() }
    }
}

struct NowPlayingView: View {
    @Environment(AudioPlayerService.self) private var player
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationStack { VStack(spacing: 28) { Spacer(); Image(systemName: "music.note").resizable().scaledToFit().frame(width: 220, height: 220).padding(44).background(.quaternary, in: RoundedRectangle(cornerRadius: 24)); VStack { Text(player.currentTrack?.title ?? "").font(.title2.bold()); Text(player.currentTrack?.artistName ?? "").foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading); Slider(value: Binding(get: { player.progress }, set: { player.seek(to: $0) }), in: 0...max(player.currentTrack?.duration ?? 0, 1)); HStack { Button { player.previous() } label: { Image(systemName: "backward.fill") }; Spacer(); Button { player.togglePlayback() } label: { Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill").font(.system(size: 64)) }; Spacer(); Button { player.next() } label: { Image(systemName: "forward.fill") } }.font(.title); Spacer() }.padding().toolbar { Button("Fechar") { dismiss() } } } }
}
