//
//  MaskItem.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/06.
//

import Foundation

///마스크 아이템만을 담을 구조체
struct MaskItem {
    
    ///품목기준코드
    var itemSeq: String
    
    ///품목명
    var itemName: String
    
    ///모델명
    var modelName: String?
    
    ///업체명
    var entpName: String
    
    ///등급
    var grade: Grade
    
    ///구분
    var classification: MaskType
    
    enum Grade: String, Codable {
        case kf94 = "KF94"
        case kf80 = "KF80"
        case undefined
    }
    
    enum MaskType: String, Codable {
        case healthMask = "보건용 마스크"
        case surgicalMask = "수술용 마스크"
        case splashMask = "비말차단용 마스크"
        case undefined
    }
}
