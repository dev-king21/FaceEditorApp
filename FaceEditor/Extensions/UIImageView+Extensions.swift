//
//  UIImageView.swift
//  FaceEditor
//
//  Created by Loyal Lauzier on 12/1/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

extension UIImageView {
func imageFrame()-> CGRect{
    let imageViewSize = self.frame.size

    guard let imageSize = self.image?.size else {return CGRect.zero}

    let imageRatio = imageSize.width / imageSize.height

    let imageViewRatio = imageViewSize.width / imageViewSize.height

    if imageRatio < imageViewRatio {
        contentScaleFactor = imageViewSize.height / imageSize.height
        let width = imageSize.width * contentScaleFactor
        let topLeftX = (imageViewSize.width - width) * 0.5

        return CGRect (x: topLeftX, y: 0, width: width, height: imageViewSize.height)
    }else{
        contentScaleFactor = imageViewSize.width / imageSize.width
        let height = imageSize.height * contentScaleFactor

        let topLeftY = (imageViewSize.height - height) * 0.5
        return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
    }
}
}
