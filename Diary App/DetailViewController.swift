//
//  DetailViewController.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18.10.2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CanPickImage {

    let imagePickerController = UIImagePickerController()
    let locationManager = CLLocationManager.init()
    var entry: JournalEntry?
    var context: NSManagedObjectContext!
    var selectedImageData: Data?

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var dayRatingView: DayRatingView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {

        guard let entry = entry else{
            print("DetailViewController: No entry")
            return
        }
 
        dateLabel.text = entry.createdOnDate.toDiaryDateFormat()
        detailTextView.text = entry.text
        detailTextView.layer.cornerRadius = 5
        if let imageData = entry.imageData{
            if let image = UIImage.init(data: imageData){
                selectImageButton.setImage(image, for: .normal)
            }
        }
        selectImageButton.imageView?.contentMode = .scaleAspectFill
        selectImageButton.imageView?.layer.cornerRadius = self.selectImageButton.bounds.height / 2
        
        var dayRating: DayRating?
        if let dayRatingString = entry.dayRating{
            dayRating = DayRating(rawValue: dayRatingString)
            dayRatingView.rating = dayRating
        }
        dayRatingView.isHidden = dayRating == nil
        
        detailTextView.delegate = self
        imagePickerController.delegate = self
        textViewDidChange(detailTextView)
    }

    func textViewDidChange(_ textView: UITextView) {
        let numberOfCharacters = textView.text.characters.count
        characterCountLabel.text = "\(numberOfCharacters) / \(JournalEntry.maxLength)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + text.characters.count <= JournalEntry.maxLength
    }
    
    @IBAction func setDayRating(_ sender: Any) {
        if let button = sender as? UIButton, let title = button.titleLabel?.text{
            var dayRating = DayRating(rawValue: title)
            entry?.dayRating = dayRating?.rawValue
            dayRatingView.rating = dayRating
            dayRatingView.isHidden = dayRating == nil
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if let entry = entry, let newText = detailTextView.text{
            entry.text = newText
            if let imageData = self.selectedImageData{
                entry.imageData = imageData
            }
            entry.lastUpdatedDate = Date.init()
            context.saveChanges {
                Alert.showSaveDataError(context: self)
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteEntry(_ sender: Any) {
        if let entry = entry{
            context.delete(entry)
            context.saveChanges(errorHandler: {
                Alert.showSaveDataError(context: self)
            })
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func selectImage(_ sender: Any) {
        Alert.showImageSourceActionSheet(context: self)
    }
    
    // Fixes the 90 degree image rotation problem caused by UIImagePNGRepresentation function.
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            // Orient the selected image up
            let imageOrientedUp = fixOrientation(img: image)
            // Save the new photo to photo library
            if picker.sourceType == .camera{
                // Save new image taken by camera
                UIImageWriteToSavedPhotosAlbum(imageOrientedUp, nil, nil, nil)
            }
            // Resize the image
            let resizedImage = imageOrientedUp.convert(toSize:CGSize(width:100.0, height:100.0), scale: UIScreen.main.scale)
            selectImageButton.setImage(resizedImage, for: .normal)
            
            if let imageData = imageOrientedUp.pngData(){
                selectedImageData = imageData
            }
            dismiss(animated: true, completion: nil)
        }
        else{
            print("No image")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: CanPickImage
    func present(_ alert: UIAlertController){
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(){
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
