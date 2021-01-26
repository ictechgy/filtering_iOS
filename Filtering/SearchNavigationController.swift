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
    var networkMonitor: NWPathMonitor?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    //네트워크 연결 상태에 따라 메시지를 띄울려고 하는데.. 시뮬레이터에서는 네트워크 끊기를 할 수가 없으니 로컬 디바이스로 테스트 해보았다. 근데 연결이 없는 상태에서는 왜 앱 자체가 켜지지가 않는걸까. (네트워크를 끈 상태에서)미리 킨 상태인 앱을 들어가는 건 되는데 이때에는 네트워크 상태 변경에 따른 클로저 콜백이 안된다. pathUpdateHandler 등록 구문을 다 없애보고 다시 빌드 후 실행해보면, 네트워크가 없는 상태여도 앱은 잘 켜진다. 즉 pathUpdateHandler클로저쪽 문제라는 것인데.. -> 해결완료.
    
    //Search쪽 탭이 눌리면 핸들러를 등록하고 다른 탭이 눌리면 핸들러를 해지한다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkMonitor = NWPathMonitor()    //cancel을 한 경우 다시 생성해줘야 한다. cancel을 한 객체는 더이상 쓸 수 없음
        networkMonitor?.pathUpdateHandler = { [unowned self] path in
            //이 부분때문이었다. 네트워크 상태를 모니터링하고 이후에 콜백으로 작동하는 과정 자체가 전부 백그라운드 쓰레드에서 진행되다보니.. 이 부분에서 View에 대한 부분을 건드리면 메인쓰레드에서의 접근이 아니어서 문제가 생긴다.
            //이 핸들 클로저 등록 구문은 백그라운드에서 실행이 되며, 등록 시에도 최초 한번은 호출되는 것으로 보인다. (인터넷 연결 끊고 앱 켰을 시 알림이 뜬다.)
            DispatchQueue.main.async {
                if path.status == .unsatisfied {    //인터넷 연결에 되어있지 않은 경우
                    let alert = UIAlertController(title: "주의!", message: "인터넷 연결을 확인할 수 없습니다. 인터넷에 연결되어있지 않은 경우 검색이 불가할 수 있습니다.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    
                    alert.addAction(okAction)
                
                    self.visibleViewController?.present(alert, animated: true, completion: nil)
                }
                
            }
        }
        networkMonitor?.start(queue: DispatchQueue.global(qos: .background))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        networkMonitor?.cancel()
        networkMonitor?.pathUpdateHandler = nil
        networkMonitor = nil
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
