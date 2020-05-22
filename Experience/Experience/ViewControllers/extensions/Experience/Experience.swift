//
//  Experience.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//


import Foundation
import MapKit
class Experience: NSObject {
    var experienceTitle: String
    var geotag: CLLocationCoordinate2D
    var picture: Picture
    var video: Video
    var audio: Audio
    
    init(experienceTitle: String,
         geotag: CLLocationCoordinate2D,
         picture: Picture,
         video: Video,
         audio: Audio) {
        
        self.experienceTitle = experienceTitle
        self.geotag = geotag
        self.picture = picture
        self.video = video
        self.audio = audio
    }
    
    struct Picture {
        var imagePost: UIImage
    }
    struct Video {
        var videoPost: URL
    }
    struct Audio {
        var audioPost: URL
    }
}
