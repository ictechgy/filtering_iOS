//
//  MaskAuthorizedListViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class MaskAuthorizedListViewController: UIViewController {
    
    let dateKey: String = "DownloadedDate"  //파일을 마지막으로 다운 받은 시각에 대한 UserDefaults 키 값
    let numberKey: String = "NumberOfAuthorizedMasks" //마스크 허가목록 개수에 대한 UserDefaults 키 값

    lazy var parsingResultHandler: Result<[MaskItem], Error> = { [weak self] in
        
    }
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //이전 데이터를 다운 받은 시기로부터 12시간이 지났거나 데이터에서 row의 수가 달라진 경우/스크래핑을 통해 얻은 숫자 값이 달라진경우
        // -> 재다운로드
        decide2Download()
        
    }
    
    //MARK:- Custom Methods
    func decide2Download() {
        guard let lastDownloadedDateString = UserDefaults.standard.string(forKey: dateKey) else {
            getNewMaskLists()
            return
        }    //이전에 파일을 다운로드 받은 일시 불러오기
        let numberOfMasksLastFetched = UserDefaults.standard.integer(forKey: numberKey) //이전에 파악해둔 마스크 목록 개수 불러오기
        if numberOfMasksLastFetched == 0 { getNewMaskLists(); return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
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
                MaskXLSXParser.parseXLSX(fileURL: url, resultHandler: parsingResultHandler)
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
