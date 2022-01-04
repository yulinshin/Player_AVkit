//
//  ViewController.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//

import UIKit

class PlayerViewController: UIViewController {

    var videoPlayerView: VideoPlayer?
    var playlist = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }

    private func setupPlayer() {
        videoPlayerView = VideoPlayer(frame: self.view.frame, urlStrs: playlist)
        videoPlayerView?.didFinishedPlaying = {
            self.dismiss(animated: true, completion: nil)
        }
        view.addSubview(videoPlayerView!)
        videoPlayerView?.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        videoPlayerView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoPlayerView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        videoPlayerView?.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
}



