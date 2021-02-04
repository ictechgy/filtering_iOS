//
//  SearchResultViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit
import FirebaseStorage
import SDWebImage
import FirebaseUI

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //ViewController에서 입력한 검색 내용
    var searchContent: String?
    var searchMode: SearchMode = .itemName
    private let cellWithImageIdentifier: String = "resultItemCellWithImage"
    private let cellWithoutImageIdentifier: String = "resultItemCellWithoutImage"
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isResultExists: UILabel!
    
    ///화면에 표시할 아이템 목록
    private var items: [NonMedicalItem] = []
    
    ///해당 내용으로 검색했을 때 서버에서 얻은 일치하는 총 목록 수
    private var numberOfSearchResults: Int = 0
    
    ///현재 보고 있는 페이지
    private var loadedPageCount: Int = 1
    private var numberOfRows: Int = 20
    private var parsingResultHandler: ((Result<[NonMedicalItem], Error>, Int) -> Void)!
    
    //Firebase Storage
    lazy var photoStorageRef: StorageReference = {
        return Storage.storage().reference().child("QuasiDrugPhotos")
    }()

    
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
                    //FIXME: - reloadData()보다 효율적인 메소드로 변경할 것
                    //self?.tableView.reloadData()
                    self?.tableView.reloadSections(IndexSet(0...0), with: .automatic)
                    //더 나은 방법이 있을까..?
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
        
        if items.count == 0 {
            importDataFromServerAndParsing(numberOfPage: loadedPageCount, numberOfRowsPerPage: numberOfRows)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //다음 데이터 로딩중에 특정 셀 항목을 계속 누르면 로딩중에 다음 컨트롤러로 들어가짐. 이 때 문제가 발생한다.
        //closure의 데이터 append는 되지 않고 viewWillDisappear()만 작동.
        //아니면 초기 로딩시 지연이 발생하는 경우 뒤로가기를 바로 누른다면..
        
        //데이터를 로딩중이었다면
        if loadingIndicator.isAnimating == true {
            NetworkHandler.shared?.abortNetworking()
            ItemXMLParser.shared.abortParse()
            loadingIndicator.stopAnimating()
            
            if loadedPageCount > 1{
                //스크롤을 아래로 내려 추가적 목록을 로드중이었다면 (로드 중 상태에서 특정 항목의 상세화면으로 들어갔거나 뒤로 간 경우)
                
                if items.count < (loadedPageCount*numberOfRows) && items.count < numberOfSearchResults {
                    //서버에서 가져온 아이템이 아직 items 배열에 append가 안된 경우였다면
                    loadedPageCount -= 1    //올라갔을 페이지 카운트를 1 줄인다.
                }else{
                    //일단 서버에서 가져온 아이템이 배열에 추가는 된 상태라면(혹시나)
                    
                    if tableView.numberOfRows(inSection: 0) == items.count {
                        //해당 추가된 것들이 tableView에 이미 반영이 되었다면 해야할 것은 없음
                    }else{
                        //배열에는 추가가 됐는데 tableView에는 반영이 안됐다면
                        tableView.reloadSections(IndexSet(0...0), with: .automatic)
                        //반영까지만 해주기... 괜찮으려나..? disappear되는데 reload해주는게...
                    }
                }
            }
        }
    }
    
    //MARK:- UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let item = items[indexPath.row]
        let identifier: String = item.itemImage == nil ? cellWithoutImageIdentifier : cellWithImageIdentifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) 
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchItemTableViewCell else {
            return SearchItemTableViewCell()
        }
        //TODO: 각각의 아이템 클릭 시 작동할 코드 작성
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewCellTapped(_:)))
        cell.addGestureRecognizer(tapGestureRecognizer)
        cell.tag = indexPath.row
        
        cell.itemName.text = item.itemName
        cell.entpName.text = item.entpName
        
        guard let itemSeq = item.itemSeq else {
            return cell
        }
        let photoDirRef: StorageReference = photoStorageRef.child(itemSeq) //해당 아이템 itemSeq로 된 폴더 가리키기
        let photoRef: StorageReference = photoDirRef.child(itemSeq + "_1.jpg")  //사진들 중 첫번째 사진 참조
        
        //cell 재활용 전 설정
        cell.itemImageView.sd_cancelCurrentImageLoad()  //로드중인 이미지가 있었다면 취소합니다.
        cell.itemImageView.image = nil
        cell.itemImageView.isHidden = true
        
        if let existingImage = item.itemImage { //만약 기존에 이미 이미지를 로딩 했었던 아이템이라면
            cell.itemImageView.image = existingImage
            cell.itemImageView.isHidden = false
        }else {
            cell.itemImageView.sd_setImage(with: photoRef, placeholderImage: nil) { [weak self] (image, error, imageCacheType, ref) in
                guard let self = self else {
                    return  //self 없을 시 return
                }
                
                //completion (main queue)
                //궁금한게 있다. 이 클로저부분은 콜백으로 실행될텐데 이 때 여기서 가리키는 cell이 기존의 그 cell이라고 장담할 수 있을까? 이미 재활용되어서 다른 셀을 가리키는 것이라면?? -> 그래서 재활용 되기 전에 기존 Load를 cancel하는 메소드를 기입해주긴 했다..
                //또 궁금한 것은.. 이미지를 다운로드 받다가 다 다운되기 전에 화면이 pop되거나 다른화면으로 push되는 등의 화면 전환 동작이 생기면 다운로드 받던 것은 어떻게 되는 걸까? 
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }  //error 발생 시 아무것도 하지 않습니다.
                
                //에러가 없다면
                cell.itemImageView.isHidden = false     //UIImageView 보여주기
                self.items[cell.tag].itemImage = image  //이미지를 저장
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //section이 하나이기에 가능한 방법
        if indexPath.row + 1 == items.count && items.count < numberOfSearchResults {   //맨 끝에 도달한 경우(맨 마지막 아이템을 그리는 경우), 검색 결과 아이템에 대한 것들이 아직 서버에 더 남아있는 경우
            loadedPageCount += 1
            importDataFromServerAndParsing(numberOfPage: loadedPageCount, numberOfRowsPerPage: numberOfRows)
        }
    }
    
    //Cell이 눌린 경우 작동할 메소드
    @objc func tableViewCellTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = (sender.view as? UITableViewCell)?.tag else {
            return
        }
        
        guard let detailViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchResultDetailViewController") as? SearchResultDetailViewController else {
            return
        }
        //만약에 이미지가 다 로드되기 전에 셀을 탭해서 상세화면으로 넘어간다면 상세화면에서도 이미지는 안뜨겠지? (이미지가 있는 것이었어도 로드가 안됐다면) 그럼 그 상태에서 즐겨찾기 한다면.. 이미지 또한 안들어가겠군..
        detailViewController.item = items[tag]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var msg: String = "'" + (searchContent ?? "알 수 없음") + "'에 대해 "
        msg.append(String(numberOfSearchResults) + " 개의 검색 결과가 존재합니다.")
        return msg
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
    
    ///서버로부터 데이터를 fetch하고 parsing합니다.
    func importDataFromServerAndParsing(numberOfPage: Int, numberOfRowsPerPage: Int) {
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
        networkHandler.getContents(searchMode: searchMode, searchContent: searchContent, pageNum: numberOfPage, numOfRows: numberOfRowsPerPage) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let data):
                let parser: ItemXMLParser = ItemXMLParser.shared
                parser.parseXML(xmlData: data, resultHandler: self.parsingResultHandler)    //클로저 참조를 넘긴다.
            case .failure(let error):
                switch error {
                case .canceled:     //취소에 의한 것이라면 아무것도 안해도 됨
                    return
                default:
                    self.presentAlert(title: "오류 발생", message: "서버로부터 데이터를 받아오던 도중 오류가 발생하였습니다. 다시 시도하세요", needToPop: true)
                }
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
