//
//  BlemishViewController.swift
//  FaceEditor
//
//  Created by Loyal Lauzier on 11/27/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

import UIKit
import LGButton

class BlemishViewController: UIViewController, UIGestureRecognizerDelegate {


    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cancel: LGButton!
    @IBOutlet weak var done: LGButton!
    
    @IBOutlet weak var nav: UIView!
    @IBOutlet weak var slide: UIView!
    @IBOutlet weak var bSizeSlider: UISlider!
    
    @IBOutlet weak var maskWidth: NSLayoutConstraint!
    @IBOutlet weak var maskHeight: NSLayoutConstraint!
    
    var originalImg: UIImage!
    var changedImg: UIImage!
    var returnImg: UIImage!

    var p_scale: Double = 1.0
    var maskViewHeight : CGFloat!
    var imgScaledHeight : CGFloat!
    var imgScaledWidth : CGFloat!
    
    var bSizeValue : Double = 17.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImg = self.storedParam as! UIImage
        changedImg = originalImg
        imageView.image = changedImg
        
        if(originalImg.size.width >= originalImg.size.height) {
            
            maskWidth.constant = view.frame.width - 20
            maskHeight.constant = CGFloat(Int(originalImg.size.height * (view.frame.width - 20) / originalImg.size.width))
            
        } else {
            print(view.frame.height)
            print(maskView.height)
            maskHeight.constant = view.frame.height - 280
            maskWidth.constant = CGFloat(Int(originalImg.size.width * (view.frame.height-280) / originalImg.size.height))
            print(maskView.frame.height)
            print(nav.frame.height)
            print(slide.frame.height)
        }

        bSizeSlider.minimumValue = 4
        bSizeSlider.maximumValue = 30
        bSizeSlider.isContinuous = false
        bSizeSlider.setValue(17.0, animated: false)
        
    }
    
    @IBAction func handleTap(_ touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: self.imageView)
        let touchPointAbs = touch.location(in: self.maskView)
//        let w1 = (p_scale == 0.0 ) ? imageView.frame.width : imageView.frame.width / CGFloat(p_scale)
//        let h1 = (p_scale == 0.0 ) ? imageView.frame.height : imageView.frame.height / CGFloat(p_scale)
        let w1 = imageView.frame.width / CGFloat(p_scale)
        let h1 = imageView.frame.height / CGFloat(p_scale)

        let t_x = touchPoint.x
        let t_y = touchPoint.y
        
//        let rplRadius = (p_scale == 0.0 || p_scale == 1.0) ? bSizeValue : bSizeValue * p_scale
        print(p_scale, bSizeValue)
        print(imageView.frame, maskView.frame)
        print(t_x, t_y)
        var option = Ripple.option()
        
        option.borderWidth = CGFloat(2)
        option.radius = CGFloat(20)
        option.duration = CFTimeInterval(0.4)
        option.borderColor = UIColor.white
        option.fillColor = UIColor.clear
        option.scale = CGFloat(2)
        
        Ripple.run(view: maskView, locationInView: touchPointAbs, option: option)
        
        returnImg = imageView.image
        changedImg = OpenCVWrapper.blemish(returnImg, bsize: bSizeValue, x: Int32(Int(t_x)), y: Int32(Int(t_y)), w: Double(w1),h: Double(h1))
        imageView.image = changedImg
     
    }
    
    @IBAction func bSizeCurrentValue(_ sender: UISlider) {
        bSizeValue = Double(round(sender.value))
    }
    
    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        
        if let img = gesture.view as? UIImageView {
            
            switch gesture.state {

                case .changed:
                    let pinchCenter = CGPoint(x: gesture.location(in: img).x - img.bounds.midX,y: gesture.location(in: img).y - img.bounds.midY)
                    
                    if(img.frame.width <= maskView.frame.width || img.frame.height <= maskView.frame.height) {
                        img.transform = img.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                                       .scaledBy(x: gesture.scale, y: gesture.scale)
                                       .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                    }else{
                        let transform = img.transform.translatedBy(x: (img.frame.origin.x + img.frame.width <= maskView.frame.width) ? (maskView.frame.width - img.bounds.midX) : pinchCenter.x, y: (img.frame.origin.y + img.frame.height <= maskView.frame.height) ? (maskView.frame.height - img.bounds.midY) : pinchCenter.y)
                                            .scaledBy(x: gesture.scale, y: gesture.scale)
                                            .translatedBy(x: (img.frame.origin.x + img.frame.width <= maskView.frame.width) ?  -(maskView.frame.width - img.bounds.midX): -pinchCenter.x, y: (img.frame.origin.y + img.frame.height <= maskView.frame.height) ? -(maskView.frame.height - img.bounds.midY) : -pinchCenter.y)
                        img.transform = transform
                        if(img.frame.origin.x > 0){
                           img.frame.origin.x = 0
                        }
                        if(img.frame.origin.y > 0){
                           img.frame.origin.y = 0
                        }
                    }
            
                    gesture.scale = 1
                
                case .ended:
                    p_scale = Double(img.frame.width / img.bounds.width)
                    
                    if(img.frame.width < img.bounds.size.width || img.frame.height < img.bounds.size.height){
                        DispatchQueue.main.async {
//                            UIView.animate(withDuration: 0.5, animations: {
                                img.transform = CGAffineTransform.identity
                                img.frame.origin.x = 0
                                img.frame.origin.y = 0
                        }
                    }

                default:
                    return
                
            }
        }
    }

    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
   
        let translation = gesture.translation(in: imageView)
        var transX = translation.x;
        var transY = translation.y;
    
        guard let gestureView = gesture.view else {
            return
        }
        
        if (imageView.frame.width > maskView.frame.width || imageView.frame.height > maskView.frame.height) {
            if ( transX > 0) {
                if (imageView.frame.origin.x + transX >= 0 ) {
                    transX = -imageView.frame.origin.x;
                }
            } else {
                if (imageView.frame.origin.x + imageView.frame.width + transX < maskView.frame.width ) {
                    transX = maskView.frame.width - imageView.frame.origin.x - imageView.frame.width;
                }
            }
            
            if ( transY > 0) {
                if (imageView.frame.origin.y + transY >= 0 ) {
                    transY = -imageView.frame.origin.y;
                }
            } else {
                if (imageView.frame.origin.y + imageView.frame.height + transY < maskView.frame.height ) {
                    transY = maskView.frame.height - imageView.frame.origin.y - imageView.frame.height;
                }
            }
                        
        } else {
            if (imageView.frame.width + imageView.frame.origin.x + transX >= view.frame.width - 10 || (transX + imageView.frame.origin.x < 10)) {
                transX = 0;
            }
            
            if (imageView.frame.height + imageView.frame.origin.y + transY >= view.frame.height - 60 || (transY + imageView.frame.origin.y < 60)) {
                transY = 0;
            }
        }

      gestureView.center = CGPoint(
        x: gestureView.center.x + transX,
        y: gestureView.center.y + transY
      )

      gesture.setTranslation(.zero, in: view)
    }

    @IBAction func returnImg(_ sender: UIButton) {
        imageView.image = returnImg
    }
    
    @IBAction func cancelBtn(_ sender: LGButton) {
        print("cancel clicked")
        self.presentPage("ToolbarViewController", ToolbarViewController.self, param: self.originalImg)
      
    }
    
    @IBAction func doneBtn(_ sender: LGButton) {
        print("done clicked")
        self.presentPage("ToolbarViewController", ToolbarViewController.self, param: self.changedImg)
              
    }
}
