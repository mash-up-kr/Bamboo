//
//  PostBoardViewController.swift
//  Bamboo
//
//  Created by 박태현 on 2015. 12. 28..
//  Copyright © 2015년 ParkTaeHyun. All rights reserved.
//

import UIKit
import Alamofire

class PostBoardViewController: UIViewController {
    
    //사진 imageView
    @IBOutlet weak var photoImageView: UIImageView!
    //게시글 TextView
    @IBOutlet weak var contentsTextView: UITextView!
    //"속마음을 표현해보세요" 레이블
    @IBOutlet weak var placeHolderLabel: UILabel!
    //키보드 위 사진및 확성기 게시기능을 할수 있는 View
    @IBOutlet weak var toolBoxView: UIView!
    //툴박스 확성기 버튼
    @IBOutlet weak var toolBoxNoticeButton: UIButton!
    //네비게이션 아이템
    @IBOutlet weak var postNavigationItem: UINavigationItem!
    @IBOutlet weak var containerImageView: UIImageView!
    @IBOutlet weak var smileImageView: UIImageView!
    
    //게시글 내용
    var contents: String = ""
    //페이지가 처음 로드되는지 판단
    var isFirstLoaded = true
    //일반글또는 대학글에서 누루는지 판단
    var type = ""
    //확성기 활성화 여부
    var isNotiveActivate = false
    var (postKeyword, postContents): (String, String) = ("","")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingNavigationItem()
        settingToolBoxNoticeButton()
        settingContentsTextView()
    }
    
    override func viewWillAppear(animated: Bool) {
        contentsTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Custom function
    func settingContentsTextView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostBoardViewController.keyWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        contentsTextView.becomeFirstResponder()
        contentsTextView.autocorrectionType = .No
    }
    
    func settingNavigationItem() {
        self.postNavigationItem.title = self.type
    }
    
    func settingToolBoxNoticeButton() {
        if self.type == "일반" {
            self.toolBoxNoticeButton.hidden = true
        }
    }
    
    func keyWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.toolBoxView.frame = CGRectMake(toolBoxView.frame.origin.x, toolBoxView.frame.origin.y + (keyboardSize.size.height * -1), toolBoxView.frame.size.width, toolBoxView.frame.size.height)
            }
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.catchIt(_:)), name: "myNotif", object: nil)
    }
    
    func setImageToPhotoImageView(image: UIImage) {
        self.containerImageView.hidden = true
        self.smileImageView.hidden = true
        self.photoImageView.image = image
    }
    
    func setPoint() {
        BBActivityIndicatorView.show("확성기를 활성화 하는 중입니다.")
        Alamofire
            .request(Router.SetPoint(uuid: User.sharedInstance().uuid))
            .responseJSON { response in
                if response.result.isSuccess {
                    self.setUser()
                    BBActivityIndicatorView.hide()
            }
        }
    }
    
    func setPointReturn() {
        BBActivityIndicatorView.show("확성기를 취소하는 중입니다.")
        Alamofire
            .request(Router.SetPointReturn(uuid: User.sharedInstance().uuid))
            .responseJSON { response in
                if response.result.isSuccess {
                    self.setUser()
                    BBActivityIndicatorView.hide()
                }
        }
    }
    
    func setUser() {
        let jsonParser = SimpleJsonParser()
        jsonParser.HTTPGetJson("http://ec2-52-68-50-114.ap-northeast-1.compute.amazonaws.com/bamboo/API/Bamboo_Get_MyInfo.php?uuid=\(User.sharedInstance().uuid)") {
            (data : Dictionary<String, AnyObject>, error : String?) -> Void in
            if error != nil {
                print("\(error) : PostBoardVC")
            } else {
                if let uuid = data["m_uuid"] as? String,
                    let point = data["m_point"] as? String,
                    let univ = data["m_univ"] as? String {
                        User.sharedInstance().uuid = uuid
                        User.sharedInstance().point = point
                        User.sharedInstance().univ = univ
                } else {
                    //print("User객체 SimpleJsonParser인스턴스 failed")
                }
            }
        }
        sleep(1)
        
        if isNotiveActivate == false {
            let description = LibraryAPI.sharedInstance.isSuccessPointReturn()
            BBAlertView.alert(description.title, message: description.message)
        }
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func requestWithImage(parameters: Dictionary<String, String>, imageData: NSData, isNotice: Bool) {
        let urlRequest = urlRequestWithComponents("http://ec2-52-68-50-114.ap-northeast-1.compute.amazonaws.com/bamboo/API/Bamboo_Set_Post.php", parameters: parameters, imageData: imageData)
        
        BBActivityIndicatorView.show("개시중입니다")
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                debugPrint(response)
                if response.result.isSuccess {
                    BBActivityIndicatorView.hide()
                    let descriptions = LibraryAPI.sharedInstance.isSuccessPost()
                    BBAlertView.alert(descriptions.title, message: descriptions.message, buttons: descriptions.buttons, tapBlock: {(alertAction, position) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    let descriptions = LibraryAPI.sharedInstance.isFailToPost()
                    BBAlertView.alert(descriptions.title, message: descriptions.message)
                }
        }
    }
    
    func requestWithNoImage(type: String) {
        var notice = ""
        if self.isNotiveActivate {notice = "Y"} else {notice = "N"}
        
        BBActivityIndicatorView.show("개시중입니다")
        Alamofire
            .request(Router.SetPost2(type: type, uuid: User.sharedInstance().uuid,keyword: self.postKeyword, contents: self.postContents, univ: User.sharedInstance().univ, notice: notice))
            .responseString { response in
                debugPrint(response)
                if response.result.isSuccess {
                    BBActivityIndicatorView.hide()
                    let descriptions = LibraryAPI.sharedInstance.isSuccessPost()
                    BBAlertView.alert(descriptions.title, message: descriptions.message, buttons: descriptions.buttons, tapBlock: {(alertAction, position) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    let descriptions = LibraryAPI.sharedInstance.isFailToPost()
                    BBAlertView.alert(descriptions.title, message: descriptions.message)
                }
        }
    }
    
    // MARK: - IBAction function
    @IBAction func closeButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func toolBoxCameraButtonClicked(sender: UIButton) {
        self.isFirstLoaded = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func toolBoxNoticeButtonClicked(sender: UIButton) {
        if isNotiveActivate == false {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            let descriptions = LibraryAPI.sharedInstance.clickNoticeButton(point: User.sharedInstance().point)
    
            BBAlertView.alert(descriptions.title, message: descriptions.message, buttons: descriptions.buttons, tapBlock: {(alertAction, position) -> Void in
                if position == 1 {
                    if Int(User.sharedInstance().point) < 10 {
                        let descriptions = LibraryAPI.sharedInstance.ifLessPointThan10()
                        BBAlertView.alert(descriptions.title, message: descriptions.message)
                    } else {
                        self.isNotiveActivate = true
                        self.toolBoxNoticeButton.setImage(UIImage(named: "notive_active"), forState: UIControlState.Normal)
                        self.setPoint()
                        self.setUser()
                    }
                }
            })
        } else {
            self.isNotiveActivate = false
            self.toolBoxNoticeButton.setImage(UIImage(named: "keyboard_notice"), forState: UIControlState.Normal)
            self.setPointReturn()
        }
    }
    
    @IBAction func toolBoxPostButtonClicked(sender: UIButton) {
        if contentsTextView.text == "" {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            let description = LibraryAPI.sharedInstance.isEmptyPostContentsTextFiled()
            BBAlertView.alert(description.title, message: description.message)
        } else {
            (postKeyword, postContents) = LibraryAPI.sharedInstance.getKeywordAndContentsFromString(originString: self.contentsTextView.text)
            // General board post
            if self.type == "일반" {
                // 이미지가 있을때
                if let image = self.photoImageView.image {
                    let parameters: Dictionary<String, String> = [
                        "type" : "T01",
                        "uuid" : User.sharedInstance().uuid,
                        "keyword" : postKeyword,
                        "contents" : postContents
                    ]
                    let imageData = UIImageJPEGRepresentation(image, 0.0)
                    requestWithImage(parameters, imageData: imageData!, isNotice: false)
                    // 이미지가 없을때
                } else {
                    requestWithNoImage("T01")
                }
                // Univ board post
            } else {
                // 이미지가 있을때
                if let image = self.photoImageView.image {
                    var notice = ""
                    // 확성기 활성화시
                    if isNotiveActivate {
                        notice = "Y"
                        // 활성기 비활성화시
                    } else {notice = "N"}
                    let parameters: Dictionary<String, String> = [
                        "type" : "T02",
                        "uuid" : User.sharedInstance().uuid,
                        "keyword" : postKeyword,
                        "contents" : postContents,
                        "notice": notice,
                        "univ" : User.sharedInstance().univ
                    ]
                    let imageData = UIImageJPEGRepresentation(image, 0.0)
                    requestWithImage(parameters, imageData: imageData!, isNotice: false)
                    // 이미지가 없을때
                } else {
                    requestWithNoImage("T02")
                }
            }
        }
    }
    
    @IBAction func savePhotoFromPostBoardAlbumVC(segue: UIStoryboardSegue) {
        let postBoardAlbumVC = segue.sourceViewController as! PostBoardAlbumViewController
        setImageToPhotoImageView(postBoardAlbumVC.selectedPhoto!)
    }
    
    @IBAction func savePhotoFromPostBoardCameraVC(segue: UIStoryboardSegue) {
        let postBoardCameraVC = segue.sourceViewController as! PostBoardCameraViewController
        
        if let photoImage = postBoardCameraVC.capturedPhoto {
            setImageToPhotoImageView(photoImage)
        }
    }
}

extension PostBoardViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        contents = contentsTextView.text
        if contents != "" {
            placeHolderLabel.hidden = true
        } else {
            placeHolderLabel.hidden = false
        }
    }
}