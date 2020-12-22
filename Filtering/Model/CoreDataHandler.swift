//
//  CoreDataHandler.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/22.
//

import Foundation
import CoreData

//AppDelegate.swift에 작성하지 않고 별도로 구현
class CoreDataHandler {
    static let shared: CoreDataHandler = CoreDataHandler()  //singletone
    private init() {}
    
    //MARK:- Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                //error handling
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    //MARK:- Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                //error handling
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
