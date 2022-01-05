//
//  Player+AudioSubtitleMenu.swift
//  AVKit
//
//  Created by yulin on 2022/1/4.
//

import Foundation
import UIKit

extension VideoPlayer: UITableViewDelegate, UITableViewDataSource {

    func showAudioSubtitleMenu() {
        audioSubtitleControlsContainerView.isHidden = false
        tapScreenGesture.isEnabled = false
    }

    func setupAudioSubtitleMenu() {

        let tableStackView: UIStackView = {
            let view = UIStackView()
            view.backgroundColor = .clear
            return view
        }()

        let closeButton: UIButton = {
            let button = UIButton(type: .system)
            let image = UIImage(systemName: "xmark")
            button.setBackgroundImage(image, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .white
            button.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
            return button
        }()

        setLayout(tableStackView: tableStackView, closeButton: closeButton)
        setupTableViews()
        audioSubtitleControlsContainerView.isHidden = true
    }

    @objc private func closeMenu() {
        audioSubtitleControlsContainerView.isHidden = true
        tapScreenGesture.isEnabled = true
    }

    private func setupTableViews(){

        subtitleTrackMenu.delegate = self
        subtitleTrackMenu.dataSource = self
        subtitleTrackMenu.reloadData()
        subtitleTrackMenu.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        subtitleTrackMenu.translatesAutoresizingMaskIntoConstraints = false
        subtitleTrackMenu.allowsSelection = true
        subtitleTrackMenu.allowsMultipleSelection = false
        subtitleTrackMenu.allowsSelection = true
        subtitleTrackMenu.backgroundColor = .clear
        audioTrackMenu.delegate = self
        audioTrackMenu.dataSource = self
        audioTrackMenu.reloadData()
        audioTrackMenu.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        audioTrackMenu.translatesAutoresizingMaskIntoConstraints = false
        audioTrackMenu.allowsSelection = true
        audioTrackMenu.largeContentTitle = "audioTrack"
        audioTrackMenu.allowsSelection = true
        audioTrackMenu.allowsMultipleSelection = false
        audioTrackMenu.backgroundColor = .clear

    }

    private func setLayout(tableStackView: UIStackView, closeButton: UIButton){

        self.addSubview(audioSubtitleControlsContainerView)
        audioSubtitleControlsContainerView.addSubview(tableStackView)
        audioSubtitleControlsContainerView.addSubview(closeButton)
        tableStackView.addArrangedSubview(subtitleTrackMenu)
        tableStackView.addArrangedSubview(audioTrackMenu)

        audioSubtitleControlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        audioSubtitleControlsContainerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        audioSubtitleControlsContainerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        audioSubtitleControlsContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        audioSubtitleControlsContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        tableStackView.distribution = .fillEqually
        tableStackView.axis = .horizontal
        tableStackView.spacing = 10

        tableStackView.translatesAutoresizingMaskIntoConstraints = false
        tableStackView.widthAnchor.constraint(equalTo: audioSubtitleControlsContainerView.widthAnchor).isActive = true
        tableStackView.heightAnchor.constraint(equalTo: audioSubtitleControlsContainerView.heightAnchor).isActive = true
        tableStackView.centerYAnchor.constraint(equalTo: audioSubtitleControlsContainerView.centerYAnchor).isActive = true
        tableStackView.centerXAnchor.constraint(equalTo: audioSubtitleControlsContainerView.centerXAnchor).isActive = true

        closeButton.topAnchor.constraint(equalTo: audioSubtitleControlsContainerView.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: audioSubtitleControlsContainerView.trailingAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

//MARK: -TableViewDelegate & DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableView {
        case subtitleTrackMenu:
            return subtitleTrackGroup?.options.count ?? 0

        case audioTrackMenu:
            return audioTrackGroup?.options.count ?? 0

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        switch tableView {
        case subtitleTrackMenu:
            guard let subtitleTrackGroup = subtitleTrackGroup else { return cell }
            if let myLabel = cell.textLabel {
                myLabel.text =
                "\(subtitleTrackGroup.options[indexPath.row].displayName)"
            }
            if indexPath.row == subtitleTrackSelectedIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case audioTrackMenu:

            guard let audioTrackGroup = audioTrackGroup else { return cell }
            if let myLabel = cell.textLabel {
                myLabel.text =
                "\(audioTrackGroup.options[indexPath.row].displayName)"
            }
            if indexPath.row == audioTrackSelectedIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

        default:
            return cell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch tableView {
        case subtitleTrackMenu:
            return "Subtitle"

        case audioTrackMenu:
            return "audioTrack"

        default:
            return ""
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch tableView {
        case subtitleTrackMenu:
            subtitleTrackSelectedIndex = indexPath.row
        case audioTrackMenu:
            audioTrackSelectedIndex = indexPath.row
        default:
            return
        }

    }

}
