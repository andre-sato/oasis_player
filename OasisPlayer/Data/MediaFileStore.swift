import Foundation

actor MediaFileStore {
    static let shared = MediaFileStore()
    private let fileManager = FileManager.default
    private var audioDirectory: URL { fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "Media/Audio", directoryHint: .isDirectory) }

    func prepareDirectories() throws { try fileManager.createDirectory(at: audioDirectory, withIntermediateDirectories: true) }
    func copyIntoLibrary(from source: URL, fileExtension: String? = nil) throws -> URL {
        let resolvedExtension = (fileExtension ?? source.pathExtension).lowercased()
        guard SupportedAudioFormat(rawValue: resolvedExtension) != nil else { throw CocoaError(.fileReadUnsupportedScheme) }
        try prepareDirectories()
        let destination = audioDirectory.appending(path: "\(UUID().uuidString).\(resolvedExtension)")
        try fileManager.copyItem(at: source, to: destination)
        return destination
    }
    func audioFiles() throws -> [URL] {
        try prepareDirectories()
        return try fileManager.contentsOfDirectory(at: audioDirectory, includingPropertiesForKeys: nil).filter(SupportedAudioFormat.accepts)
    }
    func delete(_ track: Track) throws { try fileManager.removeItem(atPath: track.filePath) }
}
