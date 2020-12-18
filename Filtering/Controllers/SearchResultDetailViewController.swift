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
    let notApplicable: String = "N/A"
    
    @IBOutlet weak var itemSeq: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var classNo: UILabel!
    @IBOutlet weak var classNoName: UILabel!
    @IBOutlet weak var entpName: UILabel!
    @IBOutlet weak var itemPermitDate: UILabel!
    @IBOutlet weak var cancelCode: UILabel!
    @IBOutlet weak var cancelDate: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.title = "상세 조회"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
