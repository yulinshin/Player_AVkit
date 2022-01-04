//
//  PlayListTableViewController.swift
//  AVKit
//
//  Created by yulin on 2022/1/4.
//

import UIKit

class PlayListTableViewController: UITableViewController {

    let videoUrls = ["https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                     "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"]


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return   videoUrls.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let textLabel = cell.textLabel {
            textLabel.text = "Video:\(indexPath.row + 1)"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let playerController = PlayerViewController()
        playerController.playlist = videoUrls
        playerController.modalPresentationStyle = .fullScreen
        self.present(playerController, animated: true, completion: nil)

    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
