//
//  ViewController.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    private func setupPlayer() {
        let videoPlayFrame = view.frame
        let videoPlayerView  = VideoPlayer(frame: videoPlayFrame)
        view.addSubview(videoPlayerView)
    }


}

