//
//  Router.swift
//  Bamboo
//
//  Created by 박태현 on 2015. 12. 24..
//  Copyright © 2015년 ParkTaeHyun. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURL = NSURL(string: "http://ec2-52-68-50-114.ap-northeast-1.compute.amazonaws.com/bamboo/API")!
    
    case GetMyInfo(uuid: String)
    case GetMyPage(uuid: String, type: String)
    case GetDetail(bCode: String)
    case GetList(type: String, page: String, university: String, uuid: String)
    case GetKeywordList(uuid: String, keyword: String)
    case GetComment(uuid: String, bCode: String)
    case SetDefault(uuid: String, university: String)
    case SetUniversity(uuid: String, university: String)
    case SetComment(uuid: String, bCode: String, comment: String)
    case SetLike(uuid: String, bCode: String)
    case SetPoint(uuid: String)
    case SetPointReturn(uuid: String)
    case SetPost2(type: String, uuid: String,keyword: String ,contents: String, univ: String, notice: String)
    case GetHotKeyword()
    case GetUnivKeyword()
    case GetSearchKeyword(keyword: String)
    case UpdateDeviceToken(uuid: String, deviceToken: String)
    case SetCommentLike(uuid: String, idx: String)
    
    var URL: NSURL {
        return Router.baseURL.URLByAppendingPathComponent(route.path)
    }
    
    var route: (path: String, parameters: [String: AnyObject]?) {
        switch self {
        case .GetMyInfo(let uuid):
            return ("/Bamboo_Get_MyInfo.php", ["uuid": "\(uuid)"])
        case .GetMyPage(let uuid, let type):
            return ("/Bamboo_Get_MyPage.php", ["uuid": "\(uuid)", "type": "\(type)"])
        case .GetDetail(let bCode):
            return ("/Bamboo_Get_Detail.php", ["b_code": "\(bCode)"])
        case .GetList(let type, let page, let university, let uuid):
            return ("/Bamboo_Get_List.php", ["type": "\(type)", "page": "\(page)", "university": "\(university)", "uuid": "\(uuid)"])
        case .GetKeywordList(let uuid, let keyword):
            return ("/Bamboo_Get_Keyword_List.php", ["uuid": "\(uuid)", "keyword": "\(keyword)"])
        case .GetComment(let uuid, let bCode) :
            return ("/Bamboo_Get_Comment.php",["uuid": "\(uuid)", "b_code" : "\(bCode)"])
        case .SetDefault(let uuid, let university):
            return ("/Bamboo_Set_Default.php", ["uuid": "\(uuid)", "university": "\(university)"])
        case .SetUniversity(let uuid, let university):
            return ("/Bamboo_Set_University.php", ["uuid": "\(uuid)", "university": "\(university)"])
        case .SetComment(let uuid, let bCode, let comment):
            return ("/Bamboo_Set_Comment.php", ["uuid": "\(uuid)", "b_code": "\(bCode)", "comment": "\(comment)"])
        case .SetLike(let uuid, let bCode):
            return ("/Bamboo_Set_Like.php", ["uuid": "\(uuid)", "b_code": "\(bCode)"])
        case .SetPoint(let uuid):
            return ("/Bamboo_Set_Point.php", ["uuid": "\(uuid)"])
        case .SetPointReturn(let uuid):
            return ("/Bamboo_Set_Point_Return.php", ["uuid": "\(uuid)"])
        case .SetPost2(let type, let uuid, let keyword, let contents, let univ, let notice):
            return ("/Bamboo_Set_Post2.php", ["type": "\(type)", "uuid":"\(uuid)","keyword":"\(keyword)" ,"contents": "\(contents)","univ": "\(univ)", "notice": "\(notice)"])
        case .GetHotKeyword():
            return("/Bamboo_Get_HotKeyword.php", nil)
        case .GetUnivKeyword():
            return("/Bamboo_Get_UnivKeyword.php", nil)
        case .GetSearchKeyword(let keyword):
            return("/Bamboo_Get_SearchKeyword.php", ["keyword": "\(keyword)"])
        case .UpdateDeviceToken(let uuid, let deviceToken):
            return("/Bamboo_Update_DeviceToken.php", ["uuid": "\(uuid)", "deviceToken": "\(deviceToken)"])
        case .SetCommentLike(let uuid, let idx):
            return ("/Bamboo_Set_Comment_Like.php", ["uuid": "\(uuid)", "idx": "\(idx)"])
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        return Alamofire
            .ParameterEncoding
            .URL
            .encode(NSURLRequest(URL: URL), parameters: (route.parameters ?? [ : ])).0
    }
}
