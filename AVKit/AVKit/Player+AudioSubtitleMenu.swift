//
//  Player+AudioSubtitleMenu.swift
//  AVKit
//
//  Created by yulin on 2022/1/4.
//

import Foundation
import UIKit

extension VideoPlayer: UITableViewDelegate, UITableViewDataSource {


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

        switch tableView {
        case subtitleTrackMenu:
            if let myLabel = cell.textLabel {
                myLabel.text =
                "\(subtitleTrackGroup?.options[indexPath.row].displayName)"
            }
            if indexPath.row == subtitleTrackSelectedIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case audioTrackMenu:
            if let myLabel = cell.textLabel {
                myLabel.text =
                "\(audioTrackGroup?.options[indexPath.row].displayName)"
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

        print("didTap\(indexPath.row)")

        switch tableView {
        case subtitleTrackMenu:
            subtitleTrackSelectedIndex = indexPath.row
        case audioTrackMenu:
            audioTrackSelectedIndex = indexPath.row
        default:
            return
        }

    }

    func showAudioSubtitleMenu() {
        audioSubtitleControlsContainerView.isHidden = false
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
            button.setImage(image, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .black
            button.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
            return button
        }()

        self.addSubview(audioSubtitleControlsContainerView)
        audioSubtitleControlsContainerView.frame = self.frame

        audioSubtitleControlsContainerView.addSubview(tableStackView)

        tableStackView.frame = audioSubtitleControlsContainerView.frame
        tableStackView.distribution = .fillEqually
        tableStackView.axis = .horizontal
        tableStackView.spacing = 10

        subtitleTrackMenu.delegate = self
        subtitleTrackMenu.dataSource = self
        subtitleTrackMenu.reloadData()
        subtitleTrackMenu.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        subtitleTrackMenu.translatesAutoresizingMaskIntoConstraints = false
        subtitleTrackMenu.allowsSelection = true
        subtitleTrackMenu.allowsMultipleSelection = false
        subtitleTrackMenu.allowsSelection = true
        audioTrackMenu.delegate = self
        audioTrackMenu.dataSource = self
        audioTrackMenu.reloadData()
        audioTrackMenu.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        audioTrackMenu.translatesAutoresizingMaskIntoConstraints = false
        audioTrackMenu.allowsSelection = true
        audioTrackMenu.largeContentTitle = "audioTrack"
        audioTrackMenu.allowsSelection = true
        audioTrackMenu.allowsMultipleSelection = false
        tableStackView.addArrangedSubview(subtitleTrackMenu)
        tableStackView.addArrangedSubview(audioTrackMenu)

        audioSubtitleControlsContainerView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: audioSubtitleControlsContainerView.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: audioSubtitleControlsContainerView.trailingAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        audioSubtitleControlsContainerView.isHidden = true
    }

    @objc private func closeMenu() {
        audioSubtitleControlsContainerView.isHidden = true
    }

}
