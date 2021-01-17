//
//  MaskAuthorizedListDetailViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/16.
//

import UIKit
import WebKit

class MaskAuthorizedListDetailViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var errorNoticeStackView: UIStackView!
    var itemSeq: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "상세 정보"
        
        //이 화면은 네비게이션 스택에서 단일경로로만 접근 가능(마스크 허가목록 화면에서의 접근만 가능)하므로 itemSeq를 이용한 웹뷰 URL 설정은 viewDidLoad나 viewWillAppear 어디서 하든 상관 없다.
        guard let contentURL = URL(string: "https://nedrug.mfds.go.kr/pbp/CCBBB01/getItemDetail?itemSeq=" + itemSeq) else {
            webView.isHidden = true
            errorNoticeStackView.isHidden = false
            return
        }
        
        let urlRequest = URLRequest(url: contentURL)
        webView.load(urlRequest)
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
