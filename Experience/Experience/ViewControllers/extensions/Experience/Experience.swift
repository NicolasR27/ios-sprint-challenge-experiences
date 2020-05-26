//
//  Experience.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//


import Foundation
import MapKit

class Experience: NSObject, Codable {
   
  var experienceTitle: String
  var latitude: Double
  var longitude: Double
  var pictureData: Data
  var videoUrl: String?
  var audioUrl: String?
    
  init(experienceTitle: String,
     geotag: CLLocationCoordinate2D,
     pictureData: Data,
     videoUrl: String?,
     audioUrl: String?) {
    self.experienceTitle = experienceTitle
    self.latitude = geotag.latitude
    self.longitude = geotag.longitude
    self.pictureData = pictureData
    self.videoUrl = videoUrl
    self.audioUrl = audioUrl
  }
}
