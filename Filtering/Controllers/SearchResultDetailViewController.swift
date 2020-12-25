//
//  SearchResultDetailViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class SearchResultDetailViewController: UIViewController {
    
    ///이전 화면(SearchResultViewController)에서 넘겨받은 아이템 객체
    var item: NonMedicalItem!
    let notApplicable: String = "N/A"   //받은 아이템 객체 값에 nil 이 있을 시 띄울 메시지
    
    var isAddedToFavorites: Bool = false    //즐겨찾기에 추가되어있는지 아닌지
    var isFavoritesAvailable: Bool = true   //즐겨찾기 버튼 활성화 여부
    
    lazy var addToFavoritesButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(favoritesButtonTapped(_:)))
        button.tintColor = .systemYellow
        //이미지 및 enable 여부는 viewWillAppear에서 결정하도록 하자.

        return button
    }()
    
    lazy var star: ()-> UIImage = { [unowned self] in
        var iconImage: UIImage
        if self.isAddedToFavorites {
            iconImage = UIImage(systemName: "star.fill")!
        }else {
            iconImage = UIImage(systemName: "star")!
        }
        return iconImage
    }
    
    @IBOutlet weak var itemSeq: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var classNo: UILabel!
    @IBOutlet weak var classNoName: UILabel!
    @IBOutlet weak var entpName: UILabel!
    @IBOutlet weak var itemPermitDate: UILabel!
    @IBOutlet weak var cancelCode: UILabel!
    @IBOutlet weak var cancelDate: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedContent: UILabel!

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "상세 조회"
        // Do any additional setup after loading the view.
        segmentedControl.addTarget(self, action: #selector(setSegViewContent(_:)), for: .valueChanged)
        
        //즐겨찾기 버튼은 언제나 있어야 한다. (viewWillAppear에 둘 필요가 없음)
        self.navigationItem.rightBarButtonItem = addToFavoritesButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setItemInfo()   //넘겨받은 아이템을 이용해서 화면 Outlet에 값 세팅
        segmentedControl.selectedSegmentIndex = 0   //다른 화면 갔다가 다시 돌아오는 경우 세그 뷰 컨텐츠만 0번 인덱스 값으로 바뀌고 컨트롤은 그대로 1번 인덱스나 2번 인덱스를 가리키고 있어서 추가한 구문
        setSegViewContent(self.segmentedControl) //세그먼티드 컨트롤에 대한 뷰 세팅(기본 값은 0번 인덱스 값으로)
        
        checkFavorites()    //현재 아이템이 즐겨찾기에 추가되어있는지 아닌지를 체크합니다.
        //이 메소드가 작동함으로써 현재 아이템이 DB에 있는지 없는지 알 수 있으며 itemSeq가 nil인 경우 즐겨찾기 비활성화 여부도 알 수 있다.
        
        addToFavoritesButton.image = star()  //뷰가 나타날 때마다 새로 아이콘 이미지 설정.
        //상세화면에서 즐겨찾기 추가 후 바로 Favorite 즐겨찾기 목록에서 삭제하고 다시 돌아오는 경우가 있을 수 있어 매번 체크해야함
        
        addToFavoritesButton.isEnabled = isFavoritesAvailable   //활성화여부 설정
    }
    
    ///아이템의 값들을 이용하여 화면 IBOutlets에 값 세팅
    func setItemInfo() {
        itemSeq.text = "품목기준코드: " + (item.itemSeq ?? notApplicable)
        itemName.text = "품목명: " + (item.itemName ?? notApplicable)
        classNo.text = "품목코드: " + (item.classNo ?? notApplicable)
        classNoName.text = "품목코드명: " + (item.classNoName ?? notApplicable)
        entpName.text = "업체명: " + (item.entpName ?? notApplicable)
        itemPermitDate.text = "허가일: " + (item.itemPermitDate ?? notApplicable)
        cancelCode.text = "인증상태: " + (item.cancelCode ?? notApplicable)
        cancelDate.text = "취소일: " + (item.cancelDate ?? notApplicable)
        //text.append로 하니까 viewWillAppear할 때마다 뒤에 계속 값이 붙어서 변경 (다른 화면으로 단순히 이동했다가 다시 오는경우..)
    }
    
    ///segmented control에 의해 바뀌어야 하는 뷰의 내용 제어
    @objc func setSegViewContent(_ sender: UISegmentedControl) {
        segmentedContent.text = ""
        
        var docData: NonMedicalItem.DocData?
        switch sender.selectedSegmentIndex {
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
        guard let seq = self.item.itemSeq else {
            //itemSeq를 확인할 수 없는 경우에는 즐겨찾기 버튼 비활성화 하기
            isFavoritesAvailable = false
            return
        }
        
        let coreDataHandler = CoreDataHandler.shared
        let result = coreDataHandler.isItemExist(itemSeq: seq)
        
        switch result {
        case .none:     //확인 실패, 즐겨찾기 비활성화
            isFavoritesAvailable = false
        case .some(let exist):
            if exist {  //존재한다면
                isAddedToFavorites = true
                isFavoritesAvailable = true
            }else {
                isAddedToFavorites = false
                isFavoritesAvailable = true
            }
        }
    }
    
    ///해당 아이템을 즐겨찾기에 추가하거나 삭제합니다.
    @objc func favoritesButtonTapped(_ sender: UIBarButtonItem){
        let coreDataHandler = CoreDataHandler.shared
        
        if isAddedToFavorites {
            //이미 즐겨찾기에 추가되어있다면 삭제합니다.
            let result = coreDataHandler.deleteItem(itemSeq: self.item.itemSeq!)    //itemSeq가 nil이라면 버튼이 비활성화되도록 해두었으므로 unwrapping 가능
            if result {     //삭제 성공
                self.addToFavoritesButton.image = UIImage(systemName: "star")!
                self.isAddedToFavorites = false
            }else {
                //삭제 실패 - alert를 띄우고 버튼 이미지는 바꾸지 않습니다.
                presentAlert(title: "삭제 실패", message: "즐겨찾기 목록에서 삭제하는데 실패하였습니다. 다음에 다시 시도하세요.")
            }
            
        }else {
            //즐겨찾기에 없으므로 추가합니다.
            let result = coreDataHandler.insertItem(item: self.item)
            
            if result {     //즐겨찾기 추가 성공
                //버튼 이미지를 바꾸고 프로퍼티 값 변경
                self.addToFavoritesButton.image = UIImage(systemName: "star.fill")!
                self.isAddedToFavorites = true
            }else {
                //즐겨찾기 추가 실패 -  alert를 띄우고 버튼 이미지는 바꾸지 않습니다.
                presentAlert(title: "추가 실패", message: "즐겨찾기 목록에 추가하는데 실패하였습니다. 다음에 다시 시도하세요.")
            }
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAlertAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAlertAction)
        
        self.present(alertController, animated: true, completion: nil)
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
