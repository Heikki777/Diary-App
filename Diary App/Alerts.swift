//
//  Alerts.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 27/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

class Alert{

    static func showSaveDataError(context: UIViewController){
        let alert = UIAlertController.init(title: "Error!", message: "The changes could not be saved", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        context.present(alert, animated: true, completion: nil)
    }
    
    static func showImageSourceActionSheet(context: CanPickImage){
        
        let alert = UIAlertController(title: "Select image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            context.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {_ in
            context.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        context.present(alert)
    }
    
}
