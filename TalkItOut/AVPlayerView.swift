import SwiftUI
import AVKit

struct AVPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        player.play()
        return controller
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct JournalEntryPlaybackView: View {
    let entry: JournalEntry
    @State private var player: AVPlayer? = nil

    var body: some View {
        VStack(spacing: 24) {
            if let player = player {
                AVPlayerView(player: player)
                    .frame(height: 220)
                    .cornerRadius(16)
                    .padding(.top, 24)
            } else {
                Text("Loading player...")
            }
            Text("Transcript")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(splitTranscript(entry.transcript), id: \ .self) { line in
                        Text(line)
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            print("[DEBUG] JournalEntryPlaybackView appeared for entry: \(entry.id)")
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                print("[DEBUG] AVAudioSession set to playback mode and activated.")
            } catch {
                print("[ERROR] Failed to set AVAudioSession for playback: \(error)")
            }
            if player == nil {
                print("[DEBUG] Attempting to create AVPlayer with URL: \(entry.audioURL)")
                if let url = URL(string: entry.audioURL) {
                    let newPlayer = AVPlayer(url: url)
                    player = newPlayer
                    print("[DEBUG] AVPlayer created. Starting playback...")
                    newPlayer.play()
                    print("[DEBUG] AVPlayer play() called.")
                } else {
                    print("[ERROR] Invalid audio URL: \(entry.audioURL)")
                }
            }
        }
    }
    
    // Helper to split transcript into lines, similar to ContentView
    func splitTranscript(_ transcript: String) -> [String] {
        let words = transcript.split(separator: " ")
        var lines: [String] = []
        var currentLine: [Substring] = []
        for word in words {
            currentLine.append(word)
            if currentLine.count >= 8 || word.hasSuffix(".") || word.hasSuffix("!") || word.hasSuffix("?") {
                lines.append(currentLine.joined(separator: " "))
                currentLine = []
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine.joined(separator: " "))
        }
        return lines
    }
} 
