//
//  QuasiDrug+CoreDataProperties.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/21.
//
//

import Foundation
import CoreData


extension QuasiDrug {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuasiDrug> {
        return NSFetchRequest<QuasiDrug>(entityName: "QuasiDrug")
    }

    @NSManaged public var itemSeq: String?
    @NSManaged public var itemName: String?
    @NSManaged public var classNo: String?
    @NSManaged public var classNoName: String?
    @NSManaged public var entpName: String?
    @NSManaged public var itemPermitDate: String?
    @NSManaged public var cancelCode: String?
    @NSManaged public var cancelDate: String?
    @NSManaged public var eeDocData: Data?
    @NSManaged public var udDocData: Data?
    @NSManaged public var nbDocData: Data?

}

extension QuasiDrug : Identifiable {

}
