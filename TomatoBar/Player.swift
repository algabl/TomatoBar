import AVFoundation
import SwiftUI

class TBPlayer: ObservableObject {
    private var windupSound: AVAudioPlayer
    private var workDingSound: AVAudioPlayer
    private var restDingSound: AVAudioPlayer
    private var tickingSound: AVAudioPlayer

    @AppStorage("windupVolume") var windupVolume: Double = 1.0 {
        didSet {
            setVolume(windupSound, windupVolume)
        }
    }
    @AppStorage("workDingVolume") var workDingVolume: Double = 1.0 {
        didSet {
            setVolume(workDingSound, workDingVolume)
        }
    }
    @AppStorage("restDingVolume") var restDingVolume: Double = 1.0 {
        didSet {
            setVolume(restDingSound, restDingVolume)
        }
    }
    @AppStorage("tickingVolume") var tickingVolume: Double = 1.0 {
        didSet {
            setVolume(tickingSound, tickingVolume)
        }
    }

    private func setVolume(_ sound: AVAudioPlayer, _ volume: Double) {
        sound.setVolume(Float(volume), fadeDuration: 0)
    }

    init() {
        let windupSoundAsset = NSDataAsset(name: "windup")
        let workDingSoundAsset = NSDataAsset(name: "ding")
        let restDingSoundAsset = NSDataAsset(name: "ding")
        let tickingSoundAsset = NSDataAsset(name: "ticking")

        let wav = AVFileType.wav.rawValue
        do {
            windupSound = try AVAudioPlayer(data: windupSoundAsset!.data, fileTypeHint: wav)
            workDingSound = try AVAudioPlayer(data: workDingSoundAsset!.data, fileTypeHint: wav)
            restDingSound = try AVAudioPlayer(data: restDingSoundAsset!.data, fileTypeHint: wav)
            tickingSound = try AVAudioPlayer(data: tickingSoundAsset!.data, fileTypeHint: wav)
        } catch {
            fatalError("Error initializing players: \(error)")
        }

        windupSound.prepareToPlay()
        workDingSound.prepareToPlay()
        restDingSound.prepareToPlay()
        tickingSound.numberOfLoops = -1
        tickingSound.prepareToPlay()

        setVolume(windupSound, windupVolume)
        setVolume(workDingSound, workDingVolume)
        setVolume(restDingSound, restDingVolume)
        setVolume(tickingSound, tickingVolume)
        
    }

    func playWindup() {
        windupSound.play()
    }

    func playWorkDing() {
        workDingSound.play()
    }

    func playRestDing() {
        restDingSound.play()
    }
    
    func startTicking() {
        tickingSound.play()
    }

    func stopTicking() {
        tickingSound.stop()
    }
}
