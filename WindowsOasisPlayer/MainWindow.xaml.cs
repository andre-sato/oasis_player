using Microsoft.Win32;
using System.IO;
using System.Net.Http;
using System.Collections.ObjectModel;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace OasisPlayer.Windows;

public partial class MainWindow : Window
{
    private static readonly string[] Extensions = [".mp3", ".m4a", ".aac", ".wav", ".aiff", ".flac"];
    private readonly MediaPlayer player = new();
    private readonly ObservableCollection<Track> tracks = [];
    private readonly string mediaDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyMusic), "Oasis Player", "Media");
    private readonly string databasePath;
    private int currentIndex = -1;
    private bool isPlaying;

    public MainWindow()
    {
        InitializeComponent();
        databasePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Oasis Player", "library.json");
        TracksList.ItemsSource = tracks;
        Directory.CreateDirectory(mediaDirectory);
        LoadLibrary();
        player.MediaEnded += (_, _) => Next();
    }

    private void ImportFiles_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Multiselect = true, Filter = "Áudio|*.mp3;*.m4a;*.aac;*.wav;*.aiff;*.flac" };
        if (dialog.ShowDialog() == true) foreach (var file in dialog.FileNames) AddToLibrary(file);
    }

    private async void Download_Click(object sender, RoutedEventArgs e)
    {
        if (!Uri.TryCreate(UrlBox.Text, UriKind.Absolute, out var uri) || (uri.Scheme != Uri.UriSchemeHttps && uri.Scheme != Uri.UriSchemeHttp) || !Extensions.Contains(Path.GetExtension(uri.AbsolutePath).ToLowerInvariant())) { StatusText.Text = "Informe uma URL direta de um arquivo de áudio suportado."; return; }
        try { StatusText.Text = "Baixando…"; using var http = new HttpClient(); var bytes = await http.GetByteArrayAsync(uri); var target = Path.Combine(mediaDirectory, $"{Guid.NewGuid()}{Path.GetExtension(uri.AbsolutePath)}"); await File.WriteAllBytesAsync(target, bytes); AddToLibrary(target, false); UrlBox.Clear(); StatusText.Text = "Download concluído."; }
        catch (Exception error) { StatusText.Text = $"Falha no download: {error.Message}"; }
    }

    private void AddToLibrary(string source, bool copy = true)
    {
        if (!Extensions.Contains(Path.GetExtension(source).ToLowerInvariant())) return;
        var path = source;
        if (copy) { path = Path.Combine(mediaDirectory, $"{Guid.NewGuid()}{Path.GetExtension(source)}"); File.Copy(source, path, true); }
        if (tracks.Any(track => string.Equals(track.FilePath, path, StringComparison.OrdinalIgnoreCase))) return;
        tracks.Add(new Track { FilePath = path, Title = Path.GetFileNameWithoutExtension(source), Artist = "Artista Desconhecido", Album = "Álbum Desconhecido" });
        SaveLibrary(); StatusText.Text = "Adicionado à biblioteca.";
    }

    private void TracksList_SelectionChanged(object sender, SelectionChangedEventArgs e) { if (TracksList.SelectedItem is Track track) Play(tracks.IndexOf(track)); }
    private void PlayPause_Click(object sender, RoutedEventArgs e) { if (currentIndex < 0 && tracks.Count > 0) Play(0); else if (isPlaying) { player.Pause(); isPlaying = false; RefreshPlayButton(); } else { player.Play(); isPlaying = true; RefreshPlayButton(); } }
    private void Previous_Click(object sender, RoutedEventArgs e) => Play(Math.Max(0, currentIndex - 1));
    private void Next_Click(object sender, RoutedEventArgs e) => Next();
    private void Next() => Play(currentIndex + 1 < tracks.Count ? currentIndex + 1 : 0);
    private void Play(int index) { if (!tracks.Any() || index < 0) return; currentIndex = index; var track = tracks[index]; player.Open(new Uri(track.FilePath)); player.Play(); isPlaying = true; NowPlayingTitle.Text = track.Title; NowPlayingArtist.Text = track.Artist; TracksList.SelectedIndex = index; RefreshPlayButton(); }
    private void RefreshPlayButton() => PlayButton.Content = isPlaying ? "❚❚ Pausar" : "▶ Reproduzir";
    private void LoadLibrary() { try { if (File.Exists(databasePath)) foreach (var item in JsonSerializer.Deserialize<List<Track>>(File.ReadAllText(databasePath)) ?? []) if (File.Exists(item.FilePath)) tracks.Add(item); } catch { StatusText.Text = "Não foi possível carregar a biblioteca anterior."; } }
    private void SaveLibrary() { Directory.CreateDirectory(Path.GetDirectoryName(databasePath)!); File.WriteAllText(databasePath, JsonSerializer.Serialize(tracks)); }
}

public sealed class Track { public string Title { get; set; } = ""; public string Artist { get; set; } = ""; public string Album { get; set; } = ""; public string FilePath { get; set; } = ""; }
