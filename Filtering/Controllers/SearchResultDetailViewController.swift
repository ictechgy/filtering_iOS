//
//  SearchResultDetailViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit
import CoreData

class SearchResultDetailViewController: UIViewController {
    
    ///이전 화면(SearchResultViewController)에서 넘겨받은 아이템 객체
    var item: NonMedicalItem!
    let notApplicable: String = "N/A"
    
    var isAddedToFavorites: Bool = false    //즐겨찾기에 추가되어있는지
    
    lazy var addToFavoritesButton: UIBarButtonItem = {
        var iconImage: UIImage
        if isAddedToFavorites {
            iconImage = UIImage(systemName: "star.fill")!
        }else {
            iconImage = UIImage(systemName: "star")!
        }
        let button = UIBarButtonItem(image: iconImage, style: .plain, target: self, action: #selector(favoritesButtonTapped(_:)))
        return button
    }()
    
    @IBOutlet weak var itemSeq: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var classNo: UILabel!
    @IBOutlet weak var classNoName: UILabel!
    @IBOutlet weak var entpName: UILabel!
    @IBOutlet weak var itemPermitDate: UILabel!
    @IBOutlet weak var cancelCode: UILabel!
    @IBOutlet weak var cancelDate: UILabel!
    
    @IBOutlet weak var segmentedContent: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상세 조회"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setItemInfo()
        setSegViewContent(index: 0)
        
        checkFavorites()
        self.navigationItem.rightBarButtonItem = addToFavoritesButton
    }
    
    func setItemInfo() {
        itemSeq.text?.append(item.itemSeq ?? notApplicable)
        itemName.text?.append(item.itemName ?? notApplicable)
        classNo.text?.append(item.classNo ?? notApplicable)
        classNoName.text?.append(item.classNoName ?? notApplicable)
        entpName.text?.append(item.entpName ?? notApplicable)
        itemPermitDate.text?.append(item.itemPermitDate ?? notApplicable)
        cancelCode.text?.append(item.cancelCode ?? notApplicable)
        cancelDate.text?.append(item.cancelDate ?? notApplicable)
    }
    
    ///segmented control에 의해 바뀌어야 하는 뷰의 내용 제어
    func setSegViewContent(index: Int) {
        segmentedContent.text = ""
        
        var docData: NonMedicalItem.DocData?
        switch index {
        case 0:
            docData = item.eeDocData
        case 1:
            docData = item.udDocData
        case 2:
            docData = item.nbDocData
        default:
            docData = nil
        }
        
        guard let doc = docData else {
            segmentedContent.text = "N/A"
            return
        }
        
        for article in doc.articles {
            segmentedContent.text?.append(article.title + "\n")
            for paragraph in article.paragraphs {
                segmentedContent.text?.append("  " + paragraph + "\n")
            }
        }
    }
    
    ///해당 아이템이 즐겨찾기에 추가되어있는지 확인하고 이에 따라 isAddedToFavorites 프로퍼티의 값을 바꿉니다.
    func checkFavorites() {
        let coreDataHandler = CoreDataHandler.shared
        let context = coreDataHandler.persistentContainer.viewContext
        
        do {
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    ///해당 아이템을 즐겨찾기에 추가하거나 삭제합니다.
    @objc func favoritesButtonTapped(_ sender: UIBarButtonItem){
        
        if isAddedToFavorites {
            //이미 즐겨찾기에 추가되어있다면 삭제합니다.
            
        }else {
            //즐겨찾기에 없으므로 추가합니다.
            
            //NSManagedObjectContext 가져오기
            let coreDataHandler = CoreDataHandler.shared
            let context = coreDataHandler.persistentContainer.viewContext
            
            //entity 가져오기
            let entity = NSEntityDescription.entity(forEntityName: "QuasiDrug", in: context)
            
            //NSManagedObject 만들기
            if let entity = entity {
                let item = NSManagedObject(entity: entity, insertInto: context)
                
                //object 값 세팅
                item.setValue(self.item.itemSeq, forKey: "itemSeq")
                item.setValue(self.item.itemName, forKey: "itemName")
                item.setValue(self.item.classNo, forKey: "classNo")
                item.setValue(self.item.classNoName, forKey: "classNoName")
                item.setValue(self.item.entpName, forKey: "entpName")
                item.setValue(self.item.itemPermitDate, forKey: "itemPermitDate")
                item.setValue(self.item.cancelCode, forKey: "cancelCode")
                item.setValue(self.item.cancelDate, forKey: "cancelDate")
                
                let encoder = PropertyListEncoder()
                
                //NSManagedObjectContext 저장
                do {
                    try item.setValue(encoder.encode(self.item.eeDocData), forKey: "eeDocData")
                    try item.setValue(encoder.encode(self.item.udDocData), forKey: "udDocData")
                    try item.setValue(encoder.encode(self.item.nbDocData), forKey: "nbDocData")
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
                //버튼 이미지를 바꾸고 프로퍼티 값 변경
                self.addToFavoritesButton.image = UIImage(systemName: "star.fill")!
                self.isAddedToFavorites = true
            }
            
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl){
        setSegViewContent(index: sender.selectedSegmentIndex)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
