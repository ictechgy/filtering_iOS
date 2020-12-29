//
//  ViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var showMaskAuthorizedList: UIButton!
    @IBOutlet weak var searchModePickerView: UIPickerView!
    
    let segueToSearchResultIdentifier: String = "segueToSearchResult"
    let searchMode: [String] = ["제품명", "업체명"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navItem.title = "filtering"
        
        searchBar.delegate = self
        searchModePickerView.dataSource = self
        searchModePickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    ///검색바 외부 클릭시 키보드 숨기기
    @IBAction func tapOutsideView(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    ///검색바 키보드에서 search버튼 클릭 시
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //검색 버튼 클릭시와 동일한 동작 하도록 작성
        performSegue(withIdentifier: segueToSearchResultIdentifier, sender: searchButton)
    }
    
    ///segue 동작 전 준비사항
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    //column 수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        searchMode.count
    }
    
    //글자 속성을 지정하기 위해서 pickerView(titleForRow:) 대신 아래의 메소드 사용
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel = (view as? UILabel) ?? UILabel()
        label.text = searchMode[row]
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
    }
}

