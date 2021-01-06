//
//  ViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var showMaskAuthorizedList: UIButton!
    @IBOutlet weak var outsideTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var searchModeLabel: UILabel!    //검색 모드를 나타내는 label
    @IBOutlet weak var searchModeStackView: UIStackView!    //검색 모드 label과 icon을 포함하는 스택 뷰
    @IBOutlet weak var searchContainerStackView: UIStackView!   //검색 모드 label, icon과 검색 창, 검색버튼을 포함하는 컨테이너 스택뷰
    
    //아래의 Position 프로퍼티들은 각 뷰들의 viewController root view에서의 절대적 위치를 얻기 위한 것들이다. (특정 뷰의 frame값을 단순히 얻어오는 경유 superView에서의 위치만을 얻어옴 -> frame이 아닌 bounds 프로퍼티 써야함
    lazy var searchModeStackViewPosition: CGRect = {
        return self.searchModeStackView.convert(self.searchModeStackView.bounds, to: nil)   //nil로 두면 알아서 윈도우 기준으로 convert
    }()
    lazy var searchBarPosition: CGRect = {
        return self.searchBar.convert(searchBar.bounds, to: nil)
    }()
    lazy var dropDownViewPosition: CGRect = {
        return self.dropDownView.convert(dropDownView.bounds, to: nil)
    }()
    
    var dropDownView: UIDropDownView = UIDropDownView()
    let dropDownViewIdentifier = "searchModeDropDownView"
    let dropDownViewCellIdentifier = "searchModeDropDownViewCell"
    let searchModes: [SearchModeItem] = [SearchModeItem(modeIdentifier: .itemName, modeName: "제품명", modeImage: UIImage(systemName: "doc.text.magnifyingglass")), SearchModeItem(modeIdentifier: .entpName, modeName: "업체명", modeImage: UIImage(systemName: "building"))]
    
    let segueToSearchResultIdentifier: String = "segueToSearchResult"
    
    var currentSearchMode : SearchMode = .itemName
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navItem.title = "filtering"
        searchBar.delegate = self
        
        //delegate방식으로 GestureRecognizer 처리 일원화
        outsideTapGestureRecognizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpDropDownView() //뷰들의 위치를 기반으로 생성되기 때문에 이 메소드에서 호출합니다.
    }
    
    //제스쳐 인식기에 대한 처리 일원화
    /*
     테스트 해보니 gestureRecognizer의 작동 순서는 아래와 같았다.
     gestureRecognizer(_, shoudReceive event:) => gestureRecognizer(_, shoudReceive touch:) => gestureRecognizerShouldBegin(_:)
     이전 메소드에서 return true를 해줘야 다음 단계로 넘어가며 false를 return하는 경우 이후 메소드는 호출되지 않는다. (default로 true를 return한다.)
     gestureRecognizer(_, shoudReceive event:)에서는 사용자가 터치한 좌표값을 얻을 수 없으며 gestureRecognizer(_, shoudReceive touch:)에서부터 touch.location(in:)으로 구할 수 있다. gestureRecognizer.location(in:)으로 구할 수 있는 때는 gestureRecognizerShouldBegin(_:)에서만이며, 이 메소드는 (touch down 이후) touch up을 했을 때에 호출이 된다. (단, 꾹 누르다가 떼는 경우에는 호출 안됨)
     
     */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self.view)
        
        //기존 2개의 GestureRecognizer를 하나로 합침
        if searchBar.isFirstResponder && !searchBarPosition.contains(location) {    //searchBar 외부 누른 경우 키보드 가리기
            searchBar.endEditing(true)
        }
        
        if self.dropDownView.isDropDownPresent && !self.dropDownViewPosition.contains(location) {   //드롭다운이 열려있는 상태에서는 어딜 누르든 드롭다운이 닫히게 만든다. dropDownView의 특정 row아이템을 선택하는 경우 제외 -> 해당 경우는 별도로 처리할 것
            self.dropDownView.hideDropDown()
            //dropDwonView frame 외부 조건(두번째 조건)을 걸지 않으면 dropDownView 열린 상태에서 아이템 클릭 시 dropDownView가 이벤트를 받기 전 GestureRecognizer가 이벤트를 먼저 받아 테이블 뷰가 사라짐 -> view가 이벤트 받는 것이 begin 되었어도 cancel되기 때문 (responder chain 과정 상)
        } else if self.searchModeStackViewPosition.contains(location) { //드롭다운이 열려있지 않을 때 해당 stackView 부분 누르면 열리도록 함
            self.dropDownView.showDropDown(height: (searchModeLabel.frame.height - 25) * CGFloat(searchModes.count))
        }
        
        return false    //이후 메소드 호출 필요성 없음
    }
    
    ///검색바 키보드에서 search버튼 클릭 시
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //검색 버튼 클릭시와 동일한 동작 하도록 작성
        performSegue(withIdentifier: segueToSearchResultIdentifier, sender: searchButton)
    }
    
    ///segue 동작 전 준비사항
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.dropDownView.hideDropDown()
        guard let sender = sender as? UIButton else {
            return
        }
        
        switch sender {
        //검색버튼을 누른 경우
        case searchButton:
            if searchBar.text?.count == 0 {     //아무 내용도 입력하지 않고 검색 버튼을 누른 경우
                let alertController: UIAlertController = UIAlertController(title: "입력한 내용 없음", message: "의약외품 이름을 입력하세요", preferredStyle: .alert)
                
                let okAlertAction: UIAlertAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAlertAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //여기서 작동방식을 선택할 수 있다. 검색을 누른다면 검색결과를 먼저 가져온 뒤에 다음화면으로 넘길지, 아니면 다음화면에 가서 검색을 시작할지.. -> 다음 화면에서 검색을 시작하도록 작성
            guard let nextViewController = segue.destination as? SearchResultViewController else {
                return
            }
            nextViewController.searchContent = searchBar.text
            nextViewController.searchMode = currentSearchMode
            
        //허가받은 목록 버튼 누른 경우
        case showMaskAuthorizedList:
            guard let nextViewController = segue.destination as? MaskAuthorizedListViewController else {
                return
            }
        default:
            return
        }
    }
    
    ///DropDownView를 설정하고 뷰에 추가하는 메소드
    func setUpDropDownView() {
        //개별 ID 설정
        dropDownView.dropDownViewIdentifier = dropDownViewIdentifier
        dropDownView.dropDownViewCellReusableIdentifier = dropDownViewCellIdentifier
        
        //DataSource, Delegate 설정
        dropDownView.dataSource = self
        dropDownView.delegate = self
        
        //셋업
        dropDownView.setUpDropDown(viewPositionReference: searchContainerStackView.frame, offset: 2.0) //해당 뷰 아래에 생성
        dropDownView.width = searchModeStackView.frame.width
        
        dropDownView.nib = UINib(nibName: "UIDropDownViewCell", bundle: nil)    //cell을 nib으로 올려놓고 테이블 뷰에 regist하는 과정
        dropDownView.setRowHeight(height: searchModeLabel.frame.height - 20)
        
        self.view.addSubview(dropDownView)  //추가는 했지만 아직 보이지는 않는다. 내부적으로 height가 0인 상태
    }
    
}

///DropDownView를 구현하기 위한 프로토콜 채택
extension ViewController: UIDropDownViewDataSource, UIDropDownViewDelegate {
    func dropDownView(numberOfRowsInDropDownViewWithID identifier: String) -> Int {
        searchModes.count
    }
    
    func dropDownView(dequeuedCell cell: UITableViewCell, cellForRowAt index: Int, dropDownViewIdentifier identifier: String) {
        let cell: UIDropDownViewCell = (cell as? UIDropDownViewCell) ?? UIDropDownViewCell()
        cell.searchModeNameLabel.text = searchModes[index].modeName
        cell.searchModeImageView.image = searchModes[index].modeImage
    }
    
    func dropDownView(didSelectRowAt index: Int, dropDownViewIdentifier identifier: String) {
        self.searchModeLabel.text = searchModes[index].modeName
        self.searchBar.placeholder = searchModes[index].modeName + " 입력"
        self.currentSearchMode = searchModes[index].modeIdentifier
        
        self.dropDownView.hideDropDown()
    }
}
