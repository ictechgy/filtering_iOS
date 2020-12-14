//
//  nonMedicalItem.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

///검색 결과값에 대한 하나하나의 항목을 담을 구조체
struct NonMedicalItem {
    var itemSeq: String?
    var itemName: String?
    
    var eeDocData: docData?
    var udDocData: docData?
    var nbDocData: docData?
    
    struct docData {
        var title: docType
        
        var articles: [article]
        
        struct article {
            var title: String
            var paragraphs: [String]
        }
    }
    
    enum docType: String {
        case EE = "효능효과"
        case UD = "용법용령"
        case NB = "사용상의 주의사항"
    }
}
