//
//  FavoriteListViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

//즐겨찾기 한 목록을 볼 수 있는 VC
class FavoriteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoritesNotExistLabel: UILabel!
    
    let cellIdentifier: String = "favoriteItemCell"
    var items: [NonMedicalItem] = []
    
    lazy var editModeDeleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash")!, style: .plain, target: self, action: #selector(deleteSelectedRows(_:)))
        button.tintColor = .systemRed

        return button
    }()
    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        
        self.navigationItem.leftBarButtonItem = editButtonItem      //이 친구는 계속 있어야하므로 lazy var가 아니라 여기에.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bringAllItemsAndSetUp()
    
        //아이템 개수 체크해서 활성화여부는 계속 확인해야 한다. (이 화면이 한번 만들어졌던 상태에서) 검색화면에서 즐겨찾기가 계속 바뀔 수 있으므로
        if self.items.count == 0 {
            editButtonItem.isEnabled = false
        }else {
            editButtonItem.isEnabled = true
        }
    }
    
    ///Core Data에서 즐겨찾기에 추가되어있는 모든 아이템을 가져옵니다.
    func bringAllItemsAndSetUp() {
        let coreDataHandler = CoreDataHandler.shared
        
        if coreDataHandler.needToCheckData {
            items = coreDataHandler.fetchAllItems()
            
            if items.count == 0 {
                favoritesNotExistLabel.isHidden = false
                tableView.isHidden = true
            }else{
                favoritesNotExistLabel.isHidden = true
                tableView.isHidden = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CoreDataHandler.shared.needToCheckData {
            tableView.reloadSections(IndexSet(0...0), with: .automatic)
            CoreDataHandler.shared.needToCheckData = false
        }
        /*  tableView.reloadSections(_, with:)에 대해
         1. 이 녀석을 viewWillAppear(animated:) 맨 마지막에 넣으니 warning이 생겼다.
         "뷰계층에 tableView가 들어가있지 않은 상태에서 layout하라고 호출받았다. 테이블 뷰 또는 테이블 뷰의 superview 중 하나가 창에 추가되지 않은 상태이다 .. 이 작업을 방지하거나 테이블 뷰가 창에 보일 때까지 작업을 연기 해도 된다." 라고 디버그 창에 나와있었다.
         reloadSections()를 바로 호출하는 시점이 viewWillAppear이면 안되는 것 같다. viewDidAppear로 테이블 뷰가 보인 뒤에 작동하도록 하니 warning 사라짐.
         (viewWillAppear LifeCycle 시점에 tableView는 아직 그려지지 않은 상태라고 봐야 할 것 같다.)
         
         2. 처음 viewWillAppear가 호출된 때에는 reload를 호출해주지 않아도 목록이 잘 띄워졌다. 최초로 뷰 컨트롤러가 보여질 때에는 데이터를 다 가져온 뒤에 tableView가 그려져서 인것 같다.
         그런데 목록 중 하나 타고 들어가서 즐겨찾기 해제를 하고 뒤로 나왔는데 목록의 개수가 그대로였다. 방금 삭제한Cell이 남아있어 눌러보니 삭제했던게 띄워지는게 아니라 그 다음 item이 띄워졌다. 맨 마지막 아이템을 눌러봤더니 앱이 비정상 종료됐다. (존재하지 않는 아이템 인덱스에 대한 참조여서 그런듯. fetch는 새로 했는데 tableView는 그대로여서 없는 아이템을 가리킴)
         즉, 테이블 뷰를 다시 그려야 하는 상황이 온 것이었다... (viewWillAppear 맨 마지막에 reload를 넣는 것은 1번에서 말한 것처럼 문제가 생겨서 viewDidAppear에 작성)
         
         그런데 이런 생각을 해보았다. 굳이 뷰가 그려질때마다 꼬박꼬박 reload를 해야할까?
         
         단순히 기존 items의 개수와 새로 fetch한 items의 개수로만 비교를 해서 그 수가 다른 경우에만 reload를 하는 것은 괜찮을까?
         (혹은 애초부터 fetchAllItems()를 호출 하기 전에 fetchAllItemsCount()를 먼저 호출 해서 self.items의 개수와 같은지를 먼저 비교한다거나)
         하지만 이렇게 하는 경우 검색 화면에서 어떤 검색을 해서 기존에 즐겨찾기에 추가되어있는 제품을 즐찾 해제하고 다른 제품 즐찾 추가를 한다면 문제가 생긴다. (개수는 어쨌든 같은걸로 간주되니까) 목록의 개수는 같아도 항목 자체가 바뀌어야 하는데 바뀌지 않는다.
         단순히 개수(비교)로만 판단하기에는 넘겨짚는 부분이 생겨 위험하기도 하고 고려해야 할 부분이 많아보인다. (현재 items의 개수와 DB내에 있는 items의 개수에 있어 경우의 수를 어느정도 생각해야하니..)
         
         DB의 값이 달라진 것에 대해 어떤 Observer같은걸 두지 않는 이상 언제나 reload는 해야할것 같다는게 일단 내린 결론이다.
         -> 일단은 간단하게 CoreDataHandler에 needToCheckData: Bool을 두어 구현해보았다. 최초에는 무조건 fetch하도록 기본값은 true로 해두었고
         Entity에 변경이 발생할 때마다 true로 바꾼다. false로는 이 VC에서 fetch - reload한 경우에만 변경되도록 하였다.
         */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SearchItemTableViewCell else {
            return SearchItemTableViewCell()
        }
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewCellTapped(_:)))
        cell.addGestureRecognizer(tapGestureRecognizer)
        cell.tag = indexPath.row
        
        let item = items[indexPath.row]
        
        cell.itemName.text = item.itemName
        cell.entpName.text = item.entpName
        
        return cell
    }
    
    @objc func tableViewCellTapped(_ sender: UITapGestureRecognizer){
        guard let cell = sender.view as? UITableViewCell else {
            return
        }

        if isEditing {  //edit 중인 상태인 경우
            cell.setSelected(!cell.isSelected, animated: true)  //toggle
            return
        }
        
        guard let detailViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchResultDetailViewController") as? SearchResultDetailViewController else {
            return
        }   //즐겨찾기 목록 클릭 시 넘어가는 상세 화면은 기존 화면을 재이용합니다.
        
        
        detailViewController.item = items[cell.tag]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let itemSeq: String = self.items[indexPath.row].itemSeq else {
            presentAlert(title: "스와이프 메뉴 실행 불가", message: "편집 모드로 들어가지 못했습니다. 다음에 다시 시도하세요.")
            return      //itemSeq를 얻지 못해 메소드 종료
        }
        
        //사용자가 스와이프 해서 delete버튼을 누른 경우
        if editingStyle == .delete {
            let result = CoreDataHandler.shared.deleteItem(itemSeq: itemSeq)
            
            if result { //성공적으로 DB에서 삭제한 경우
                self.items.remove(at: indexPath.row)        //현재 배열에서도 해당 인덱스 객체 삭제
                tableView.deleteRows(at: [indexPath], with: .fade)      //해당 Row 업데이트
                CoreDataHandler.shared.needToCheckData = false      //별도로 tableView를 reload할 필요는 없으므로 false로 변경
                
                if self.items.count == 0 {
                    editButtonItem.isEnabled = false  //삭제하다가 item 개수가 0개가 된 경우에 disable
                }
            }else {     //DB에서 삭제 실패
                presentAlert(title: "삭제 실패", message: "삭제에 실패하였습니다.")
            }
        }
    }
    
    ///Edit button을 누른 경우 작동
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        if !editing {   //Edit 모드가 끝났을 때 선택 된 것들이 남아있으면 선택 해제를 해주기 위한 부분
            for index in 0...items.count-1 {
                guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) else { continue }
                if cell.isSelected { cell.setSelected(false, animated: true) }
            }
            //더 나은 방법이 있을까..?
        }else {
            //EditMode인 경우
            
        }
    }
    
    @objc func deleteSelectedRows(_ sender: UIBarButtonItem){
        
    }
        
    func presentAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAlertAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
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
