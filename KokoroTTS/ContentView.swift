import SwiftUI
import AVFoundation

struct Voice: Identifiable, Hashable {
    let id: String
    let name: String
    let language: String
    let code: String
}

struct ContentView: View {
    @State private var selectedVoice: Voice = Voice(
        id: "af_heart",
        name: "af_heart",
        language: "American English",
        code: "a"
    )
    @State private var text: String = ""
    @State private var isGenerating = false
    @State private var generatedAudioURL: URL?
    @State private var showingSavePanel = false
    @State private var statusMessage: String = "Ready"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var currentChunkIndex = 0
    @State private var totalChunks = 0
    @State private var playbackProgress: Double = 0
    @State private var progressTimer: Timer?
    @State private var generatedChunkURLs: [URL] = []
    @State private var isPlaying = false
    @State private var isPaused = false
    @State private var currentQueueIndex = 0
    @State private var playTask: Task<Void, Error>?
    @State private var playbackSpeed: Double = 1.0
    
    let chunkSize = 400
    
    let voices: [Voice] = [
        Voice(id: "af_heart", name: "af_heart (Default)", language: "American English", code: "a"),
        Voice(id: "af_alloy", name: "af_alloy", language: "American English", code: "a"),
        Voice(id: "af_aoede", name: "af_aoede", language: "American English", code: "a"),
        Voice(id: "af_bella", name: "af_bella", language: "American English", code: "a"),
        Voice(id: "af_jessica", name: "af_jessica", language: "American English", code: "a"),
        Voice(id: "af_kore", name: "af_kore", language: "American English", code: "a"),
        Voice(id: "af_nicole", name: "af_nicole", language: "American English", code: "a"),
        Voice(id: "af_nova", name: "af_nova", language: "American English", code: "a"),
        Voice(id: "af_river", name: "af_river", language: "American English", code: "a"),
        Voice(id: "af_sarah", name: "af_sarah", language: "American English", code: "a"),
        Voice(id: "af_sky", name: "af_sky", language: "American English", code: "a"),
        Voice(id: "am_adam", name: "am_adam", language: "American English", code: "a"),
        Voice(id: "am_echo", name: "am_echo", language: "American English", code: "a"),
        Voice(id: "am_eric", name: "am_eric", language: "American English", code: "a"),
        Voice(id: "am_fenrir", name: "am_fenrir", language: "American English", code: "a"),
        Voice(id: "am_liam", name: "am_liam", language: "American English", code: "a"),
        Voice(id: "am_michael", name: "am_michael", language: "American English", code: "a"),
        Voice(id: "am_onyx", name: "am_onyx", language: "American English", code: "a"),
        Voice(id: "am_puck", name: "am_puck", language: "American English", code: "a"),
        Voice(id: "am_santa", name: "am_santa", language: "American English", code: "a"),
        Voice(id: "bf_alice", name: "bf_alice", language: "British English", code: "b"),
        Voice(id: "bf_emma", name: "bf_emma", language: "British English", code: "b"),
        Voice(id: "bf_isabella", name: "bf_isabella", language: "British English", code: "b"),
        Voice(id: "bf_lily", name: "bf_lily", language: "British English", code: "b"),
        Voice(id: "bm_daniel", name: "bm_daniel", language: "British English", code: "b"),
        Voice(id: "bm_fable", name: "bm_fable", language: "British English", code: "b"),
        Voice(id: "bm_george", name: "bm_george", language: "British English", code: "b"),
        Voice(id: "bm_lewis", name: "bm_lewis", language: "British English", code: "b"),
        Voice(id: "ef_dora", name: "ef_dora", language: "Spanish", code: "e"),
        Voice(id: "em_alex", name: "em_alex", language: "Spanish", code: "e"),
        Voice(id: "em_santa", name: "em_santa", language: "Spanish", code: "e"),
        Voice(id: "ff_siwis", name: "ff_siwis", language: "French", code: "f"),
        Voice(id: "hf_alpha", name: "hf_alpha", language: "Hindi", code: "h"),
        Voice(id: "hf_beta", name: "hf_beta", language: "Hindi", code: "h"),
        Voice(id: "hm_omega", name: "hm_omega", language: "Hindi", code: "h"),
        Voice(id: "hm_psi", name: "hm_psi", language: "Hindi", code: "h"),
        Voice(id: "if_sara", name: "if_sara", language: "Italian", code: "i"),
        Voice(id: "im_nicola", name: "im_nicola", language: "Italian", code: "i"),
        Voice(id: "jf_alpha", name: "jf_alpha", language: "Japanese", code: "j"),
        Voice(id: "jf_gongitsune", name: "jf_gongitsune", language: "Japanese", code: "j"),
        Voice(id: "jf_nezumi", name: "jf_nezumi", language: "Japanese", code: "j"),
        Voice(id: "jf_tebukuro", name: "jf_tebukuro", language: "Japanese", code: "j"),
        Voice(id: "jm_kumo", name: "jm_kumo", language: "Japanese", code: "j"),
        Voice(id: "pf_dora", name: "pf_dora", language: "Portuguese (BR)", code: "p"),
        Voice(id: "pm_alex", name: "pm_alex", language: "Portuguese (BR)", code: "p"),
        Voice(id: "pm_santa", name: "pm_santa", language: "Portuguese (BR)", code: "p"),
        Voice(id: "zf_xiaobei", name: "zf_xiaobei", language: "Mandarin", code: "z"),
        Voice(id: "zf_xiaoni", name: "zf_xiaoni", language: "Mandarin", code: "z"),
        Voice(id: "zf_xiaoxiao", name: "zf_xiaoxiao", language: "Mandarin", code: "z"),
        Voice(id: "zf_xiaoyi", name: "zf_xiaoyi", language: "Mandarin", code: "z"),
        Voice(id: "zm_yunjian", name: "zm_yunjian", language: "Mandarin", code: "z"),
        Voice(id: "zm_yunxi", name: "zm_yunxi", language: "Mandarin", code: "z"),
        Voice(id: "zm_yunxia", name: "zm_yunxia", language: "Mandarin", code: "z"),
        Voice(id: "zm_yunyang", name: "zm_yunyang", language: "Mandarin", code: "z"),
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Kokoro TTS")
                .font(.title)
                .padding(.top, 8)
            
            HStack {
                Text("Voice:")
                Picker("Voice", selection: $selectedVoice) {
                    ForEach(voices) { voice in
                        Text("\(voice.name) (\(voice.language))").tag(voice)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 280)
            }
            
            HStack {
                Text("Speed:")
                Slider(value: $playbackSpeed, in: 0.5...2.0, step: 0.1)
                Text("\(String(format: "%.1fx", playbackSpeed))")
                    .frame(width: 40)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            HStack(alignment: .top) {
                Text("Text:")
                TextEditor(text: $text)
                    .frame(height: 120)
                    .border(Color.gray.opacity(0.3))
            }
            
            HStack {
                Button(action: generateChunkedAudio) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Audio")
                    }
                }
                .disabled(isGenerating || text.isEmpty)
                
                if isPlaying || isPaused {
                    Button(action: togglePause) {
                        Text(isPaused ? "Resume" : "Pause")
                    }
                }
                
                Button(action: stopPlayback) {
                    Text("Stop")
                }
                .disabled(!isPlaying && !isPaused)
                
                Button(action: saveAudio) {
                    Text("Save...")
                }
                .disabled(generatedChunkURLs.isEmpty)
            }
            
            if totalChunks > 0 {
                VStack(spacing: 6) {
                    ProgressView(value: playbackProgress)
                        .progressViewStyle(.linear)
                        .frame(height: 8)
                    
                    HStack {
                        Text("Chunk \(currentChunkIndex + 1) of \(totalChunks)")
                        Spacer()
                        Text("\(Int(playbackProgress * 100))%")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text(statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(20)
        .frame(width: 520, height: 400)
        .onDisappear {
            progressTimer?.invalidate()
            playTask?.cancel()
            audioPlayer?.stop()
        }
    }
    
    private func chunkText(_ text: String, size: Int) -> [String] {
        var chunks: [String] = []
        var current = ""
        for word in text.split(separator: " ") {
            if current.count + word.count + 1 > size && !current.isEmpty {
                chunks.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            }
            current += (current.isEmpty ? "" : " ") + word
        }
        if !current.isEmpty {
            chunks.append(current.trimmingCharacters(in: .whitespaces))
        }
        return chunks.isEmpty ? [text] : chunks
    }
    
    private func generateChunkedAudio() {
        guard !text.isEmpty else { return }
        
        isGenerating = true
        statusMessage = "Preparing chunks..."
        generatedChunkURLs = []
        currentChunkIndex = 0
        totalChunks = 0
        playbackProgress = 0
        currentQueueIndex = 0
        audioPlayer?.stop()
        progressTimer?.invalidate()
        
        let chunks = chunkText(text, size: chunkSize)
        totalChunks = chunks.count
        let tempDir = FileManager.default.temporaryDirectory
        
        playTask = Task {
            for (index, chunk) in chunks.enumerated() {
                if Task.isCancelled { break }
                
                await MainActor.run {
                    statusMessage = "Generating chunk \(index + 1)/\(chunks.count)..."
                    currentChunkIndex = index
                }
                
                let chunkURL = tempDir.appendingPathComponent("kokoro_chunk_\(index).wav")
                
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/kokoro")
                task.arguments = [
                    "-m", selectedVoice.id,
                    "-l", selectedVoice.code,
                    "-o", chunkURL.path,
                    "-t", chunk,
                    "-s", String(playbackSpeed)
                ]
                
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    
                    if task.terminationStatus == 0 && FileManager.default.fileExists(atPath: chunkURL.path) {
                        await MainActor.run {
                            generatedChunkURLs.append(chunkURL)
                            if index == 0 {
                                generatedAudioURL = chunkURL
                                statusMessage = "Starting playback..."
                                playCurrentChunk()
                            }
                        }
                    } else {
                        let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                        let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        await MainActor.run {
                            statusMessage = "Chunk \(index + 1) error: \(errorString.prefix(50))"
                        }
                        break
                    }
                } catch {
                    await MainActor.run {
                        statusMessage = "Chunk \(index + 1) error: \(error.localizedDescription)"
                    }
                    break
                }
            }
            
            await MainActor.run {
                isGenerating = false
                if !generatedChunkURLs.isEmpty {
                    statusMessage = "Ready - \(generatedChunkURLs.count) chunks generated"
                }
            }
        }
    }
    
    private func playCurrentChunk(completion: @escaping () -> Void = {}) {
        guard currentQueueIndex < generatedChunkURLs.count else {
            isPlaying = false
            isPaused = false
            statusMessage = "Playback complete"
            playbackProgress = 1.0
            progressTimer?.invalidate()
            completion()
            return
        }
        
        let url = generatedChunkURLs[currentQueueIndex]
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = AudioPlayerDelegate(onFinish: {
                Task { @MainActor in
                    self.currentQueueIndex += 1
                    self.updateProgress()
                    if self.currentQueueIndex < self.generatedChunkURLs.count && !self.isPaused {
                        self.playCurrentChunk(completion: completion)
                    } else if self.currentQueueIndex >= self.generatedChunkURLs.count {
                        self.isPlaying = false
                        self.isPaused = false
                        self.statusMessage = "Playback complete"
                        self.progressTimer?.invalidate()
                        self.playbackProgress = 1.0
                        completion()
                    }
                }
            })
            audioPlayer?.play()
            
            isPlaying = true
            isPaused = false
            statusMessage = "Playing chunk \(currentQueueIndex + 1)/\(generatedChunkURLs.count)"
            startProgressTimer()
        } catch {
            statusMessage = "Playback error: \(error.localizedDescription)"
            isPlaying = false
            completion()
        }
    }
    
    private func togglePause() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            isPlaying = false
            isPaused = true
            statusMessage = "Paused"
            progressTimer?.invalidate()
        } else if isPaused {
            player.play()
            isPlaying = true
            isPaused = false
            statusMessage = "Playing chunk \(currentQueueIndex + 1)/\(generatedChunkURLs.count)"
            startProgressTimer()
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        playTask?.cancel()
        isPlaying = false
        isPaused = false
        currentQueueIndex = 0
        currentChunkIndex = 0
        playbackProgress = 0
        progressTimer?.invalidate()
        statusMessage = "Stopped"
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateProgress()
        }
    }
    
