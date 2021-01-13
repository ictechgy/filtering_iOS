//
//  MaskAuthorizedListViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class MaskAuthorizedListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Variables
    //MARK: IBOutlet Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    //MARK: General Variables
    let dateKey: String = "DownloadedDate"  //파일을 마지막으로 다운 받은 시각에 대한 UserDefaults 키 값
    let numberKey: String = "NumberOfAuthorizedMasks" //마스크 허가목록 개수에 대한 UserDefaults 키 값
    
    let maskItemCellIdentifier: String = "maskItemCell"
    var items: [MaskItem] = []
    
    lazy var userDefaults: UserDefaults = {
        return UserDefaults.standard
    }()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm"
        return formatter
    }()
    
    lazy var parsingResultHandler: (Result<[MaskItem], Error>) -> Void = { [weak self] result in
        switch result {
        case .success(let maskItems):
            guard let self = self else {
                return
            }
            self.items = maskItems
            self.tableView.reloadSections(IndexSet(0...0), with: .none)
            self.indicatorStackView.isHidden = true
            
            let now = self.dateFormatter.string(from: Date())
            self.userDefaults.setValue(now, forKey: self.dateKey)
            self.userDefaults.setValue(self.items.count, forKey: self.numberKey)
        case .failure(_):
            <#code#>
        }
    }
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    //viewDidLoad 단계에서 테이블 뷰와 검색 창은 hidden상태이며 indicator요소들만 보이는 상태입니다.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //이전 데이터를 다운 받은 시기로부터 12시간이 지났거나 데이터에서 row의 수가 달라진 경우/스크래핑을 통해 얻은 숫자 값이 달라진경우
        // -> 재다운로드
        decide2Download()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //TODO: 네트워크 통신 취소
    }
    
    //MARK:- Custom Methods
    func decide2Download() {
        guard let lastDownloadedDateString = userDefaults.string(forKey: dateKey) else {
            getNewMaskLists()
            return
        }    //이전에 파일을 다운로드 받은 일시 불러오기
        let numberOfMasksLastFetched = userDefaults.integer(forKey: numberKey) //이전에 파악해둔 마스크 목록 개수 불러오기
        if numberOfMasksLastFetched == 0 { getNewMaskLists(); return }
        
        guard let lastDownloadedDate = dateFormatter.date(from: lastDownloadedDateString) else {
            getNewMaskLists()
            return
        }
                
        let timeInterval = lastDownloadedDate.timeIntervalSinceNow //이전에 다운받은 일시와 현재 시각과의 시간 차(seconds)
        if timeInterval > 43200 {   //12시간 넘었다면
            getNewMaskLists()
            return
        }
        
        
        NetworkHandler.scrapingNumberOfMasks { result in
            switch result {
            case .success(let number):
                if numberOfMasksLastFetched != number {
                    self.getNewMaskLists()
                }else {
                    //업데이트 할 필요가 없음
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func getNewMaskLists() {
        NetworkHandler.getMaskData { resultURL in
            switch resultURL {
            case .success(let url):
                MaskXLSXParser.parseXLSX(fileURL: url, resultHandler: self.parsingResultHandler)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MaskItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: maskItemCellIdentifier) as? MaskItemTableViewCell ?? MaskItemTableViewCell()
        
        let item = items[indexPath.row]
        cell.itemName.text = item.itemName
        cell.entpName.text = item.entpName
        cell.maskTypeLable.text = item.classification.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
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
