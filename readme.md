# SeeFood

![app-screenshot](https://raw.githubusercontent.com/kawgh1/seefood/main/2.jpeg)

## Image Recognition App
- Uses CoreML, Vision and allows user to either take a photo from library or use the camera to take a picture, run it through the Inception v3 model and the app will tell the user what it thinks the image is of with a Confidence Score as a percent

### Main Code

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
