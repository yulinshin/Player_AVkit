//
//  ViewController.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//

import UIKit

class ViewController: UIViewController {

    let videoUrls = ["https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    private func setupPlayer() {
        let videoPlayFrame = view.frame
        let videoPlayerView  = VideoPlayer(frame: videoPlayFrame, urlStrs: videoUrls)
        view.addSubview(videoPlayerView)
    }


}

