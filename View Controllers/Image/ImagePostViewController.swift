//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        setViewsForFilter()
        
        guard imageView.image == nil else { return }
        
        addFilterButton.isHidden = true
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        let completion: (Bool) -> Void = { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }

        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio, completion: completion)
        
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
        default:
            break
        }
        presentImagePickerController()
    }
    
    @IBAction func addFilter(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a filter", message: nil, preferredStyle: .actionSheet)
        
        let fadeAction = UIAlertAction(title: "Fade", style: .default) { (_) in
            self.filterImage(withFilter: .fade)
            self.setViewsForFilter()
        }
        
        let exposureAdjustAction = UIAlertAction(title: "Exposure", style: .default) { (_) in
            self.filterImage(withFilter: .exposure, parameters: [kCIInputEVKey: 0.0])
            self.setViewsForFilter()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(fadeAction)
        alert.addAction(exposureAdjustAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    var currentFilter: ImageFilter = .none
    
    enum ImageFilter: String {
        case fade = "CIPhotoEffectFade"
        case exposure = "CIExposureAdjust"
        case none
        
        static var allFilters: [ImageFilter] = [.fade]
    }
    
    func setViewsForFilter() {
        
        switch currentFilter {
        case .fade, .none:
            filterLabel.isHidden = true
            filterSlider.isHidden = true
        case .exposure:
            
            
            filterLabel.isHidden = false
            filterSlider.isHidden = false
            
            filterSlider.minimumValue = -2.5
            let value = CGFloat((filterSlider.value * 1000).rounded() / 1000)
            
            filterLabel.text = "Exposure: \(value) EV"
            
            filterSlider.maximumValue = 2.5
            
        }
    }
    
    @IBAction func adjustFilter(_ sender: Any) {
        
        switch currentFilter {
        case .exposure:
            let value = CGFloat(filterSlider.value)
            filterImage(withFilter: .exposure, parameters: [kCIInputEVKey: value])
            setViewsForFilter()
        default:
            break
        }
    }
    
    func filterImage(withFilter filter: ImageFilter, parameters: [String: CGFloat] = [:]) {
        
        guard let image = originalImage else { return }
        
        if let imageFilter = CIFilter(name: filter.rawValue) {
            
            let startImage = CIImage(image: image)
            imageFilter.setValue(startImage, forKey: kCIInputImageKey)
            
            for (key, value) in parameters {
                imageFilter.setValue(value, forKey: key)
            }
            
            guard let outputImage = imageFilter.outputImage,
                let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
            
            let image = UIImage(cgImage: cgImage)
            
            imageView.image = image
            
            currentFilter = filter
        }
    }
    
    let context = CIContext(options: nil)
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var originalImage: UIImage?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addFilterButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSlider: UISlider!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
        addFilterButton.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
