//
//  Player.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//
import AVFoundation
import UIKit

class VideoPlayer: UIView {
    var playerLayer: AVPlayerLayer?
    var playerQueue: [AVPlayerItem] = []
    var currentTrack = 0
    var audioTrackMenu = UITableView()
    var subtitleTrackMenu = UITableView()
    var audioTrackGroup: AVMediaSelectionGroup?
    var subtitleTrackGroup: AVMediaSelectionGroup?
    var audioTrackSelectedIndex: Int? {
        didSet {
            guard let audioTrackGroup = audioTrackGroup else {
                return
            }
            guard let audioTrackSelectedIndex = audioTrackSelectedIndex else {
                return
            }
            audioTrackMenu.reloadData()
            player?.currentItem?.select(audioTrackGroup.options[audioTrackSelectedIndex], in: audioTrackGroup)
        }
    }
    var subtitleTrackSelectedIndex: Int? {
        didSet {
            guard let subtitleTrackGroup = subtitleTrackGroup else {
                return
            }
            guard let subtitleTrackSelectedIndex = subtitleTrackSelectedIndex else {
                return
            }
            subtitleTrackMenu.reloadData()
            player?.currentItem?.select(subtitleTrackGroup.options[subtitleTrackSelectedIndex], in: subtitleTrackGroup)
        }
    }
    private var playerItemContext = 0

    let audioSubtitleControlsContainerView: UIView = {
        let view = UIStackView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        return view
    }()

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
        let image = UIImage(systemName: "goforward.10")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        return button
    }()

    let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "goforward.10")
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

    let audioSubtitlesTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "dock.rectangle")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAudioSubtitles), for: .touchUpInside)
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

    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()

    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()

    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .gray
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)

        return slider
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
        setupPlayList(content: urlStrs)
        setupLayout()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showControls)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupLayout() {
        addSubview(controlsContainerView)
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        controlsContainerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        controlsContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        controlsContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        addIndicator()
        addPauseButton()
        addForwardButton()
        addBackwardButton()
        addNextTrackButton()
        addPreviousTrackButton()
        addCurrentTimeLabel()
        addVideoLengthLabel()
        addProgressSlider()
        addAudioSubtitleButton()
        setupAudioSubtitleMenu()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
            if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                activityIndicatorView.stopAnimating()
                if let duration = player?.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    let secondsText = Int(seconds) % 60
                    let minutesText = String(format: "%02d", Int(seconds) / 60)
                        videoLengthLabel.text = "\(minutesText):\(secondsText)"
                }
    
            }
    }

    @objc func handleAudioSubtitles() {
        showAudioSubtitleMenu()
    }


    @objc func handleSliderChange() {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(progressSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime)
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
        player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context:  &self.playerItemContext)
        player?.replaceCurrentItem(with: playerQueue[currentTrack])
        activityIndicatorView.startAnimating()
        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &self.playerItemContext )
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
        player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context:  &self.playerItemContext)
        player?.replaceCurrentItem(with: playerQueue[currentTrack])
        activityIndicatorView.startAnimating()
        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &self.playerItemContext )
        activityIndicatorView.startAnimating()
        player?.play()
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
    private func setupPlayList(content: [String]) {
        backgroundColor = .black
        guard content.count != 0 else { return }
        playerQueue = createPlayerQueue(with: content)
        player = AVQueuePlayer(playerItem: playerQueue[currentTrack])
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.bounds
        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &self.playerItemContext )
        player?.play()
        isPlaying = true
        isShowingControllers = false
        player?.appliesMediaSelectionCriteriaAutomatically = false

        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds) % 60)
            let minutesString = String(format: "%02d", Int(seconds) / 60)
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
                self.progressSlider.value = Float(seconds / durationSeconds)
            }
        })

        guard let asset = player?.currentItem?.asset else {
            return
        }

        if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                audioTrackGroup = group
        }
        if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                subtitleTrackGroup = group
        }

        audioTrackSelectedIndex = 0
        subtitleTrackSelectedIndex = 0
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
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


    private func addVideoLengthLabel() {
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    private func addCurrentTimeLabel() {
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    private func addProgressSlider() {
        controlsContainerView.addSubview(progressSlider)
        progressSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        progressSlider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
        progressSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }

    private func addAudioSubtitleButton() {
        controlsContainerView.addSubview(audioSubtitlesTrackButton)
        audioSubtitlesTrackButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 20).isActive = true
        audioSubtitlesTrackButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -20).isActive = true
        audioSubtitlesTrackButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        audioSubtitlesTrackButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
