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
    
    @IBOutlet weak var segmentedContent: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.title = "상세 조회"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setItemInfo()
        setSegViewContent(index: 0)
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
