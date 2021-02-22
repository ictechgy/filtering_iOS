//
//  QuasiDrug+CoreDataProperties.swift
//  
//
//  Created by JINHONG AN on 2021/02/03.
//
//

import Foundation
import CoreData


extension QuasiDrug {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuasiDrug> {
        return NSFetchRequest<QuasiDrug>(entityName: "QuasiDrug")
    }

    @NSManaged public var cancelCode: String?
    @NSManaged public var cancelDate: String?
    @NSManaged public var classNo: String?
    @NSManaged public var classNoName: String?
    @NSManaged public var eeDocData: Data?
    @NSManaged public var entpName: String?
    @NSManaged public var itemImage: Data?
    @NSManaged public var itemName: String?
    @NSManaged public var itemPermitDate: String?
    @NSManaged public var itemSeq: String?
    @NSManaged public var nbDocData: Data?
    @NSManaged public var udDocData: Data?

}
