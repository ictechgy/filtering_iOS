//
//  LicenseModel.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/21.
//

import Foundation
import UIKit.NSDataAsset

struct LicenseInfo: Codable {
    var title: String
    var contents: String
}

class LicenseModel {
    var list: [LicenseInfo]
    
    init?() {
        let jsonDecoder = JSONDecoder()
        
        guard let licenseData: NSDataAsset = NSDataAsset(name: "Licenses") else {
            return nil
        }
        
        do {
            self.list = try jsonDecoder.decode([LicenseInfo].self, from: licenseData.data)
        } catch {
            return nil
        }
    }
}
