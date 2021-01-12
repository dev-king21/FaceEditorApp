//
//  ExampleViewController.swift
//  YPImagePickerExample
//
//  Created by Sacha DSO on 17/03/2017.
//  Copyright © 2017 Octopepper. All rights reserved.
//
import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos

class MainViewController: UIViewController {
    var selectedItems = [YPMediaItem]()

    let selectedImageV = UIImageView()

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        // print("\(CV2.openVersionString())")
        
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
            self.selectedItems = items
            let img:UIImage = items.singlePhoto!.image
            self.selectedImageV.image = items.singlePhoto?.image
            picker.dismiss(animated: true, completion: nil)
            self.presentPage("ToolbarViewController", ToolbarViewController.self, param: img)
        }

        present(picker, animated: true, completion: nil)
    }
}

// Support methods
extension MainViewController {
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
