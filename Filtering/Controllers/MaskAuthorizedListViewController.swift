//
//  MaskAuthorizedListViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class MaskAuthorizedListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
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
    var filteredItems: [MaskItem] = []
    
    lazy var userDefaults: UserDefaults = {
        return UserDefaults.standard
    }()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm"
        return formatter
    }()
    
    lazy var parsingResultHandler: (Result<[MaskItem], Error>) -> Void = { [weak self] result in
        self?.controlIndicators(message: "", isHidden: true)
        guard let self = self else {
            return
        }
        switch result {
        case .success(let maskItems):
            self.tableView.isHidden = false
            self.searchBar.isHidden = false
            
            self.items = maskItems
            self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "")
            //현재 테이블뷰는 사용자가 검색한 값이 없으면 그냥 items그대로, 검색한 값이 있으면 해당 검색한 값에 맞게 필터링해서 보여주려고 한다. 그래서 기본적으로 tableView에서 DataSource로 쓰는 배열을 filteredItems로 설정하였다. 그러면 맨 처음에 모든 목록을 보여주려면 self.items와 self.filteredItems는 동일해야한다.
            //self.filteredItems = maskItems (또는 self.filteredItems = self.items)라고 바로 할당하지 않고 위의 메소드를 쓴 이유 및 여기에서 tableView.reloadSections()를 제거한 이유에 대하여.
            //-> items와 filteredItems는 가장 처음에는 동일해야하겠지만 검색어가 있는 상태에서 다른화면으로 갔다가 다시 돌아오는 경우 업데이트가 이루어지면 문제가 발생한다. 검색어는 분명히 있는데 업데이트가 이루어지면서 그냥 self.filteredItems = maskItems라고 하면 검색어가 무시되고 모든 목록이 다 보여지게 된다. 따라서 searchBar의 딜리게이트 메소드를 한번 호출하도록 해두었다. 만약 검색어가 있었다면 다른 화면으로 갔다가 왔을 때 업데이트가 이루어지더라도 검색어에 맞는 목록만 보일 것이며 검색어가 없다면 그냥 self.items를 보여주는 것과 동일하게 된다.
            //-> tableView.reloadSections()를 없앤 이유는 간단하다. searchBar Delegate 메소드에서 해당 메소드를 이미 호출하고 있기 때문에 굳이 중복호출 할 필요가 없다.
            
            let now = self.dateFormatter.string(from: Date())
            self.userDefaults.setValue(now, forKey: self.dateKey)
            self.userDefaults.setValue(self.items.count, forKey: self.numberKey)
        case .failure(let error):
            print(error)
            //여기서 받을 수 있는 에러는 파싱에러, 파일 관련 에러, 워크시트 에러 등 로컬적인 부분이다.
            self.presentAlert(title: "오류 발생", message: "파일을 불러오던 도중 문제가 발생하였습니다. 다음에 다시 시도해주세요.", needToPop: true)
        }
    }
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
    }
    //viewDidLoad 단계에서 테이블 뷰와 검색 창은 hidden상태이며 indicator요소들만 보이는 상태입니다.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controlIndicators(message: "새로운 데이터가 있는지 확인중...", isHidden: false)
        
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
                    //업데이트 할 필요가 없음 - 12시간도 지나지 않았고 새로운 데이터가 있지도 않음
                    self.getLocalMaskLists()
                }
            case .failure(let error):
                print(error)
                self.presentAlert(title: "오류 발생", message: "목록 개수 확인 과정에서 오류 발생\n다음에 다시 시도하십시오.", needToPop: true)
                self.controlIndicators(message: "", isHidden: true)
            }
        }
        
    }
    
    ///새로운 데이터를 가져오기
    func getNewMaskLists() {
        controlIndicators(message: "새로운 데이터 받아오는 중..", isHidden: nil)
        NetworkHandler.getMaskData { resultURL in
            switch resultURL {
            case .success(let url):
                MaskXLSXParser.parseXLSX(fileURL: url, resultHandler: self.parsingResultHandler)
            case .failure(let error):
                print(error)
                self.presentAlert(title: "오류 발생", message: "서버에서 데이터를 받아오던 도중 오류가 발생하였습니다.\n다음에 다시 시도하여주세요.", needToPop: false)
                self.controlIndicators(message: "", isHidden: true)
            }
        }
    }
    
    ///기존에 저장된 데이터를 파싱하여 가져옴
    func getLocalMaskLists() {
        //앱을 처음으로 다운받아 실행시켰다면 이 메소드는 호출되지 않을 것이며 데이터를 새로 받아 올 것. (이후에는 업데이트가 필요하면 업데이트를 알아서 함)
        //다른 화면 잠깐 갔다가 다시 왔을 때 업데이트를 다시 할 필요가 없다면 로컬 데이터를 다시 파싱 할 필요도 없음(보여줬던 것 그대로 다시 보여주면 됨)
        //다만 앱을 껐다가 다시 킨 경우(12시간도 안지났고 목록 수도 안 변해서) 업데이트가 필요없다면 이 메소드가 호출 될 텐데 이 때 items는 비어있을 것이므로 이때에 대한 대처는 필요. 기존 저장되어있던 파일을 파싱해서 가져와야 함.
        if items.count == 0 {
            controlIndicators(message: "기존 데이터 불러오는 중", isHidden: nil)
            guard let documentURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return presentAlert(title: "오류 발생", message: "로컬 파일시스템에 접근할 수 없습니다.", needToPop: true)
            }
            let localFileURL: URL = documentURL.appendingPathComponent("maskData.xlsx")
            MaskXLSXParser.parseXLSX(fileURL: localFileURL, resultHandler: self.parsingResultHandler)
        }else {
            controlIndicators(message: "", isHidden: true)
        }
    }
    
    ///indicator들을 한번에 제어하는 메소드
    /// - parameter message: indicator label에 보일 메시지 기입. 아무 메시지도 안보이게 하고 싶거나 필요가 없는 경우 "" 빈 텍스트 기입
    /// - parameter isHidden: 숨길지 보일지를 제어. 만약 indicator 메시지만 바꿀 것이라면 인자로 nil을 줄 것
    func controlIndicators(message: String, isHidden: Bool?) {
        indicatorLabel.text = message
        guard let isHidden = isHidden else {
            return
        }
        indicatorLabel.isHidden = isHidden
        if isHidden { indicatorView.stopAnimating() } else { indicatorView.startAnimating() }
        indicatorView.isHidden = isHidden
        indicatorStackView.isHidden = isHidden
    }
    
    func presentAlert(title: String, message: String, needToPop: Bool) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var handler: ((UIAlertAction) -> Void)?
        if needToPop {
            handler = { _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }else {
            handler = nil
        }
        
        let okAlertAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        alertController.addAction(okAlertAction)
        
        self.navigationController?.visibleViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MaskItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: maskItemCellIdentifier) as? MaskItemTableViewCell ?? MaskItemTableViewCell()
        
        let item = filteredItems[indexPath.row]
        cell.itemName.text = item.itemName
        cell.entpName.text = item.entpName
        cell.maskTypeLable.text = item.classification.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MaskAuthorizedListDetailViewController") as? MaskAuthorizedListDetailViewController else {
            return
        }
        
        detailViewController.itemSeq = filteredItems[indexPath.row].itemSeq
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    //MARK:- SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredItems = searchText.isEmpty ? self.items : self.items.filter {
            $0.itemName.range(of: searchText, options: .caseInsensitive) != nil || $0.entpName.range(of: searchText, options: .caseInsensitive) != nil
            //아이템명 또는 업체명으로 검색할 수 있도록 설정
            //위 구문은 String.contains()와 동일하다. 다만 대소문자 미구분인 것만 다르다.
        }
        
        tableView.reloadSections(IndexSet(0...0), with: .automatic)
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
