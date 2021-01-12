//
//  ViewExtension.swift
//  JaegarTech
//
//  Created by jsec1912 on 8/30/19.
//  Copyright © 2019 JaegarTech Sdn Bhd. All rights reserved.
//

import UIKit

public extension UIView {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color, toSide: "Top")
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color, toSide: "Bottom")
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color, toSide: "Left")
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color, toSide: "Right")
    }
    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor, toSide: String) {
        let border = CALayer()
        border.name = toSide
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    
    func removeBorder(_ toSide: String) {
        guard let sublayers = layer.sublayers else { return }
        var layerForRemove: CALayer?
        for layer in sublayers {
            if layer.name == toSide {
                layerForRemove = layer
            }
        }
        if let layer = layerForRemove {
            layer.removeFromSuperlayer()
        }
    }
    
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 2
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

public extension UIViewController {
    struct Holder {
        static let storyboard = UIStoryboard(name: "Main", bundle: nil)
        static let appDelegate = UIApplication.shared.delegate as! AppDelegate
        static var _storedParam: NSObject!
    }
    
    var storedParam: NSObject {
        get {
            return Holder._storedParam
        }
        set(newValue) {
            Holder._storedParam = newValue
        }
    }
    
    func goPage(controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func presentPage<T: UIViewController>(_ storyId: String, _ controller: T.Type) {
        let controller = Holder.storyboard.instantiateViewController(withIdentifier: storyId) as! T
        Holder.appDelegate.window?.rootViewController = controller
    }
    
    func presentPage<T: UIViewController>(_ storyId: String, _ controller: T.Type, param: NSObject) {
        let controller = Holder.storyboard.instantiateViewController(withIdentifier: storyId) as! T
        controller.storedParam = param
        Holder.appDelegate.window?.rootViewController = controller
    }
    
}

public extension UITextField {
    func setBottomBorder () {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
}

extension UILabel {
    public var substituteFontName : String {
        get {
            return self.font.fontName
        }
        set {
            let fontNameToTest = self.font.fontName.lowercased()
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraIta"
            } else {
                fontName += "-Book"
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
}

extension UITextView {
    public var substituteFontName : String {
        get {
            return self.font?.fontName ?? ""
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? ""
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraIta"
            } else {
                fontName += "-Book"
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}

extension UITextField {
    public var substituteFontName : String {
        get {
            return self.font?.fontName ?? ""
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? ""
            var fontName = newValue
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold"
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium"
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light"
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraIta"
            } else {
                fontName += "-Book"
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}

