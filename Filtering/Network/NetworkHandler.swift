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
    func getContents(itemName nameOfItem: String, pageNum numberOfPage: Int = 1, numOfRows numberOfRowsPerPage: Int = 20, resultHandler: @escaping (Result<Data, errorType>) -> Void) {
        
        //서버와 통신
        var urlComponents = URLComponents(string: requestURL)
        let serviceKey = URLQueryItem(name: "serviceKey", value: apiKey)
        let itemName = URLQueryItem(name: "item_name", value: nameOfItem)
        let pageNo = URLQueryItem(name: "pageNo", value: "\(numberOfPage)")
        let numOfRows = URLQueryItem(name: "numOfRows", value: "\(numberOfRowsPerPage)")
        
        guard ((urlComponents?.queryItems = [serviceKey, itemName, pageNo, numOfRows]) != nil), let url = urlComponents?.url else {
            return resultHandler(.failure(.componentError))
        }
        
        let urlSessionTask: URLSessionTask = urlSession.dataTask(with: url) { (data, response, error) in
            //async
            
            guard let data = data else{
                return DispatchQueue.main.async {
                    resultHandler(.failure(.fetchError))
                }
            }
            
            DispatchQueue.main.async {
                resultHandler(.success(data))
            }
        }
        
        urlSessionTask.resume()
    }
    
    enum errorType: Int, Error {
                
        case applicationError = 01
        case databaseError = 02
        case noData = 03
        case httpError = 04
        case serviceTimeOut = 05
        case invalidRequestParameterError = 10
        case missingRequiredRequestParameter = 11
        case serviceRetired = 12
        case accessDenied = 20
        case serviceRequestLimitExceededError = 22
        case unRegisteredServiceKey = 30
        case expiredServiceKey = 31
        case wrongDomainName = 32
        
        case componentError
        case fetchError
        case unknownError
    }
}
