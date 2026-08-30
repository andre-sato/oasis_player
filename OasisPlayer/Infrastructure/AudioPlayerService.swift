import AVFoundation
import MediaPlayer
import Observation

@MainActor @Observable final class AudioPlayerService {
    var currentTrack: Track?
    var isPlaying = false
    var progress: Double = 0
    var queue: [Track] = []
    var repeatEnabled = false
    var shuffleEnabled = false
    var volume: Float = 1 { didSet { player.volume = volume } }
    private let player = AVQueuePlayer()
    private var timeObserver: Any?

    init() {
        configureAudioSession()
        configureRemoteCommands()
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in self?.progress = time.seconds }
    }
    deinit { if let timeObserver { player.removeTimeObserver(timeObserver) } }

    func play(_ track: Track, queue tracks: [Track] = []) {
        queue = tracks.isEmpty ? [track] : tracks
        currentTrack = track
        rebuildQueue(startingWith: track)
        player.play(); isPlaying = true; updateNowPlaying()
    }
    func togglePlayback() { isPlaying ? pause() : resume() }
    func pause() { player.pause(); isPlaying = false; updateNowPlaying() }
    func resume() { player.play(); isPlaying = true; updateNowPlaying() }
    func next() { player.advanceToNextItem(); moveCurrentIndex(by: 1) }
    func previous() { guard let currentTrack, let index = queue.firstIndex(where: { $0.id == currentTrack.id }) else { return }; play(queue[max(0, index - 1)], queue: queue) }
    func seek(to seconds: Double) { player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600)) }
    func removeFromQueue(at offsets: IndexSet) { queue.remove(atOffsets: offsets) }
    func moveQueue(from offsets: IndexSet, to destination: Int) { queue.move(fromOffsets: offsets, toOffset: destination) }

    private func rebuildQueue(startingWith track: Track) {
        player.removeAllItems()
        var items = queue
        if shuffleEnabled { items.shuffle() }
        guard let start = items.firstIndex(where: { $0.id == track.id }) else { return }
        for item in items[start...] { player.insert(AVPlayerItem(url: URL(fileURLWithPath: item.filePath)), after: nil) }
    }
    private func moveCurrentIndex(by step: Int) {
        guard let currentTrack, let index = queue.firstIndex(where: { $0.id == currentTrack.id }) else { return }
        let nextIndex = index + step
        guard queue.indices.contains(nextIndex) else { if repeatEnabled, let first = queue.first { play(first, queue: queue) }; return }
        currentTrack = queue[nextIndex]; progress = 0; updateNowPlaying()
    }
    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.resume(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.pause(); return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.next(); return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in self?.previous(); return .success }
    }
    private func updateNowPlaying() {
        guard let track = currentTrack else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: track.title, MPMediaItemPropertyArtist: track.artistName, MPMediaItemPropertyAlbumTitle: track.albumTitle, MPMediaItemPropertyPlaybackDuration: track.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: progress, MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1 : 0]
    }
}
