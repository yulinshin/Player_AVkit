//
//  Player.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//
import AVFoundation
import UIKit

class VideoPlayer: UIView {

    let firstUrl = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    let secUrl = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .black
        if let url = URL(string: firstUrl) {
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            player.play()
        }
    }

}
