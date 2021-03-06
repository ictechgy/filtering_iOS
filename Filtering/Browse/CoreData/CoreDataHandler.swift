//
//  CoreDataHandler.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/22.
//

import Foundation
import CoreData
import UIKit.UIImage

//AppDelegate.swift에 작성하지 않고 별도로 구현
class CoreDataHandler {
    static let shared: CoreDataHandler = CoreDataHandler()  //singletone
    private init() {}
    
    let modelName: String = "DataModel"
    var needToCheckData: Bool = true
    //즐겨찾기 목록 화면(FavoriteListVC)에서 데이터를 fetch해야 할지 말지 결정하게 해주는 프로퍼티
    //DB에 변경이 생긴 경우 true가 된다. 초기에는 데이터를 가져가야 하므로 기본값은 true
    
    //MARK:- Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer? = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                //error handling
                print(error.localizedDescription)
                self.persistentContainer = nil  //load 도중 실패시 container를 nil로 바꾸기
            }
        }
        
        //현재 QuasiDrug Entity의 Constraint를 itemSeq로 잡아놓았다.(기본키)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //만약 기존에 저장되어있던 것과 in-memory의 것이 충돌된다면 in-memory의 값으로 덮어씌운다.
        
        return container
    }()
    
    //MARK:- Core Data Saving support
    
    func saveContext() -> Bool {
        guard let context = persistentContainer?.viewContext else {
            return false    //저장하지 못함을 의미
        }
        if context.hasChanges {
            do {
                try context.save()
                return true //저장 성공
            } catch {
                //error handling
                let nsError = error as NSError
                print(nsError)
                return false
            }
        }else {
            return false
        }
    }
    
    //MARK:- Other
    var context: NSManagedObjectContext? {
        return self.persistentContainer?.viewContext
    }
    
    ///itemSeq를 넘겨받아 해당 아이템이 저장되어있는지 체크
    func isItemExist(itemSeq: String) -> Bool? {
        guard let context = self.context else {
            return nil      //확인 실패를 의미
        }
        
        let request: NSFetchRequest<QuasiDrug> = QuasiDrug.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(QuasiDrug.itemSeq), itemSeq)
        //특정 아이템만을 지칭하기 위해 NSPredicate 값을 세팅합니다. 
        request.predicate = predicate
        
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.count == 0 {
                return false    //존재하지 않습니다.
            }else {
                return true     //존재합니다.
            }
        } catch {
            print(error.localizedDescription)
            return nil          //실패
        }
    }
    
    /*
    Image를 어떻게 저장할 것인가.. 파일을 통째로 그냥 저장해서 쓸 것인지, 아니면 메타데이터를 이용하는 방식을 쓸 것인지
    Image를 Binary Data로 변환 해 CoreData에 저장할 수도 있고 파일 id값만 CoreData에 저장하고 이미지 자체는 파일시스템을 이용할 수도 있다. - 애플에서는 큰 파일(BLOB)의 경우 파일 시스템을 같이 이용할 것을 권하고 있다.
     - 참고 사이트
        1. https://jiseobkim.github.io/swift/2019/07/11/swift-File-Manager.html
        2. https://www.vadimbulavin.com/how-to-save-images-and-videos-to-core-data-efficiently/
        3. https://fluffy.es/store-image-coredata/
        
     처음에는 참고사이트 1처럼 구현할까 했었으나 참고 사이트 2번을 보니 External Storage를 같이 이용하는게 이미지 용량이 커질수록 더 빠르다고 하여 해당 방식으로 만들어보고자 한다. - 이미지 크기가 작으면 CoreData 자체에 저장하고 이미지 크기가 크면 FileSystem을 이용하는 방식 (크기에 대한 기준은 우리가 정하는것은 아님. 휴리스틱하게 CoreData가 알아서. iOS 5.0부터 지원) -
     */
    
    ///item을 넘겨받아 해당 아이템을 저장
    func insertItem(item: NonMedicalItem) -> Bool {
        //NSManagedObjectContext 가져오기
        guard let context = self.context else {
            return false    //저장 실패
        }
        
        //entity 가져오기
        let entity = NSEntityDescription.entity(forEntityName: "QuasiDrug", in: context)
        
        //NSManagedObject 만들기
        if let entity = entity {    //entity정보를 잘 가져왔다면
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            //object 값 세팅
            managedObject.setValue(item.itemSeq, forKey: #keyPath(QuasiDrug.itemSeq))
            managedObject.setValue(item.itemName, forKey: #keyPath(QuasiDrug.itemName))
            managedObject.setValue(item.classNo, forKey: #keyPath(QuasiDrug.classNo))
            managedObject.setValue(item.classNoName, forKey: #keyPath(QuasiDrug.classNoName))
            managedObject.setValue(item.entpName, forKey: #keyPath(QuasiDrug.entpName))
            managedObject.setValue(item.itemPermitDate, forKey: #keyPath(QuasiDrug.itemPermitDate))
            managedObject.setValue(item.cancelCode, forKey: #keyPath(QuasiDrug.cancelCode))
            managedObject.setValue(item.cancelDate, forKey: #keyPath(QuasiDrug.cancelDate))
            managedObject.setValue(item.itemImage?.pngData(), forKey: #keyPath(QuasiDrug.itemImage))
            
            let encoder = PropertyListEncoder()
            
            
            do {
                //struct들은 인코딩해서 넣기
                try managedObject.setValue(encoder.encode(item.eeDocData), forKey: #keyPath(QuasiDrug.eeDocData))
                try managedObject.setValue(encoder.encode(item.udDocData), forKey: #keyPath(QuasiDrug.udDocData))
                try managedObject.setValue(encoder.encode(item.nbDocData), forKey: #keyPath(QuasiDrug.nbDocData))
                
                //NSManagedObjectContext 저장
                try context.save()
                needToCheckData = true
            } catch {
                print(error.localizedDescription)
                return false    //error, 저장 실패
            }
            
            return true     //성공적으로 저장
        }else{
            return false    //entity 실패(저장 실패)
        }
    }
    
    ///itemSeq와 일치하는 키를 가진 릴레이션 인스턴스 삭제
    func deleteItem(itemSeq: String) -> Bool {
        guard let context = self.context else {
            return false    //삭제 실패
        }
        
        let request: NSFetchRequest<QuasiDrug> = QuasiDrug.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(QuasiDrug.itemSeq), itemSeq)
        
        do {
            let result = try context.fetch(request)
            if result.count == 1 {      //검색 결과가 정확히 하나만 나온 경우
                context.delete(result[0])
                
                try context.save()
                needToCheckData = true
                return true     //삭제 성공
            }else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    ///itemSeq와 일치하는 키를 가진 인스턴스들을 삭제
    func deleteItems(itemSeqs: [String]) -> Bool {
        guard let context = self.context else {
            return false
        }
        
        let request: NSFetchRequest<QuasiDrug> = QuasiDrug.fetchRequest()
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(QuasiDrug.itemSeq), itemSeqs)  //format 문자 대소문자에 주의하자.
        
        do {
            let result = try context.fetch(request)
            if result.count == itemSeqs.count {
                result.forEach {
                    context.delete($0)
                }
                try context.save()
                needToCheckData = true
                
                return true
            }else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    ///저장되어있는 모든 아이템 가져오기
    func fetchAllItems() -> [NonMedicalItem] {
        guard let context = self.context else {
            return []       //context 불러오기 실패
        }
        
        let request: NSFetchRequest<QuasiDrug> = QuasiDrug.fetchRequest()
        
        do {
            let result = try context.fetch(request) //모든 인스턴스 가져오기
            if result.count == 0 {
                return []       //하나도 없으면 바로 빈 배열 반환
                
            }
            
            var items: [NonMedicalItem] = []
            for drug in result {            //Quasi Drug을 NonMedicalItem으로 변환하는 for문
                var item: NonMedicalItem = NonMedicalItem()
                
                item.itemSeq = drug.itemSeq
                item.itemName = drug.itemName
                item.classNo = drug.classNo
                item.classNoName = drug.classNoName
                item.entpName = drug.entpName
                item.itemPermitDate = drug.itemPermitDate
                item.cancelCode = drug.cancelCode
                item.cancelDate = drug.cancelDate
                
                if let imageData = drug.itemImage { //저장된 이미지 데이터가 있다면 설정해주기
                    item.itemImage = UIImage(data: imageData)
                    item.isImageExist = item.itemImage != nil
                }
                
                let decoder = PropertyListDecoder()
                
                //인코딩되어있는 Attribute들은 디코딩하여 저장합니다.
                if let docData = drug.eeDocData {
                    item.eeDocData = try decoder.decode(NonMedicalItem.DocData.self, from: docData)
                }else {
                    item.eeDocData = nil
                }
                
                if let docData = drug.udDocData {
                    item.udDocData = try decoder.decode(NonMedicalItem.DocData.self, from: docData)
                }else {
                    item.udDocData = nil
                }
                
                if let docData = drug.nbDocData {
                    item.nbDocData = try decoder.decode(NonMedicalItem.DocData.self, from: docData)
                }else {
                    item.nbDocData = nil
                }
                
                items.append(item)
            }
            
            return items     //변환 완료 후 반환
        } catch {
            print(error.localizedDescription)
            return []       //에러 시 빈 배열 반환
        }
    }
    
    ///저장되어있는 아이템들의 개수를 반환합니다.
    func fetchAllItemsCount() -> Int {
        guard let context = self.context else {
            return -1
        }
        
        let request: NSFetchRequest<QuasiDrug> = QuasiDrug.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            return -2
        }
    }
    
    func deleteAllItems() -> Bool {
        guard let context = self.context else {
            return false
        }
        
        let request: NSFetchRequest<NSFetchRequestResult> = QuasiDrug.fetchRequest()
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)      //batchDelete - 한번에 삭제
        
        do {
            try context.execute(batchRequest)
            return true
        } catch {
            return false
        }
    
    }
}
