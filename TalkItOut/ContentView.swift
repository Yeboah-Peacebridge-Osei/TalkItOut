//
//  ContentView.swift
//  TalkItOut
//
//  Created by Yeboah Peacebridge Osei on 6/1/25.
//

import SwiftUI
import AVFoundation
import Combine
import AVKit
import Speech

class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var lastRecordingURL: URL? = nil
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        #endif
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        lastRecordingURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var sentimentAnalyzer = SentimentAnalyzer()
    @State private var showingPermissionAlert = false
    @State private var detectedTopic: String = ""
    @State private var journalingPrompt: String = ""
    @State private var isLoadingPrompt: Bool = false
    @State private var showAIResult: Bool = false
    @State private var scrollToBottom: Bool = true
    @Namespace private var lyricsBottom
    @EnvironmentObject var journalEntriesModel: JournalEntriesModel
    @State private var streakCount: Int = 0
    @State private var lastEntryDate: Date? = nil
    @State private var showPlayer: Bool = false
    @State private var playerURL: URL? = nil
    
    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 24) {
                // Show motivational message if not recording and transcript is empty
                if !audioRecorder.isRecording && speechRecognizer.transcript.isEmpty {
                    Text("Talk it and let it all out")
                        .font(.title2)
                        .italic()
                        .foregroundColor(.white)
                        .padding(.top, 40)
                }
                // Streak indicator
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .scaleEffect(streakCount > 0 ? 1.2 : 1.0)
                        .animation(.easeInOut, value: streakCount)
                    Text("Streak: \(streakCount) day\(streakCount == 1 ? "" : "s")")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
                .opacity(streakCount > 0 ? 1 : 0.5)

                // Camera preview
                CameraView()
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.top, 24)
                    .padding(.horizontal)

                Spacer().frame(height: 48) // Add more space below camera

                // Journal entry info
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTime)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("New Entry")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Live transcript display as lyrics
                if !speechRecognizer.transcript.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(splitTranscript(speechRecognizer.transcript), id: \ .self) { line in
                                    Text(line)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                // Invisible anchor for auto-scroll
                                Color.clear.frame(height: 1).id(lyricsBottom)
                            }
                            .padding()
                        }
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onChange(of: speechRecognizer.transcript) { _ in
                            if scrollToBottom {
                                withAnimation {
                                    proxy.scrollTo(lyricsBottom, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Show AI topic and prompt only after recording is finished
                if showAIResult {
                    if !detectedTopic.isEmpty {
                        Text("Topic: \(detectedTopic)")
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                            .padding(.horizontal)
                        Text(journalingPrompt)
                            .font(.body)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .padding(.top, 2)
                    }
                }

                Spacer()
            }
            // Circular record button at bottom right
            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 72, height: 72)
                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
            .padding([.bottom, .trailing], 32)
            .shadow(radius: 8)
        }
        .background(Color(.black).ignoresSafeArea())
        .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please allow microphone access in Settings to use the recording feature.")
        }
        .onChange(of: speechRecognizer.transcript) { newTranscript in
            guard !newTranscript.isEmpty else {
                detectedTopic = ""
                journalingPrompt = ""
                isLoadingPrompt = false
                showAIResult = false
                return
            }
            isLoadingPrompt = true
            showAIResult = true
            OpenAIService.shared.classifyTopicsAndPrompt(transcript: newTranscript) { topic, prompt in
                DispatchQueue.main.async {
                    detectedTopic = topic == "Unknown" ? "" : topic
                    journalingPrompt = prompt
                    isLoadingPrompt = false
                }
            }
        }
    }

    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
            #if os(iOS)
            speechRecognizer.stopTranscribing()
            let transcript = speechRecognizer.transcript
            
            // Reset UI state immediately
            detectedTopic = ""
            journalingPrompt = ""
            isLoadingPrompt = false
            showAIResult = false
            
            // Check if transcript is empty before processing
            guard !transcript.isEmpty else {
                // Clear transcript immediately if empty
                speechRecognizer.transcript = ""
                return
            }
            
            // Process the transcript for AI and journal entry
            isLoadingPrompt = true
            showAIResult = true
            
            OpenAIService.shared.classifyTopicsAndPrompt(transcript: transcript) { topic, prompt in
                DispatchQueue.main.async {
                    self.detectedTopic = topic == "Unknown" ? "" : topic
                    self.journalingPrompt = prompt
                    self.isLoadingPrompt = false
                }
            }
            
            // Save journal entry
            if let audioURL = audioRecorder.lastRecordingURL {
                let fileName = UUID().uuidString + ".m4a"
                let storagePath = "user_audios/\(fileName)"
                StorageManager.shared.uploadFile(localFile: audioURL, path: storagePath) { result in
                    switch result {
                    case .success(let downloadURL):

                        let entry = JournalEntry(date: Date(), transcript: transcript, audioURL: downloadURL.absoluteString)
                        DispatchQueue.main.async {
                            journalEntriesModel.entries.append(entry)
                            updateStreak(for: entry.date)
                            lastEntryDate = entry.date
                        }
                    case .failure(let error):
                        print("Upload failed: \(error)")
                        // Optionally show an error to the user
                    }
                }
            }
            
            // Clear transcript AFTER using it for all necessary operations
            DispatchQueue.main.async {
                self.speechRecognizer.transcript = ""
            }
            #endif
        } else {
            #if os(iOS)
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        audioRecorder.startRecording()
                        do {
                            try speechRecognizer.startTranscribing()
                        } catch {
                            print("Speech recognition error: \(error)")
                        }
                        // Reset AI result state
                        detectedTopic = ""
                        journalingPrompt = ""
                        isLoadingPrompt = false
                        showAIResult = false
                    } else {
                        showingPermissionAlert = true
                    }
                }
            }
            #else
            audioRecorder.startRecording()
            #endif
        }
    }

    private func updateStreak(for newDate: Date) {
        guard let last = lastEntryDate else {
            streakCount = 1
            return
        }
        let calendar = Calendar.current
        if calendar.isDate(newDate, inSameDayAs: last) {
            // Same day, streak unchanged
        } else if let days = calendar.dateComponents([.day], from: last, to: newDate).day, days == 1 {
            streakCount += 1
        } else {
            streakCount = 1
        }
    }

    func splitTranscript(_ transcript: String) -> [String] {
        // Split by sentence or every ~8 words for lyric effect
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
