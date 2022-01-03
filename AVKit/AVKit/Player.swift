//
//  Player.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//
import AVFoundation
import UIKit

class VideoPlayer: UIView {
    
    var playerQueue: [AVPlayerItem] = []
    var currentTrack = 0

    let pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()

    let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "forward")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        return button
    }()

    let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "backward")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleBackward), for: .touchUpInside)
        return button
    }()


    let nextTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "forward.end")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleNextTrack), for: .touchUpInside)
        return button
    }()

    let previousTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "backward.end")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePreviousTrack), for: .touchUpInside)
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

    var player: AVQueuePlayer?
    var isPlaying = false {
        didSet {
            if isPlaying {
                let image = UIImage(systemName: "pause")
                pausePlayButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "play")
                pausePlayButton.setImage(image, for: .normal)
            }
        }
    }
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
    }

    convenience init(frame: CGRect, urlStrs:[String]){
        self.init(frame: frame)
        setup(content: urlStrs)
        controlsContainerView.frame = frame
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showControls)))
        addSubview(controlsContainerView)
        addIndicator()
        addPauseButton()
        addForwardButton()
        addBackwardButton()
        addNextTrackButton()
        addPreviousTrackButton()
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
            isPlaying = false

        } else {
            player?.play()
            isPlaying = true
            isShowingControllers = false
        }

    }

    @objc private func handleForward() {
        guard let player = player else { return }
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0
        if newTime < (CMTimeGetSeconds(duration) - 10.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }

    @objc private func handleBackward() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10.0
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }

    @objc private func handleNextTrack() {
        if currentTrack + 1 > (playerQueue.count - 1) {
               currentTrack = 0
           } else {
               currentTrack += 1;
           }
        player?.replaceCurrentItem(with: playerQueue[currentTrack])
        activityIndicatorView.startAnimating()
        player?.play()
        isPlaying = true
        isShowingControllers = false
    }

    @objc private func handlePreviousTrack(){
        if currentTrack - 1 < 0 {
              currentTrack = (playerQueue.count - 1) < 0 ? 0 : (playerQueue.count - 1)
          } else {
              currentTrack -= 1
          }
        player?.replaceCurrentItem(with: playerQueue[currentTrack])
        activityIndicatorView.startAnimating()
        player?.play()
        isPlaying = true
        isShowingControllers = false
    }

    @objc private func showControls() {
        isShowingControllers = true
        DispatchQueue.main.asyncAfter(deadline: .now()+3 ){
            if self.isPlaying {
                self.isShowingControllers = false
            }
        }
    }
    private func setup(content: [String]) {
        backgroundColor = .black
        playerQueue = createPlayerQueue(with: content)
        player = AVQueuePlayer(playerItem: playerQueue[currentTrack])
        let playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
        playerLayer.frame = self.frame
        player?.play()
        isPlaying = true
        isShowingControllers = false
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
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

    private func addForwardButton() {
        controlsContainerView.addSubview(forwardButton)
        forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        forwardButton.leadingAnchor.constraint(equalTo: pausePlayButton.trailingAnchor, constant: 20).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func addBackwardButton() {
        controlsContainerView.addSubview(backwardButton)
        backwardButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backwardButton.trailingAnchor.constraint(equalTo: pausePlayButton.leadingAnchor, constant: -20).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func addNextTrackButton() {
        controlsContainerView.addSubview(nextTrackButton)
        nextTrackButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nextTrackButton.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 20).isActive = true
        nextTrackButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        nextTrackButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func addPreviousTrackButton() {
        controlsContainerView.addSubview(previousTrackButton)
        previousTrackButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        previousTrackButton.trailingAnchor.constraint(equalTo: backwardButton.leadingAnchor, constant: -20).isActive = true
        previousTrackButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        previousTrackButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func createPlayerQueue(with content: [String]) -> [AVPlayerItem] {
            var playerQueue: [AVPlayerItem] = []
            content.forEach { urlStr in
                guard let url = URL(string: urlStr) else { return }
                let item = AVPlayerItem(url: url)
                playerQueue.append(item)
            }
            return playerQueue
        }

}
