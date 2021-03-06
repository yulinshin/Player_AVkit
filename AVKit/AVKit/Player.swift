//
//  Player.swift
//  AVKit
//
//  Created by yulin on 2022/1/3.
//
import AVFoundation
import UIKit

class VideoPlayer: UIView {

    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerQueue: [AVPlayerItem] = []
    private var playerItemContext = 0

    var audioTrackMenu = UITableView()
    var subtitleTrackMenu = UITableView()
    var audioTrackGroup: AVMediaSelectionGroup?
    var subtitleTrackGroup: AVMediaSelectionGroup?
    var didFinishedPlaying: (() -> Void )?

    lazy var tapScreenGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapScreen))
        tap.numberOfTapsRequired = 1
        return tap
    }()

//MARK: - Player Status
    private var isPlaying = false {
        didSet {
            if isPlaying {
                let image = UIImage(systemName: "pause")
                pausePlayButton.setBackgroundImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "play")
                pausePlayButton.setBackgroundImage(image, for: .normal)
            }
        }
    }

    var isShowingControllers = false {
        didSet{
            if isShowingControllers {
                controlsContainerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                controlsContainerView.subviews.forEach { $0.isHidden = false }
            } else {
                controlsContainerView.backgroundColor = UIColor(white: 0, alpha: 0)
                controlsContainerView.subviews.forEach { $0.isHidden = true }
            }

            checkIfIsLastItem()

        }
    }

    private func checkIfIsLastItem() {
        if player?.currentItem == player?.items().last {
            nextTrackButton.isHidden = true
        }
    }

//MARK: - Controls UI Element

    private let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        return view
    }()

    private let pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "pause")
         button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "goforward.10")
         button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gobackward.10")
         button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleBackward), for: .touchUpInside)
        button.isHidden = true
        return button
    }()


    private let nextTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "forward.end")
         button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleNextTrack), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let audioSubtitlesTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "dock.rectangle")
         button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAudioSubtitles), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let aiView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.startAnimating()
        return aiView
    }()

    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.isHidden = true
        return label
    }()

    private let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .gray
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        slider.isHidden = true
        return slider
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")
        button.setBackgroundImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(playerDidFinishPlaying), for: .touchUpInside)
        return button
    }()


    //MARK: - Audio & Subtitle Setting Menu

    let audioSubtitleControlsContainerView: UIView = {
        let view = UIStackView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        view.isHidden = true
        return view
    }()

    var audioTrackSelectedIndex: Int? {
        didSet {
            guard let audioTrackGroup = audioTrackGroup,
                  let audioTrackSelectedIndex = audioTrackSelectedIndex else {
                return
            }
            audioTrackMenu.reloadData()
            player?.currentItem?.select(audioTrackGroup.options[audioTrackSelectedIndex], in: audioTrackGroup)
        }
    }

    var subtitleTrackSelectedIndex: Int? {
        didSet {
            guard let subtitleTrackGroup = subtitleTrackGroup,
                  let subtitleTrackSelectedIndex = subtitleTrackSelectedIndex else {
                return
            }
            subtitleTrackMenu.reloadData()
            player?.currentItem?.select(subtitleTrackGroup.options[subtitleTrackSelectedIndex], in: subtitleTrackGroup)
        }
    }

//MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, urlStrs:[String]){
        self.init(frame: frame)
        self.addGestureRecognizer(tapScreenGesture)
        self.isUserInteractionEnabled = true
        tapScreenGesture.isEnabled = true
        backgroundColor = .black
        setupPlayList(content: urlStrs)
        addIndicator()
        setupControls()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Player Dead")
    }

    private func setupControls() {
        addSubview(controlsContainerView)
        addControls()
        isShowingControllers = false
        setupControlsLayout()
        setupAudioSubtitleMenu()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
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

//MARK: -User Interactive

    @objc func didTapScreen() {
        isShowingControllers = !isShowingControllers
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
        player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &self.playerItemContext)
        player?.advanceToNextItem()
        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &self.playerItemContext)
        activityIndicatorView.startAnimating()
        player?.play()
        isPlaying = true
        isShowingControllers = false
    }

    @objc private func playerDidFinishPlaying(){
        if let play = player {
               play.pause()
               player = nil
           } 
        didFinishedPlaying?()
    }

    private func setupPlayList(content: [String]) {

        guard content.count != 0 else { return }
        playerQueue = createPlayerQueue(with: content)
        player = AVQueuePlayer(items: playerQueue)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerQueue.last)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bounds
        self.layer.addSublayer(playerLayer!)

        player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &self.playerItemContext)
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

    private func addIndicator() {
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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

    //MARK: - UI Element Layout

        private func setupControlsLayout(){

            let largeButtonSize: CGFloat = 28
            let buttonSize: CGFloat = 24

            controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
            controlsContainerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            controlsContainerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            controlsContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            controlsContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

            pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            pausePlayButton.widthAnchor.constraint(equalToConstant: largeButtonSize).isActive = true
            pausePlayButton.heightAnchor.constraint(equalToConstant: largeButtonSize).isActive = true

            forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            forwardButton.leadingAnchor.constraint(equalTo: pausePlayButton.trailingAnchor, constant: 20).isActive = true
            forwardButton.widthAnchor.constraint(equalToConstant: largeButtonSize).isActive = true
            forwardButton.heightAnchor.constraint(equalToConstant: largeButtonSize).isActive = true

            backwardButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            backwardButton.trailingAnchor.constraint(equalTo: pausePlayButton.leadingAnchor, constant: -20).isActive = true
            backwardButton.widthAnchor.constraint(equalToConstant: largeButtonSize).isActive = true
            backwardButton.heightAnchor.constraint(equalToConstant: largeButtonSize).isActive = true

            nextTrackButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -20).isActive = true
            nextTrackButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            nextTrackButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            nextTrackButton.trailingAnchor.constraint(equalTo: audioSubtitlesTrackButton.leadingAnchor, constant: -10).isActive = true

            videoLengthLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -10).isActive = true
            videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true
            videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

            currentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 10).isActive = true
            currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

            progressSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
            progressSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true
            progressSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
            progressSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true

            closeButton.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 10).isActive = true
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
            closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true

            audioSubtitlesTrackButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -20).isActive = true
            audioSubtitlesTrackButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -30).isActive = true
            audioSubtitlesTrackButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            audioSubtitlesTrackButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        }

        private func addControls(){
            controlsContainerView.addSubview(pausePlayButton)
            controlsContainerView.addSubview(forwardButton)
            controlsContainerView.addSubview(backwardButton)
            controlsContainerView.addSubview(currentTimeLabel)
            controlsContainerView.addSubview(videoLengthLabel)
            controlsContainerView.addSubview(progressSlider)
            controlsContainerView.addSubview(nextTrackButton)
            controlsContainerView.addSubview(closeButton)
            controlsContainerView.addSubview(audioSubtitlesTrackButton)
        }
}


#if DEBUG
extension VideoPlayer {
    public func exposePrivatePlayer() -> AVQueuePlayer? {
        return self.player
    }
    public func exposePrivatePlayerIsPlaying() -> Bool {
        return self.isPlaying
    }
}
#endif
