//
//  SearchResultViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    //ViewController에서 입력한 검색 내용
    var searchContent: String?
    private let cellIdentifier: String = "resultItemCell"
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var items: [NonMedicalItem] = []
    private var parsingResultHandler: ((Result<[NonMedicalItem], Error>) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let searchContent = searchContent else {
            let alertController: UIAlertController = UIAlertController(title: "입력한 내용 없음", message: "의약외품 이름을 입력하세요", preferredStyle: .alert)
            
            let okAlertAction: UIAlertAction = UIAlertAction(title: "ok", style: .default){ _ in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAlertAction)
            
            self.present(alertController, animated: true, completion: nil)

            return
        }
        
        //segue를 통해 세팅된 searchContent에 맞는 값을 가져오기
        guard let networkHandler: NetworkHandler = NetworkHandler.shared else {
            
            let alertController: UIAlertController = UIAlertController(title: "오류 발생", message: "네트워크 설정 중 오류가 발생하였습니다. 다음에 다시 시도하세요", preferredStyle: .alert)
            
            let okAlertAction: UIAlertAction = UIAlertAction(title: "ok", style: .default){ _ in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAlertAction)
            
            self.present(alertController, animated: true, completion: nil)

            return
        }
        
        loadingIndicator.startAnimating()
        networkHandler.getContents(itemName: searchContent) { result in
            switch result {
            case .success(let data):
                let parser: ItemXMLParser = ItemXMLParser.shared
                parser.parseXML(xmlData: data)
            case .failure(let error):
                print(error)
            }
        }
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
