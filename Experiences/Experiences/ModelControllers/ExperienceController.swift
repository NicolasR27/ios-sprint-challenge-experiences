//
//  ExperienceController.swift
//  Experiences
//
//  Created by Nicolas Rios on 5/17/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import Foundation
import MapKit

class ExperienceController {
    private (set) var experiences: [Experience] = []
    
    func createExperience(withExperienceTitle experienceTitle: String, withImageData imageData: Data, withAudioURL audioURL: URL, withVideoURL videoURL: URL, withCoordinate coordinate: CLLocationCoordinate2D) {
        let experience = Experience(experienceTitle: experienceTitle, coordinate: coordinate, audioURL: audioURL, imageData: imageData, videoURL: videoURL)
        self.experiences.append(experience)
    }
}
