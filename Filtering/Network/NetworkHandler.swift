//
//  NetworkHandler.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

class NetworkHandler {
    
    ///singletone
    static let shared = NetworkHandler()
    private init(){}
    
    private let urlString: String = "http://apis.data.go.kr/1471057/NonMdcinPrductPrmisnInfoService/getNonMdcinPrductPrmisnInfoList"
    private let urlSession: URLSession = URLSession.shared
    
    ///사용자가 검색한 값을 기반으로 서버로부터 데이터를 가져옵니다.
    func getContents(itemName: String, pageNum: Int = 1, numOfRows: Int = 20, resultHandler: @escaping (Result<[nonMedicalItem], errorType>) -> Void) {
        
        
        //plist로부터 읽어오기
        guard let path = Bundle.main.path(forResource: "keys", ofType: "plist") else {
            return resultHandler(.failure(.unknownError))
        }
        
        let plistUrl = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: plistUrl) else {
            return resultHandler(.failure(.unknownError))
        }
        
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            return resultHandler(.failure(.unknownError))
        }
        
        guard let apiKey: String = plist["ServiceKey"] else {
            return resultHandler(.failure(.unknownError))
        }
        
        
        //서버와 통신
        guard let url: URL = URL(string: urlString) else{
            return resultHandler(.failure(.unknownError))
        }
        
        
        
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
        
        case unknownError = 00
    }
}
