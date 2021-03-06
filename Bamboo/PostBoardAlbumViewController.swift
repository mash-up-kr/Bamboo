//
//  PostBoardAlbumViewController.swift
//  Bamboo
//
//  Created by 박태현 on 2015. 12. 30..
//  Copyright © 2015년 ParkTaeHyun. All rights reserved.
//

import UIKit
import Photos

class PostBoardAlbumViewController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var smileImageView: UIImageView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var photos = [UIImage]()
    var selectedPhoto : UIImage?
    var totalPhotoCount = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingPhotos()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.catchIt(_:)), name: "myNotif", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func settingPhotos() {
        photos = []
        fetchPhotoAtIndexFromEnd(0)
    }
    
    func fetchPhotoAtIndexFromEnd(index:Int) {
        let imgManager = PHImageManager.defaultManager()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        if fetchResult.count > 0 {
            imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { image, _ in
                if let image = image {
                    self.photos.append(image)
                }
                if index + 1 < fetchResult.count && index < self.totalPhotoCount {
                    self.fetchPhotoAtIndexFromEnd(index + 1)
                } else {
                }
            })
        }
    }
    
    @IBAction func backButtonClicked(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SavePhoto" {
            if selectedPhoto == nil {
                let description = LibraryAPI.sharedInstance.ifNoSelectedPhoto()
                BBAlertView.alert(description.title, message: description.message)
                return false
            }else {
                return true
            }
        }
        return false
    }
}

extension PostBoardAlbumViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.photoImageViewCell.image = photos[indexPath.item]
        
        return cell
    }
}

extension PostBoardAlbumViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.smileImageView.hidden = true
        self.placeHolderLabel.hidden = true
        self.photoImageView.image = photos[indexPath.item]
        self.selectedPhoto = photos[indexPath.item]
    }
}