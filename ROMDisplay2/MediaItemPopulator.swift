//
//  MediaItemPopulator.swift
//  ROMDisplay2
//
//  Created by Jennifer Murdoch on 2018-02-19.
//  Copyright © 2018 Jennifer Murdoch. All rights reserved.
//

import Alamofire
import Foundation

// Notification when the media item ID list becomes available, OR
// a new media item URL becomes available
extension Notification.Name {
    static let modelChange = Notification.Name("modelChange")
}

class MediaItemPopulator {
    
    static let MediaItemsUrl = "https://media-rest-service.herokuapp.com/media"
    
    internal var mediaItems = [MediaItem]()

    private let queue = DispatchQueue(label: "serialQueue")
    
    func start() {
        getMediaItemsList()
    }

    internal func getMediaItemsList(callback: (([MediaItem]) -> Void)? = nil) {
        
        Alamofire.request(MediaItemPopulator.MediaItemsUrl)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                    case .success(let json):
                    
                        let dict = json as! NSDictionary
                        
                        // Don't get value based on key, as the key is transient
                        let mediaItemsJson = dict.allValues.first as? [String]
                        
                        print("Media Items Size: \(mediaItemsJson!.count)")
                        
                        if mediaItemsJson != nil && mediaItemsJson!.count > 0 {
                            
                            // Retrieve the media item IDs
                            for (index, mediaItemID) in mediaItemsJson!.enumerated() {
                                
                                let mediaItem = MediaItem(index: index, id: mediaItemID)
                                
                                self.mediaItems.append(mediaItem)
                                
                                print("\(mediaItem.index): \(mediaItem.id)")
                            }
                            
                            if callback != nil {
                                callback!(self.mediaItems)
                            }
                            
                            // Fire a notification containing the media items
                            NotificationCenter.default.post(
                                name: .modelChange, object: nil, userInfo: ["media_items" : self.mediaItems])
                            
                            // Get individual media item resources
                            self.getMediaItems()
                        }
                        else {
                            if callback != nil {
                                callback!(self.mediaItems)
                            }
                            
                            print ("Error after GET... no media items")
                            self.retryGetMediaItemsList(callback: callback)
                        }
                    
                    case .failure:
                        if callback != nil {
                            callback!(self.mediaItems)
                        }
                        
                        print ("Error with GET... failure result")
                        self.retryGetMediaItemsList(callback: callback)
                }
        }
    }
    
    private func retryGetMediaItemsList(callback: (([MediaItem]) -> Void)? = nil) {
        
        print("Waiting to retry...")
        queue.asyncAfter(deadline: DispatchTime.now()+5){
            print("Retrying...")
            self.getMediaItemsList(callback: callback)
        }
    }
    
    private func getMediaItems() {
        
        for mediaItem in mediaItems {
            getMediaItem(mediaItem: mediaItem)
        }
    }
    
    internal func getMediaItem(mediaItem: MediaItem, callback: (([MediaItem]) -> Void)? = nil) {
        
        print("GET media item #\(mediaItem.index)")
        
        Alamofire.request("\(MediaItemPopulator.MediaItemsUrl)/\(mediaItem.id)")
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let json):
                    
                    let dict = json as! NSDictionary
                    let mediaItemArr = dict.allValues.first as? [Any]
                    
                    if mediaItemArr != nil && mediaItemArr!.count == 1
                    {
                        let mediaItemDict = mediaItemArr![0] as? NSDictionary
                        print("JSON: \(String(describing:mediaItemDict))") // serialized json response
                        
                        // Retrieve the media item URL
                        if mediaItemDict != nil {
                            let urlString = mediaItemDict!.value(forKey: "url") as? String
                            if urlString != nil {
                                print("#\(mediaItem.index) URL: \(String(describing:urlString))")
                                
                                mediaItem.url = urlString
                                
                                if callback != nil {
                                    callback!(self.mediaItems)
                                }
                                
                                NotificationCenter.default.post(
                                    name: .modelChange, object: nil, userInfo: ["media_items" : self.mediaItems])
                            }
                            else {
                                print ("Error... no URL in media item dictionary")
                                
                                if callback != nil {
                                    callback!(self.mediaItems)
                                }
                                
                                self.retryGetMediaItem(mediaItem: mediaItem)
                            }
                        }
                        else {
                            print ("Error after GET... no media item")
                            
                            if callback != nil {
                                callback!(self.mediaItems)
                            }
                            
                            self.retryGetMediaItem(mediaItem: mediaItem)
                        }
                    }
                    else {
                        print ("Error after GET... no media item")
                        
                        if callback != nil {
                            callback!(self.mediaItems)
                        }
                        
                        self.retryGetMediaItem(mediaItem: mediaItem)
                    }
                    
                case .failure:
                    print ("Error with GET... failure result")
                    
                    if callback != nil {
                        callback!(self.mediaItems)
                    }
                    
                    self.retryGetMediaItem(mediaItem: mediaItem)
                }
        }
    }
    
    private func retryGetMediaItem(mediaItem: MediaItem) {
        
        print("Waiting to retry media item \(mediaItem.index)...")
        queue.asyncAfter(deadline: DispatchTime.now()+5){
            print("Retrying...")
            self.getMediaItem(mediaItem: mediaItem)
        }
    }
}
