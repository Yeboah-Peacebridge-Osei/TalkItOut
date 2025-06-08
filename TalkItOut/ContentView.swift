//
//  ContentView.swift
//  TalkItOut
//
//  Created by Yeboah Peacebridge Osei on 6/1/25.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    
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
    @State private var showingPermissionAlert = false
    
    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 24) {
                // Camera preview
                CameraView()
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.top, 24)
                    .padding(.horizontal)

                Spacer().frame(height: 48) // Add more space below camera

                // Motivational prompt
                Text("What's on your mind right now?")
                    .font(.title2)
                    .italic()
                    .foregroundColor(.white)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

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

                // Live transcript display
                if !speechRecognizer.transcript.isEmpty {
                    Text(speechRecognizer.transcript)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal)
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
    }

    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
            #if os(iOS)
            speechRecognizer.stopTranscribing()
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
