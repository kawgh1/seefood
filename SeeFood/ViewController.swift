//
//  ViewController.swift
//  SeeFood
//
//  Created by J on 5/13/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    let imagePicker = UIImagePickerController()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SeeFood"
 
        imagePicker.delegate = self
      
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userSelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userSelectedImage
            
            guard let ciimage = CIImage(image: userSelectedImage) else {
                fatalError("Could not convert UIImage to CIImage...")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
       
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed...")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Could not convert results into VNClassicationObservations. Model failed to process image.")
            }
            print("Results 1-5:  ", results[0...4])
            
            if let firstResult = results.first {
               
                self.resultsLabel.text = firstResult.identifier
                
                let stringToDouble = Double(firstResult.confidence)
                let intNumber = self.determineConfidenceColor(number: stringToDouble)
                
                self.percentLabel.text = String(intNumber) + "%"
            } else {
                self.resultsLabel.text = ""
                self.percentLabel.text = ""
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
            do {
                try handler.perform([request])
            } catch {
                print("Error: ", error)
            }
        
        
    }
    
    func determineConfidenceColor(number: Double) -> Int {
                
        let doubleNumber = number * 100.0
        let  intNumber = Int(doubleNumber)
        
        if(intNumber > 90) {
            self.percentLabel.textColor = UIColor.systemGreen
        } else if (intNumber > 70) {
            self.percentLabel.textColor = UIColor.systemYellow
        } else {
            self.percentLabel.textColor = UIColor.systemRed
        }
        return intNumber
    }
    
    
    
    @IBAction func photoPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

