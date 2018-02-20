//
//  ViewController.swift
//  ROMDisplay2
//
//  Created by Jennifer Murdoch on 2018-02-19.
//  Copyright © 2018 Jennifer Murdoch. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerViewController: UIViewController {
    
    let SupportedPlayerExtensions = ["mp4", "mov", "m3u8"]
    
    var mediaItems = [MediaItem]()
    var loadingAlert: UIAlertController? = nil

    var mutex = pthread_mutex_t()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pthread_mutex_init(&mutex, nil)

        let mediaItemPopulator = MediaItemPopulator()

        // Execute change listener on the main queue
        NotificationCenter.default.addObserver(forName: .modelChange, object: nil, queue: OperationQueue.main, using: modelChangeHandler)
        
        // Begin asynchronous retrieval of media item resources
        mediaItemPopulator.start()
        
        // Display a loading alert until the first video
        // is ready to begin playing
        loadingAlert = UIAlertController(title: "Loading...", message: "Retreiving media metadata.\nThis may take some time.", preferredStyle: UIAlertControllerStyle.alert)
        self.present(loadingAlert!, animated: true, completion: nil)
    }
    
    @objc
    func modelChangeHandler(notification: Notification) {
        
        pthread_mutex_lock(&mutex)
        print("Model Change BEGIN !!")
        if let userInfo = notification.userInfo
        {
            if let mediaItems = userInfo["media_items"] as? [MediaItem] {
                    self.mediaItems = mediaItems
            }
            
            // Dismiss the loading alert and begin playing videos
            // only once the first video URL becomes available
            if self.loadingAlert != nil && mediaItems.count > 0 && mediaItems[0].url != nil {

                loadingAlert!.dismiss(animated: true, completion: nil)
                loadingAlert = nil
                
                // Begin playing videos
                curMediaItemIdx = 0
                playMediaItem()
            }
        }
        print("Model Change END !!")
        pthread_mutex_unlock(&mutex)
    }
    
    var curMediaItemIdx: Int = -1
    var playerLayer: AVPlayerLayer? = nil
    
    func playMediaItem() {
        
        let curMediaItem = mediaItems[curMediaItemIdx]
        
        // If the current media item has no URL, continue to the next
        if curMediaItem.url == nil {
            curMediaItemIdx = (curMediaItemIdx+1)%mediaItems.count
            playMediaItem()
            return
        }
        
        print("Attempting to play \(curMediaItemIdx): \(curMediaItem.url!)")
        
        // Check that the video file extensions is a playable format
        let ext = URL(string:curMediaItem.url!)!.pathExtension
        
        if self.SupportedPlayerExtensions.contains(ext) {
            
            let videoURL = URL(string: curMediaItem.url!)
            
            // Play the video in the UI
            let player = AVPlayer(url: videoURL!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer!)
            player.play()
            
            print("Playing")
            
            // Add observers
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        }
        else {
            curMediaItemIdx = (curMediaItemIdx+1)%mediaItems.count
            playMediaItem()
        }
    }
    
    @objc func playerDidFinishPlaying(sender: AnyObject){
        print("Finished")
        
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        
        // Remove the player
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // Advance to the next media item
        curMediaItemIdx = (curMediaItemIdx+1)%mediaItems.count
        playMediaItem()
    }
}

