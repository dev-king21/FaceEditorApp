//
//  ToolbarViewController.swift
//  FaceEditor
//
//  Created by Loyal Lauzier on 11/11/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

import UIKit
import YPImagePicker
import LGButton
import Combine
import AVFoundation
import AVKit
import SwiftIconFont
import YUCIHighPassSkinSmoothing

class ToolbarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    @IBOutlet weak var toolbarListView: UICollectionView!

    @IBOutlet weak var imageView: UIImageView!
    
    var toolbarList = [ToolbarItem]()
    var selectedItems = [YPMediaItem]()
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var actionNavbar: UIView!
    @IBOutlet weak var mainNavbar: UIView!
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var toolbarCollectionView: UICollectionView!
    
    @IBOutlet weak var browseBtn: LGButton!
    @IBOutlet weak var cancelBtn: LGButton!
    @IBOutlet weak var doneBtn: LGButton!
    @IBOutlet weak var saveBtn: LGButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getToolbarList()
        toolbarListView.dataSource = self
        toolbarListView.delegate = self
        actionNavbar.isHidden = true
        slideView.isHidden = true
        imageView.image = self.storedParam as! UIImage
        
    }
    
    func getToolbarList() {
        toolbarList = [
            ToolbarItem(imageIcon: "edit", name: "Blemish"),
            ToolbarItem(imageIcon: "crop", name: "Crop"),
            ToolbarItem(imageIcon: "format-color-fill", name: "Blur"),
            ToolbarItem(imageIcon: "find-replace", name: "Whiten"),
            ToolbarItem(imageIcon: "filter", name: "Filter"),
            ToolbarItem(imageIcon: "filter-frames", name: "Frame"),
        ]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        toolbarList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell:ToolbarItemCell = self.toolbarListView!.dequeueReusableCell(withReuseIdentifier: "toolbarItem", for: indexPath) as! ToolbarItemCell
        let toolbar = toolbarList[indexPath.row]
       
        cell.toolbarName.text = toolbar.name
        cell.toolbarName.tintColor = UIColor.green
        cell.imageIcon.setIcon(from: .materialIcon, code: toolbar.imageIcon, textColor: .white, backgroundColor: .clear)
     
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * CGFloat(6)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(5)
        let height = collectionView.frame.height - 2 * sectionInsets.top
        
        return CGSize(width: widthPerItem, height: height)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    @IBOutlet weak var customIndicator: UIActivityIndicatorView!
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let toolbarSelectList = toolbarList[indexPath.row]

        print(toolbarSelectList.name)
//        let indicator = customIndicator(at: self.view.center)
//              self.view.addSubview(customIndicator)
//              customIndicator.startAnimating()
        mainNavbar.isHidden = true
        toolbarCollectionView.isHidden = true
        switch(toolbarSelectList.name){
            case "Blemish":
                self.presentPage("SkinSmoothingViewController", SkinSmoothingViewController.self, param: imageView.image!)
            default: return
        }
    }
    
    @IBAction func browseClick(_ sender: Any) {
        var config = YPImagePickerConfiguration()
              config.library.mediaType = .photoAndVideo
              config.shouldSaveNewPicturesToAlbum = false
              config.showsPhotoFilters = false
              config.video.compression = AVAssetExportPresetMediumQuality
              config.startOnScreen = .library
              config.screens = [.library, .photo]
              config.video.libraryTimeLimit = 500.0
              config.wordings.libraryTitle = "Gallery"
              config.hidesStatusBar = false
              config.hidesBottomBar = false
              config.library.maxNumberOfItems = 5
              config.library.preselectedItems = selectedItems
              
              let picker = YPImagePicker(configuration: config)
          
              picker.didFinishPicking { [unowned picker] items, _ in
                  let img:UIImage = items.singlePhoto!.image
                  picker.dismiss(animated: true, completion: nil)
                  self.presentPage("ToolbarViewController", ToolbarViewController.self, param: img)
              }
        

              present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveClick(_ sender: Any) {
        ImageSaver().writeToPhotoAlbum(image: imageView.image!)
        print("save")
    }
    
//         imageView.image = self.storedParam as! UIImage
//        var image: UIImage = imageView.image{
//            if let data = image.pngData() {
//                let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
//                try? data.write(to: filename)
//            }
//        }
    }

    

class ToolbarItem {
    
    var imageIcon: String = ""
    var name: String = ""
    
    init(imageIcon: String, name: String) {
        self.name = name
        self.imageIcon = imageIcon
    }
    
}

class ToolbarItemCell : UICollectionViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var toolbarName: UILabel!
}

class ImageSaver: NSObject {
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
            print("Oops: \(error.localizedDescription)")
        } else {
            successHandler?()
            print("Success!")
        }
    }
}

