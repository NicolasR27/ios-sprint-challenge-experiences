//
//  ImageAudioViewController.swift
//  Experiences
//
//  Created by Nicolas Rios on 5/17/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit
import AVFoundation

class ImageAudioViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var experienceTitleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var audioRecorderButton: UIButton!
    
    //MARK: Properties
    var experienceController: ExperienceController?
    var originalImage: UIImage? {
        didSet {
            self.updateImage()
        }
    }
    var imageData: Data?
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CISepiaTone")!
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    //MARK: Actions
    
   
    @IBAction func uploadImageButtonTapped(_ sender: UIButton) {
        self.presentImagePickerController()
    }
    
    
    @IBAction func audioRecorderButtonTapped(_ sender: UIButton) {
        defer { updateRecordingButton() }
        
        guard !isRecording else {
            audioRecorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            audioRecorder = try AVAudioRecorder(url: self.newAudioRecordingURL(), format: format)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error)")
            return
        }
    }
    
    //MARK: Methods
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { NSLog("The photo library is not available"); return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateImage() {
        if let img = self.originalImage {
            imageView.image = self.image(byFiltering: img)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Set the values of the filter's parameters
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.10, forKey: kCIInputIntensityKey)
        
        // The metadata to be processed. NOT the actual filtered image
        guard let outputCIImage = filter.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        let filteredImage = UIImage(cgImage: outputCGImage)
        
        let imageData = filteredImage.jpegData(compressionQuality: 1)!
        self.imageData = imageData
                
        return filteredImage
    }
    
    private func updateRecordingButton() {
            let recordButtonTitle = self.isRecording ? "Stop Recording" : "Record"
            self.audioRecorderButton.setTitle(recordButtonTitle, for: .normal)
    }
    
    private func newAudioRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDirectory = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageAudioViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            self.originalImage = img
        }
        
        self.imageUploadButton.isHidden = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImageAudioViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingURL = recorder.url
        self.audioRecorder = nil
        self.updateRecordingButton()
    }
}
