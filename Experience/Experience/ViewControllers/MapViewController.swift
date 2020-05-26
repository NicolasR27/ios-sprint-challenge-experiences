//
//  MapViewController.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreLocation


class MapViewController: UIViewController, ExperienceSavedDelegate {
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    private let regionInMeters: Double = 35000.0
    
    var experience: Experience? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //requestCameraPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    
    func currentUserLocation() -> CLLocationCoordinate2D {
        guard let currentLocation = locationManager.location?.coordinate else { return CLLocationCoordinate2D() }
        return currentLocation
    }
    
    
    private func requestVideoPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            guard isGranted else {
                preconditionFailure("Maybe create an alert later alerting to enable permissions for video.")
            }
        }
    }
    
    
    func updateViews() {
        
        
        guard let url = fileURL else { return }
              
              do {
                  let decoder = PropertyListDecoder()
                  let data = try Data(contentsOf: url)
                  print(data)
                  let experience = try decoder.decode(Experience.self, from: data)
                  
                  let coordinate = CLLocationCoordinate2D(latitude: experience.latitude, longitude: experience.longitude)
                  let annotation = MKPointAnnotation()
                  annotation.coordinate = coordinate
              
                  mapView.addAnnotation(annotation)
                  
              } catch {
                  print("Error decoding data: \(error)")
              }
    }
    
    
    
    func experienceSaved(url: URL?) {
        // Load from persistence
      
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewExperienceSegue" {
            guard let newExperienceVC = segue.destination as? NewExperienceViewController else { return }
            userLocation = currentUserLocation()
            newExperienceVC.userLocation = userLocation
            newExperienceVC.mapVC = self
            
        }
    }
}




extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        
        mapView.setRegion(region, animated: true)
    }
}

