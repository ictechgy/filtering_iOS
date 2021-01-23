//
//  SearchNavigationController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/23.
//

import UIKit
import Network

class SearchNavigationController: UINavigationController {
    
    //search쪽 작업들은 인터넷 연결이 필수적이다. 테스트 해보니 인터넷 연결이 없는 경우 의약외품 검색 및 마스크 목록 보기 진입 시 오류 발생 메시지와 함께 진입이 되지는 않는다.
    lazy var networkMonitor: NWPathMonitor = NWPathMonitor()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    //Search쪽 탭이 눌리면 핸들러를 등록하고 다른 탭이 눌리면 핸들러를 해지한다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkMonitor.pathUpdateHandler = { [unowned self] path in
            
            if path.status == .unsatisfied {    //인터넷 연결에 되어있지 않은 경우
                let alert = UIAlertController(title: "주의!", message: "인터넷 연결을 확인할 수 없습니다. 인터넷에 연결되어있지 않은 경우 검색이 불가할 수 있습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                self.visibleViewController?.present(alert, animated: true, completion: nil)
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        networkMonitor.cancel()
        networkMonitor.pathUpdateHandler = nil
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
