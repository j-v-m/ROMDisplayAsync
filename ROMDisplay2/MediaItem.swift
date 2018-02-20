//
//  MediaItem.swift
//  ROMDisplay2
//
//  Created by Jennifer Murdoch on 2018-02-19.
//  Copyright © 2018 Jennifer Murdoch. All rights reserved.
//

import Foundation

class MediaItem {
    
    let index: Int
    let id: String
    var url: String?
    
    init(index: Int, id: String) {
        self.index = index
        self.id = id
        self.url = nil
    }
}
