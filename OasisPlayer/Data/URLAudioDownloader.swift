import Foundation
import Observation

@Observable final class URLAudioDownloader {
    enum State: Equatable { case idle, downloading(Double), finished(URL), failed(String) }
    var state: State = .idle
    func download(_ text: String) async {
        guard let url = LibraryRules.validateDirectAudioURL(text) else { state = .failed("Informe uma URL direta de áudio válida."); return }
        state = .downloading(0)
        do {
            let (temporaryURL, response) = try await URLSession.shared.download(from: url)
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else { throw URLError(.badServerResponse) }
            let stored = try await MediaFileStore.shared.copyIntoLibrary(from: temporaryURL, fileExtension: url.pathExtension)
            state = .finished(stored)
        } catch { state = .failed(error.localizedDescription) }
    }
}
