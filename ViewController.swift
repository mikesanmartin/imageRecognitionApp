//
//  ViewController.swift
//  MachineLearningPhotos
//
//  Created by Michel Emmanuel San Martin on 21/7/20.
//  Copyright © 2020 Michel Emmanuel San Martin. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detectarImagenes()
    }
    
    // Variables
    
    
    // IBOutlets
    
    @IBOutlet weak var dataImage: UIImageView!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    
    // IBActions
    
    @IBAction func tomarFoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("No se pudo obtener acceso a camara")
        }
        
    }
    
    @IBAction func seleccionarFoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("No se pudo obtener acceso a la libreria de fotos")
        }
    }
    
    // Functions
    
    func detectarImagenes() {
        dataLabel.text = "Cargando..."
        
        guard  let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            print("Ha ocurrido un error, no se pudo crear el modelo")
            return
        }
        
        let peticion = VNCoreMLRequest(model: model) { (request, error) in
            guard let resultados = request.results as? [VNClassificationObservation],
                let primerResultado = resultados.first else {
                    print("No se encontraron resultados")
                    return
        }
            DispatchQueue.main.async {
                self.dataLabel.text = "\(primerResultado.identifier) \(primerResultado.confidence * 100)%"
            }
 
        }
        
        guard let ciimageForUse = CIImage(image: self.dataImage.image!) else {
            print("No se ha podido crear la imagen CCImage a partir de un UIImage")
            return
        }
        
        // Correr peticion
        let handler = VNImageRequestHandler(ciImage: ciimageForUse)
        
        DispatchQueue.global().async {
            do {
                try handler.perform([peticion])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // System Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.dataImage.contentMode = .scaleAspectFill
            self.dataImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        detectarImagenes()
    }
    
}

