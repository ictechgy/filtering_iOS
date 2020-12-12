//
//  ViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var showMaskAuthorizedList: UIButton!
    
    @IBAction func tapOutsideView(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? UIButton else {
            return
        }
        
        switch sender {
        case searchButton:
            if searchBar.text?.count == 0 {     //아무 내용도 입력하지 않고 검색 버튼을 누른 경우
                let alertController: UIAlertController = UIAlertController(title: "입력한 내용 없음", message: "의약외품 이름을 입력하세요", preferredStyle: .alert)
                
                let okAlertAction: UIAlertAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAlertAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //여기서 작동방식을 선택할 수 있다. 검색을 누른다면 검색결과를 먼저 가져온 뒤에 다음화면으로 넘길지, 아니면 다음화면에 가서 검색을 시작할지..

            guard let nextViewController = segue.destination as? SearchResultViewController else {
                return
            }
            nextViewController.searchContent = searchBar.text
            
        case showMaskAuthorizedList:
            guard let nextViewController = segue.destination as? MaskAuthorizedListViewController else {
                return
            }
        default:
            return
        }
    }
}

