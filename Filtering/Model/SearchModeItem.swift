//
//  SearchModeItem.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/31.
//

import UIKit

struct SearchModeItem {
    ///모드 구분 값 - eg. item_name, entp_name..
    var modeIdentifier: String
    ///모드명 - eg. 제품명, 업체명 등
    var modeName: String
    ///모드명 옆에 띄울 이미지 값
    var modeImage: UIImage?
}
