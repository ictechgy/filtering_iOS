//
//  SearchResultViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    //ViewController에서 입력한 검색 내용
    var searchContent: String!
    let cellIdentifier: String = "resultItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //segue를 통해 세팅된 searchContent에 맞는 값을 가져오기
        
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
