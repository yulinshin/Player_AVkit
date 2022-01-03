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


    let pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.startAnimating()
        return aiView
    }()

    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        return view
    }()

    var player: AVPlayer?
    var isPlaying = false
    var isShowingControllers = false {
        didSet{
            if isShowingControllers {
                controlsContainerView.isHidden = false
            } else {
                controlsContainerView.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        controlsContainerView.frame = frame
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showControls)))
        addSubview(controlsContainerView)
        addIndicator()
        addPauseButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
        }
    }

    @objc private func handlePause() {

        if isPlaying {
            player?.pause()
            let image = UIImage(systemName: "play")
            pausePlayButton.setImage(image, for: .normal)
            isPlaying = false

        } else {
            player?.play()
            let image = UIImage(systemName: "pause")
            pausePlayButton.setImage(image, for: .normal)
            isPlaying = true
            isShowingControllers = false
        }

    }

    @objc private func showControls() {
        isShowingControllers = true
        DispatchQueue.main.asyncAfter(deadline: .now()+3 ){
            if self.isPlaying {
                self.isShowingControllers = false
            }
        }
    }

    private func setup() {
        backgroundColor = .black
        if let url = URL(string: firstUrl) {
            player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            player?.play()
            isPlaying = true
            isShowingControllers = false
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        }
    }

    private func addIndicator() {
          self.addSubview(activityIndicatorView)
          activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
          activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      }

    private func addPauseButton() {
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }


}
