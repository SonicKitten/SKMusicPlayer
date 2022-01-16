//
//  MusicPlayer.swift
//  Freesound Safari
//
//  Created by James Navarro on 12/20/21.
//
// 

import Foundation
import AVFoundation


@objc enum PlayState: Int {
    case playing = 0
    case paused = 1
    case loading = 2
    case stopped = 3
}

class MusicPlayer: NSObject {
    
    static let shared = MusicPlayer()
    var currentURL: URL?
    
    // currentID will be nil when player stops.
    // you should check prevID on stop to know
    // which sound just stopped
    var currentID: Int?
    var prevID: Int?
    
    @objc dynamic private(set) var playState: PlayState = .stopped
    
    private var isSessionInit: Bool
    private var player: AVPlayer?
    private var playerStatusToken: NSKeyValueObservation?
    var playerItemActive: Bool = false
    
    override init() {
        // init props
        isSessionInit = false
        
        super.init()
        
        // other stuff
        NotificationCenter.default.addObserver(self, selector: #selector(playerReachedEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        print("")
    }
    
    // url - a local/remote file url
    // soundID - a unique id for the sound. It's purely for client purposes.
    // So if you don't care just use 0 or something.
    func playSoundFromURL(url: URL, soundID: Int) throws {
        if isSessionInit == false {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        currentURL = url
        
        // if nothing is playing currently, don't use that as a prevID
        if currentID != nil {
            prevID = currentID
        }
        currentID = soundID
        
        // setup player
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        
        // watch .timeControlStatus
        playerStatusToken = player?.observe(\.timeControlStatus, options: [.old, .new], changeHandler: { [weak self] player, change in
            if player.timeControlStatus == AVPlayer.TimeControlStatus.paused {
                if self?.playerItemActive == false {
                    print("playback stopped")
                    self?.prevID = self?.currentID
                    self?.currentID = nil
                    self?.currentURL = nil
                    self?.playState = .stopped
                }
                else {
                    print("playback paused")
                    self?.playState = .paused
                }
            }
            else if player.timeControlStatus == AVPlayer.TimeControlStatus.playing {
                self?.playState = .playing
            }
            else if player.timeControlStatus == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate {
                self?.playState = .loading
            }
        })
        player?.play()
        playerItemActive = true
    }
    
    func pause() {
        player?.pause()
    }
    
    func unpause() {
        player?.play()
    }
    
    // Get notification from AVPlayer
    @objc func playerReachedEnd() {
        print("playerReachedEnd")
        playerItemActive = false
    }
}
