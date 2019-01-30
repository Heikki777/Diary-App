//
//  CanPickImage.swift
//  Diary App
//
//  Created by Sofia Digital on 27/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

protocol CanPickImage{
    func openPhotoLibrary() -> Void
    func openCamera() -> Void
    func present(_ alert: UIAlertController) -> Void
}
