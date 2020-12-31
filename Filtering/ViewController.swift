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
    
    @IBOutlet weak var searchModeLabel: UILabel!
    @IBOutlet weak var searchModeTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var searchModeStackView: UIStackView!
    
    var dropDownView: UIDropDownView = UIDropDownView()
    let dropDownViewIdentifier = "searchModeDropDownView"
    let dropDownViewCellIdentifier = "searchModeDropDownViewCell"
    let searchModes: [SearchModeItem] = [SearchModeItem(modeIdentifier: "item_name", modeName: "제품명", modeImage: UIImage(systemName: "doc.text.magnifyingglass")), SearchModeItem(modeIdentifier: "entp_name", modeName: "업체명", modeImage: UIImage(systemName: "building"))]
    
    let segueToSearchResultIdentifier: String = "segueToSearchResult"
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navItem.title = "filtering"
        searchBar.delegate = self
        searchModeTapGestureRecognizer.addTarget(self, action: #selector(searchModeStackViewTapped(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpDropDownView() //뷰들의 위치를 기반으로 생성되기 때문에 이 메소드에서 호출합니다.
    }
    
    
    @IBAction func tapOutsideView(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true) ///검색바 외부 클릭시 키보드 숨기기
        dropDownView.hideDropDown() //외부 터치 시 DropDownView 숨기기
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
        dropDownView.setUpDropDown(viewPositionReference: searchModeStackView.frame, offset: 2.0) //해당 뷰 아래에 생성
        dropDownView.nib = UINib(nibName: "UIDropDownViewCell", bundle: nil)    //cell을 nib으로 올려놓고 테이블 뷰에 regist하는 과정
        dropDownView.setRowHeight(height: searchModeLabel.frame.height)
        
        self.view.addSubview(dropDownView)  //추가는 했지만 아직 보이지는 않는다. 내부적으로 height가 0인 상태
    }
    
    @objc func searchModeStackViewTapped(_ sender: UITapGestureRecognizer) {
        if self.dropDownView.isDropDownPresent {
            self.dropDownView.hideDropDown()
        }else {
            self.dropDownView.showDropDown(height: searchModeLabel.frame.height * CGFloat(searchModes.count))
        }
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
    
    func dropDownView(didSelectedRowAt index: Int, dropDownViewIdentifier identifier: String) {
        self.searchModeLabel.text = searchModes[index].modeName
        self.dropDownView.hideDropDown()
    }
}
