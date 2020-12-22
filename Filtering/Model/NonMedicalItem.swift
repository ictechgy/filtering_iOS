//
//  nonMedicalItem.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

///검색 결과값에 대한 하나하나의 항목을 담을 구조체
struct NonMedicalItem {
    ///품목기준코드
    var itemSeq: String?
    
    ///품목명
    var itemName: String?
    
    ///효능효과
    var eeDocData: DocData?
    
    ///용법용량
    var udDocData: DocData?
    
    ///주의사항(일반)
    var nbDocData: DocData?
    
    ///품목코드
    var classNo: String?
    
    ///품목코드명
    var classNoName: String?
    
    ///업체명
    var entpName: String?
    
    ///허가일
    var itemPermitDate: String?
    
    ///인증상태 - 허가상태 여부(취소 됐는지, 안됐으면 정상)
    var cancelCode: String?
    
    ///취소됐다면 그 날짜
    var cancelDate: String?
    
    struct DocData: Codable {
        var title: DocType
        
        var articles: [Article]
        
        struct Article: Codable {
            var title: String
            var paragraphs: [String]
        }
    }
    
    enum DocType: String, Codable {
        case EE = "효능효과"
        case UD = "용법용령"
        case NB = "사용상의 주의사항"
    }
}
