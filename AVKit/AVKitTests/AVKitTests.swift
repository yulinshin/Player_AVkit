//
//  AVKitTests.swift
//  AVKitTests
//
//  Created by yulin on 2022/1/5.
//

import XCTest
@testable import AVKit

class AVKitTests: XCTestCase {

    var playerTest: VideoPlayer!

    override func setUpWithError() throws {
       try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        playerTest = nil
    }

    func testPlayerWithTwoSource() {
        let urls = ["https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                    "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"]
        playerTest = VideoPlayer(frame: CGRect(x: 0, y: 0, width: 0, height: 0), urlStrs: urls)
        let player = playerTest.exposePrivatePlayer()!
        let isPlaying = playerTest.exposePrivatePlayerIsPlaying()
        XCTAssertNotNil(player)
        XCTAssertEqual(player.items().count, 2)
        XCTAssertTrue(isPlaying)
    }
    
}
