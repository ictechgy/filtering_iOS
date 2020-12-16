//
//  NetworkHandler.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

class NetworkHandler {
    
    ///singletone
    static let shared: NetworkHandler? = NetworkHandler()
    
    private var apiKey: String
    private let requestURL: String = "http://apis.data.go.kr/1471057/NonMdcinPrductPrmisnInfoService/getNonMdcinPrductPrmisnInfoList"
    private let urlSession: URLSession = URLSession.shared
    
    //제대로 파일 값을 읽어오지 못하는 경우 nil을 반환합니다. failable
    private init?(){
        //plist로부터 읽어오기, 싱글톤 객체 생성 시 최초 1회 작동
        guard let path = Bundle.main.path(forResource: "keys", ofType: "plist") else {
            return nil
        }
        
        let plistURL = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: plistURL) else {
            return nil
        }
        
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            return nil
        }
        
        guard let retrievedKey = plist["ServiceKey"] else {
            return nil
        }
        
        self.apiKey = retrievedKey
    }
    
    ///사용자가 검색한 값을 기반으로 서버로부터 데이터를 가져옵니다.
    func getContents(itemName nameOfItem: String, pageNum numberOfPage: Int = 1, numOfRows numberOfRowsPerPage: Int = 20, resultHandler: @escaping (Result<Data, NetworkErrorType>) -> Void) {
        
        //서버와 통신
        var urlComponents = URLComponents(string: requestURL)
        let serviceKey = URLQueryItem(name: "serviceKey", value: apiKey)
        let itemName = URLQueryItem(name: "item_name", value: nameOfItem.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let pageNo = URLQueryItem(name: "pageNo", value: "\(numberOfPage)")
        let numOfRows = URLQueryItem(name: "numOfRows", value: "\(numberOfRowsPerPage)")
        
        guard ((urlComponents?.percentEncodedQueryItems = [serviceKey, itemName, pageNo, numOfRows]) != nil), let url = urlComponents?.url else {
            return resultHandler(.failure(.componentError("URL 컴포넌트 변환 중 오류 발생")))
        }
        //이부분에서 조금 고생했다.
        //URLComponents.url을 하면 자동으로 내부 QueryItem들이 PercentEncoding이 된다.
        //apiKey는 이미 인코딩 되어있는데 또 인코딩해서 자꾸 오류가 발생했다.
        //그래서 전부 percentEncodedQueryItems라고 해서 이미 인코딩 된 것으로 넣어줬고, nameOfItem만 별도로 미리 따로 인코딩 해줬다.
        
        let urlSessionTask: URLSessionTask = urlSession.dataTask(with: url) { (data, response, error) in
            //async
            
            guard let data = data else{
                return DispatchQueue.main.async {
                    resultHandler(.failure(.fetchError("데이터를 받아오지 못했습니다.")))
                }
            }
            
            DispatchQueue.main.async {
                resultHandler(.success(data))
            }
        }
        
        urlSessionTask.resume()
    }
    
    enum NetworkErrorType: Error {
                
        case applicationError(Int = 1, String = "서비스 제공 상태가 원활하지 않습니다.")
        case databaseError(Int = 2, String = "서비스 제공 상태가 원활하지 않습니다.")
        case noData(Int = 3, String = "데이터 없음")
        case httpError(Int = 4, String = "서비스 제공 상태가 원활하지 않습니다.")
        case serviceTimeOut(Int = 5, String = "서비스 제공 상태가 원활하지 않습니다.")
        case invalidRequestParameterError(Int = 10, String = "요청 URL이 잘못되었습니다.")
        case missingRequiredRequestParameter(Int = 11, String = "필수 파라미터가 누락되었습니다.")
        case serviceRetired(Int = 12, String = "해당 서비스는 폐기되었습니다.")
        case accessDenied(Int = 20, String = "서비스 접근 거부")
        case serviceRequestLimitExceededError(Int = 22, String = "일일 요청 제한 초과")
        case unRegisteredServiceKey(Int = 30, String = "등록되지 않은 키")
        case expiredServiceKey(Int = 31, String = "기한만료된 키")
        case wrongDomainName(Int = 32, String = "등록되지 않은 도메인명입니다.")
        
        case componentError(String)
        case fetchError(String)
        case unknownError
    }
}
