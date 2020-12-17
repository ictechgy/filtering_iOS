//
//  SearchResultViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //ViewController에서 입력한 검색 내용
    var searchContent: String?
    private let cellIdentifier: String = "resultItemCell"
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isResultExists: UILabel!
    
    ///화면에 표시할 아이템 목록
    private var items: [NonMedicalItem] = []
    
    ///해당 내용으로 검색했을 때 서버에서 얻은 일치하는 총 목록 수
    private var numberOfSearchResults: Int = 0
    
    ///현재 보고 있는 페이지
    private var loadedPageCount: Int = 1
    private var parsingResultHandler: ((Result<[NonMedicalItem], Error>, Int) -> Void)!

    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        parsingResultHandler = { [weak self] result, numberOfTotalItems in      //retain cycle 방지
            switch result {
            case .success(let parsedItems):
                //검색 결과 아이템이 없다면
                if numberOfTotalItems == 0 {
                    self?.isResultExists.isHidden = false
                    self?.tableView.isHidden = true
                }else {
                    self?.items.append(contentsOf: parsedItems)
                    self?.numberOfSearchResults = numberOfTotalItems
                    
                    //tableView 다시 그리기
                    self?.tableView.reloadData()
                }
                
            case .failure(_):
                self?.presentAlert(title: "오류 발생", message: "데이터를 불러오는 도중 오류가 발생했습니다. 다음에 다시 시도하세요!", needToPop: false)
            }
            self?.loadingIndicator.stopAnimating()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isResultExists.isHidden = true
        self.tableView.isHidden = false
        
        guard let searchContent = searchContent else {
            presentAlert(title: "입력한 내용 없음", message: "의약외품 이름을 입력하세요", needToPop: true)
            return
        }
        
        guard let networkHandler: NetworkHandler = NetworkHandler.shared else {
            presentAlert(title: "오류 발생", message: "네트워크 설정 중 오류가 발생하였습니다. 다음에 다시 시도하세요", needToPop: true)
            return
        }
        
        //segue를 통해 세팅된 searchContent에 맞는 값을 가져오기
        loadingIndicator.startAnimating()
        networkHandler.getContents(itemName: searchContent) { result in
            switch result {
            case .success(let data):
                let parser: ItemXMLParser = ItemXMLParser.shared
                parser.parseXML(xmlData: data, resultHandler: self.parsingResultHandler)    //클로저 참조를 넘긴다.
            case .failure(_):
                self.presentAlert(title: "오류 발생", message: "서버로부터 데이터를 받아오던 도중 오류가 발생하였습니다. 다시 시도하세요", needToPop: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NetworkHandler.shared?.abortNetworking()
        ItemXMLParser.shared.abortParse()
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchItemTableViewCell else {
            return SearchItemTableViewCell()
        }
        let item = items[indexPath.row]
        cell.itemName.text = item.itemName
        cell.entpName.text = item.entpName
        
        return cell
    }
    
    //MARK:- Custom Methods
    func presentAlert(title: String, message: String, needToPop: Bool) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var handler: ((UIAlertAction) -> Void)?
        if needToPop {
            handler = { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }else {
            handler = nil
        }
        
        let okAlertAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: handler)
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
