//
//  RecorderViewController.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit


// Persistence file url
var fileURL: URL? {
    let manager = FileManager.default
    guard let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let fileURL = documentDir.appendingPathComponent("list.plist")
    return fileURL
}


protocol ExperienceSavedDelegate: NSObject {
    func experienceSaved(url: URL?)
}



class RecordersViewController: UIViewController {
    
    var mapViewController: MapViewController?
    var userLocation: CLLocationCoordinate2D?
    var pictureData: Data?
    var audioRecorder: AVAudioRecorder?
    var experience: Experience?
    var recordingURL: URL?
    weak var delegate: ExperienceSavedDelegate?
    
    @IBOutlet weak var recordAudioOutlet: UIButton!
    @IBOutlet weak var recordVideoOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordAudioOutlet.layer.cornerRadius = 20
        recordAudioOutlet.layer.borderColor = UIColor.black.cgColor
        recordAudioOutlet.layer.borderWidth = 1
        recordVideoOutlet.isEnabled = false
        recordVideoOutlet.alpha = 0.5
        
    }
    
    @IBAction func startStopRecording(_ sender: Any) {
        if recordAudioOutlet.isSelected {
            recordAudioOutlet.isSelected = false
            stopRecording()
        } else {
            recordAudioOutlet.isSelected = true
            requestPermissionForRecording()
        }
    }
    
    @IBAction func startRecordingVideo(_ sender: Any) {
        guard recordingURL != nil else { return }
        performSegue(withIdentifier: "RecordVideoSegue", sender: self)
    }
    
    func createAudioMessageURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        print("Recording URL: \(file)")
        
        return file
    }
    
    func requestPermissionForRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                guard granted == true else {
                    print("We need the mic access please.")
                    return
                }
                
                print("Recording permission has been granted.")
                self.startRecording()
            }
            
        case .denied:
            print("Mic access has been blocked.")
            
            let alert = UIAlertController(title: "Mic access denied", message: "Please allow app to access the microphone", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        case .granted:
            startRecording()
            
        @unknown default:
            break
        }
    }
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot Record audio: \(error.localizedDescription)")
            return
        }
        
        recordingURL = createAudioMessageURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.record()
        } catch {
            preconditionFailure("The audio recorder could not be created with: \(recordingURL) and \(format)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordVideoOutlet.isEnabled = true
        
        experience?.audioUrl = self.recordingURL?.absoluteString
        saveToPersistence()
        delegate?.experienceSaved(url: fileURL)

    }

    
    // Save to persistence
    func saveToPersistence() {
        guard let url = fileURL else {  return }
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(experience)
            try data.write(to: url)
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // Can fail on a phone call
    }
    
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideoSegue" {
            guard let videoVC = segue.destination as? VideoRecordingViewController else { return }
            guard let recordingURL = recordingURL else { return }
            videoVC.picture = self.pictureData
            videoVC.experienceTitle = title
            videoVC.recordingURL = recordingURL.absoluteString
            videoVC.userLocation = userLocation
            videoVC.mapViewController = mapViewController
        }
    }
}
