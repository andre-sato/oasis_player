import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var urlText = ""
    @State private var showingFilePicker = false
    @State private var downloader = URLAudioDownloader()
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("URL direta") {
                    TextField("URL do arquivo de áudio", text: $urlText).textInputAutocapitalization(.never).keyboardType(.URL).autocorrectionDisabled()
                    Button("Baixar", systemImage: "arrow.down.circle") { Task { await download() } }.disabled(urlText.isEmpty)
                    downloadStatus
                }
                Section("Arquivos") { Button("Importar do app Arquivos", systemImage: "folder") { showingFilePicker = true } }
                if let message { Section { Text(message).foregroundStyle(.secondary) } }
            }
            .navigationTitle("Importar")
            .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: supportedTypes, allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls): Task { for url in urls { await importFile(url) } }
                case .failure(let error): message = error.localizedDescription
                }
            }
        }
    }

    @ViewBuilder private var downloadStatus: some View {
        switch downloader.state {
        case .idle: EmptyView()
        case .downloading(let progress): ProgressView(value: progress) { Text("Baixando…") }
        case .finished: Label("Download concluído", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed(let text): Text(text).foregroundStyle(.red)
        }
    }
    private var supportedTypes: [UTType] { [.mp3, .mpeg4Audio, .wav, .aiff, UTType(filenameExtension: "flac")! ] }
    private func download() async {
        await downloader.download(urlText)
        if case let .finished(url) = downloader.state { await register(url); urlText = "" }
    }
    private func importFile(_ url: URL) async {
        let acquired = url.startAccessingSecurityScopedResource()
        defer { if acquired { url.stopAccessingSecurityScopedResource() } }
        do { let stored = try await MediaFileStore.shared.copyIntoLibrary(from: url); await register(stored) }
        catch { message = error.localizedDescription }
    }
    private func register(_ url: URL) async {
        let metadata = await MetadataService().read(from: url)
        let duration = await MetadataService().duration(of: url)
        let bytes = ((try? FileManager.default.attributesOfItem(atPath: url.path)[.size]) as? NSNumber)?.int64Value ?? 0
        modelContext.insert(Track(title: metadata.title, artistName: metadata.artist, albumTitle: metadata.album, filePath: url.path, duration: duration, fileSizeBytes: bytes))
        do { try modelContext.save(); message = "\(metadata.title) foi adicionado à biblioteca." } catch { message = error.localizedDescription }
    }
}
