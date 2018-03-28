//
//  UIImage+Extensions.swift
//  JuniorRoadRacer
//
//  Created by Tigran Hambardzumyan on 2/23/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit

extension UIImage {

    func aspectFill(width: CGFloat, height: CGFloat) -> UIImage? {
        if width > self.size.width * height / self.size.height {
            return resizeImage(newWidth: width)
        } else {
            return resizeImage(newHeight: height)
        }
    }

    func resizeImage(newHeight: CGFloat) -> UIImage? {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        return resizeImage(newWidth: newWidth, newHeight: newHeight)
    }

    func resizeImage(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        return resizeImage(newWidth: newWidth, newHeight: newHeight)
    }

    private func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

