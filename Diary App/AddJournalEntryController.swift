//
//  AddJournalEntryController.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Photos
import PhotosUI

class AddJournalEntryController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, CanPickImage {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var dayRatingView: DayRatingView!
    @IBOutlet weak var entryTableView: UITableView!
    @IBOutlet weak var compassImageView: UIImageView!
    
    var managedObjectContext: NSManagedObjectContext!
    let imagePickerController = UIImagePickerController()
    
    var entries = [JournalEntry](){
        didSet{
            entryTableView.reloadData()
        }
    }
    
    var currentLocation: CLLocation? {
        didSet{
            guard let currentLocation = currentLocation else { return }
            
            geocoder.reverseGeocodeLocation(currentLocation){ placemarks, error in
                
                if let error = error{
                    print("Error: Location not found: \(error.localizedDescription)")
                    return
                }
                
                if let place = placemarks?.first {
                    if let locality = place.locality, let name = place.name {
                        self.locationString = "\(name), \(locality)"
                    }
                }
            }
        }
    }
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        return locationManager
    }()
    
    lazy var geocoder: CLGeocoder = {
        return CLGeocoder.init()
    }()
    
    var locationString: String?{
        didSet{
            locationLabel.text = locationString
            locationLabel.isHidden = locationString == nil
            compassImageView.isHidden = locationString == nil
        }
    }
    
    lazy var tableViewDataSource: DataSource = {
        return DataSource(tableView: self.entryTableView, context: self.managedObjectContext, viewController: self)
    }()
    
    var selectedImageData: Data?
    var selectedDayRating: DayRating?{
        didSet{
            self.dayRatingView.rating = selectedDayRating
            self.dayRatingView.isHidden = selectedDayRating == nil
        }
    }
    
    deinit {
        selectedImageData = nil
        selectedDayRating = nil
        locationString = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 5
        self.imagePickerController.delegate = self
        self.selectImageButton.imageView?.contentMode = .scaleAspectFill
        self.selectImageButton.imageView?.layer.cornerRadius = self.selectImageButton.bounds.height / 2
        self.selectedDayRating = nil
        self.entryTableView.dataSource = tableViewDataSource
        self.locationLabel.isHidden = locationString == nil
        self.compassImageView.isHidden = locationString == nil
        self.locationManager.requestLocation()
    }
    
    @IBAction func setDayRating(_ sender: Any) {
        if let button = sender as? UIButton, let title = button.titleLabel?.text{
            selectedDayRating = DayRating(rawValue: title)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
        guard let text = textView.text, !text.isEmpty else{
            return
        }
        
        if let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: managedObjectContext) as? JournalEntry{
            entry.text = text
            entry.createdOnDate = Date.init()
            entry.lastUpdatedDate = Date.init()
            entry.location = locationString
            entry.imageData = selectedImageData
            entry.dayRating = selectedDayRating?.rawValue
        }

        managedObjectContext.saveChanges(errorHandler: {
            Alert.showSaveDataError(context: self)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectImage(_ sender: Any) {
        Alert.showImageSourceActionSheet(context: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let numberOfCharacters = textView.text.count
        characterCountLabel.text = "\(numberOfCharacters) / \(JournalEntry.maxLength)"
        
        // Attributed text
        let text = textView.text
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        let attributedText = NSAttributedString(string: text!, attributes: attributes)
        
        // set attributed text on a UILabel
        textView.attributedText = attributedText
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + text.count <= JournalEntry.maxLength
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: CanPickImage
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
    
    func present(_ alert: UIAlertController){
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIImage
{
    // convenience function in UIImage extension to resize a given image
    func convert(toSize size:CGSize, scale:CGFloat) ->UIImage
    {
        let imgRect = CGRect(origin: CGPoint(x:0.0, y:0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: imgRect)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copied!
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
