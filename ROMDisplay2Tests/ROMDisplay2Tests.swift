//
//  ROMDisplay2Tests.swift
//  ROMDisplay2Tests
//
//  Created by Jennifer Murdoch on 2018-02-19.
//  Copyright © 2018 Jennifer Murdoch. All rights reserved.
//

import Mockingjay
import XCTest
@testable import ROMDisplay2

class ROMDisplay2Tests: XCTestCase {
    
    let MediaItemsUrl = "https://media-rest-service.herokuapp.com/media"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMediaItemPopulatorGetMediaItemsListSuccess() {
        
        let expectation = XCTestExpectation(description: "GET list of 5 media item IDs")
        
        // Test with 5 media items in list
        let indexBody:Dictionary<String, Any> = [
            "ANY_KEY": ["e76d3718-70c7-4101-9a17-a5143b47b137", "5fdcea83-ec7d-4f42-a833-2b930072fa2a", "41a6f236-29bd-40b7-ac36-b33d099317a7", "6872cf9a-c643-46a7-a536-06db89c3dd3c", "50e987dd-f40e-4095-8096-0f6ec8bd4824"]
        ]
        stub(uri(MediaItemsUrl), json(indexBody))
        
        let mip = MediaItemPopulator()
        mip.getMediaItemsList(callback: { mediaItemsList in
            XCTAssert(mediaItemsList.count == 5)
            XCTAssertEqual(mediaItemsList[0].index, 0)
            XCTAssertEqual(mediaItemsList[0].id, "e76d3718-70c7-4101-9a17-a5143b47b137")
            XCTAssertNil(mediaItemsList[0].url)
            XCTAssertEqual(mediaItemsList[1].index, 1)
            XCTAssertEqual(mediaItemsList[1].id, "5fdcea83-ec7d-4f42-a833-2b930072fa2a")
            XCTAssertNil(mediaItemsList[1].url)
            XCTAssertEqual(mediaItemsList[2].index, 2)
            XCTAssertEqual(mediaItemsList[2].id, "41a6f236-29bd-40b7-ac36-b33d099317a7")
            XCTAssertNil(mediaItemsList[2].url)
            XCTAssertEqual(mediaItemsList[3].index, 3)
            XCTAssertEqual(mediaItemsList[3].id, "6872cf9a-c643-46a7-a536-06db89c3dd3c")
            XCTAssertNil(mediaItemsList[3].url)
            XCTAssertEqual(mediaItemsList[4].index, 4)
            XCTAssertEqual(mediaItemsList[4].id, "50e987dd-f40e-4095-8096-0f6ec8bd4824")
            XCTAssertNil(mediaItemsList[4].url)
            
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMediaItemPopulatorGetMediaItemsListFailure() {

        let expectation = XCTestExpectation(description: "GET empty list of media item IDs")
        
        // Test with 5 media items in list
        let indexBody:Dictionary<String, Any> = [
            "ANY_KEY": []
        ]
        stub(uri(MediaItemsUrl), json(indexBody))
        
        let mip = MediaItemPopulator()
        mip.getMediaItemsList(callback: { mediaItemsList in
            XCTAssert(mediaItemsList.count == 0)
            
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
 
    func testMediaItemPopulatorGetMediaItemSuccess() {

        let expectation = XCTestExpectation(description: "GET media item metadata")
        
        let itemBody:Dictionary<String, Any> = [
            "id": [[
                "quality": "auto",
                "duration": 5,
                "name": "media-item-1",
                "url": "https://s3-us-west-2.amazonaws.com/caustic-rest-service-bucket/Beija_Flor_na_Chuva.mp4",
                "id": "e76d3718-70c7-4101-9a17-a5143b47b137"
                ]]
        ]
        stub(uri("\(MediaItemsUrl)/e76d3718-70c7-4101-9a17-a5143b47b137"), json(itemBody))
        
        var mediaItem = MediaItem(index: 0, id: "e76d3718-70c7-4101-9a17-a5143b47b137")
        
        let mip = MediaItemPopulator()
        mip.mediaItems.append(mediaItem)
        mip.getMediaItem(mediaItem: mediaItem, callback: { mediaItems in
            
            XCTAssertNotNil(mip.mediaItems[0].url)
            XCTAssertEqual(mip.mediaItems[0].url, "https://s3-us-west-2.amazonaws.com/caustic-rest-service-bucket/Beija_Flor_na_Chuva.mp4")
            
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
 
    func testMediaItemPopulatorGetMediaItemFailure() {

        let expectation = XCTestExpectation(description: "GET media item metadata")
        
        let itemBody:Dictionary<String, Any> = [
            "id": "ANY_ID"
        ]
        stub(uri("\(MediaItemsUrl)/e76d3718-70c7-4101-9a17-a5143b47b137"), json(itemBody))
        
        var mediaItem = MediaItem(index: 0, id: "e76d3718-70c7-4101-9a17-a5143b47b137")
        
        let mip = MediaItemPopulator()
        mip.mediaItems.append(mediaItem)
        mip.getMediaItem(mediaItem: mediaItem, callback: { mediaItems in
            
            XCTAssertNil(mip.mediaItems[0].url)
            
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
}