    private func updateProgress() {
        guard generatedChunkURLs.count > 0 else { return }
        
        let chunkWeight = 1.0 / Double(generatedChunkURLs.count)
        let chunkProgress = audioPlayer?.currentTime ?? 0
        let chunkDuration = audioPlayer?.duration ?? 1
        let chunkFraction = chunkDuration > 0 ? chunkProgress / chunkDuration : 0
        
        let baseProgress = Double(currentQueueIndex) * chunkWeight
        playbackProgress = baseProgress + chunkFraction * chunkWeight
    }
    
    private func saveAudio() {
        guard !generatedChunkURLs.isEmpty else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.wav]
        panel.nameFieldStringValue = "kokoro_output.wav"
        panel.begin { response in
            if response == .OK, let destination = panel.url {
                do {
                    if self.generatedChunkURLs.count == 1 {
                        try FileManager.default.copyItem(at: self.generatedChunkURLs[0], to: destination)
                    } else {
                        try self.concatWavFiles(chunkURLs: self.generatedChunkURLs, outputURL: destination)
                    }
                    self.statusMessage = "Saved to \(destination.path)"
                } catch {
                    self.statusMessage = "Save error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func concatWavFiles(chunkURLs: [URL], outputURL: URL) throws {
        let finalData = NSMutableData()
        
        for (index, chunkURL) in chunkURLs.enumerated() {
            let data = try Data(contentsOf: chunkURL)
            if index == 0 {
                finalData.append(data)
            } else {
                let headerSize = 44
                if data.count > headerSize {
                    finalData.append(data.subdata(in: headerSize..<data.count))
                }
            }
        }
        
        try finalData.write(to: outputURL)
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            onFinish()
        }
    }
}
