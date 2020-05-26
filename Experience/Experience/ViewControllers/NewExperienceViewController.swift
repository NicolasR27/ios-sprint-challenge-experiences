//
//  NewExperienceViewController.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins
import MapKit

class NewExperienceViewController: ShiftableViewController {
    
    //Properties:
    var mapVC: MapViewController?
    var userLocation: CLLocationCoordinate2D?
    
    private let context = CIContext()
    private let exposureAdjustFilter = CIFilter.exposureAdjust()
    private var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            
            var scaledSize = photoImageView.bounds.size
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            let scaledUIImage = selectedImage.imageByScaling(toSize: scaledSize)
            
            guard let scaledCGImage = scaledUIImage?.cgImage else { return }
            scaledImage = CIImage(cgImage: scaledCGImage)
            
        }
    }
    
    private var scaledImage: CIImage? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPosterButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If false, it'll show greyed out on the screen.
        recordButton.isEnabled = false
        titleTextField.delegate = self
    }
    
    func updateViews() {
        if let scaledImage = scaledImage {
            photoImageView.image = filterImage(for: scaledImage)
        } else {
            photoImageView.image = nil
        }
    }
    
    private func filterImage(for inputImage: CIImage) -> UIImage {
        exposureAdjustFilter.inputImage = inputImage
        exposureAdjustFilter.ev = Float(1.0)
        
        guard let outputImage = exposureAdjustFilter.outputImage else { return UIImage(ciImage: inputImage)}
        guard let renderedImage = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: UIImage(ciImage: inputImage).size)) else { return UIImage(ciImage: inputImage)}
        
        return UIImage(cgImage: renderedImage)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library.")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library you must allow us to access it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow us to access it")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the library. Your devices's restrictions do not allow access.")
        default:
            preconditionFailure("The app does not handle this new case provided by apple")
        }
        
        presentImagePickerController()
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        guard titleTextField.text != "" else {
            presentInformationalAlertController(title: "Error", message: "Cannot have text field empty")
            return
        }
        
        performSegue(withIdentifier: "GoToRecordersSegue", sender: self)
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            //Presenting the ViewController:
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToRecordersSegue" {
            guard let recordersVC = segue.destination as? RecordersViewController else { return }
            
            guard let title = titleTextField.text, let image = photoImageView.image, let imageData = image.jpegData(compressionQuality: 1.0), let userLocation = self.userLocation else { return }
            
           let experience = Experience(experienceTitle: title, geotag: userLocation, pictureData: imageData, videoUrl: nil, audioUrl: nil)
            
            recordersVC.experience = experience
            recordersVC.mapViewController = mapVC
        }
    }
}


extension NewExperienceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        addPosterButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        selectedImage = image
        recordButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
