//
//  NetworkHandler.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation
import SwiftSoup

class NetworkHandler {
    
    ///singletone
    static let shared: NetworkHandler? = NetworkHandler()
    
    private var apiKey: String
    private let requestURL: String = "http://apis.data.go.kr/1471057/NonMdcinPrductPrmisnInfoService/getNonMdcinPrductPrmisnInfoList"
    private let urlSession: URLSession = URLSession.shared
    
    private var task: URLSessionTask?
    
    ///작업이 취소되었는지를 판별하는 프로퍼티
    private var isCanceled: Bool = false
    
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
    func getContents(searchMode: SearchMode, searchContent: String, pageNum numberOfPage: Int, numOfRows numberOfRowsPerPage: Int, resultHandler: @escaping (Result<Data, NetworkErrorType>) -> Void) {
        
        var searchValue: String?
        
        switch searchMode {
        case .itemName, .entpName:  //한글, 영어같은 값일 것이므로 인코딩 필요
            searchValue = searchContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        case .itemSeq, .classNo:    //숫자 값이므로 인코딩 필요 없음
            searchValue = searchContent
        }
        
        //서버와 통신
        var urlComponents = URLComponents(string: requestURL)
        let serviceKey = URLQueryItem(name: "serviceKey", value: apiKey)
        let content2Query = URLQueryItem(name: searchMode.rawValue, value: searchValue)
        let pageNo = URLQueryItem(name: "pageNo", value: "\(numberOfPage)")
        let numOfRows = URLQueryItem(name: "numOfRows", value: "\(numberOfRowsPerPage)")
        
        guard ((urlComponents?.percentEncodedQueryItems = [serviceKey, content2Query, pageNo, numOfRows]) != nil), let url = urlComponents?.url else {
            return resultHandler(.failure(.componentError("URL 컴포넌트 변환 중 오류 발생")))
        }
        //이부분에서 조금 고생했다.
        //URLComponents.url을 하면 자동으로 내부 QueryItem들이 PercentEncoding이 된다.
        //apiKey는 이미 인코딩 되어있는데 또 인코딩해서 자꾸 오류가 발생했다.
        //그래서 전부 percentEncodedQueryItems라고 해서 이미 인코딩 된 것으로 넣어줬고, 인코딩이 필요한 프로퍼티들만 별도로 미리 따로 인코딩 해줬다.
        
        isCanceled = false
        let urlSessionTask: URLSessionTask = urlSession.dataTask(with: url) { [unowned self] (data, response, error) in
            //async
            task = nil          //retain cycle을 유의한다. 그냥 익명클로저면 상관이 없는데 메소드가 실행되면 이 task자체를 NetworkHandler 객체에서 참조하고 있게 된다.
            //self뿐만 아니라 resultHandler에 대한 강한 참조도 그대로 있게 되므로 통신 완료 시 nil로 처리한다.
            
            guard let data = data else{
                var error: NetworkErrorType
                if self.isCanceled {    //만약에 사용자 취소에 의한 nil data라면..
                    error = .canceled
                    self.isCanceled = false     //초기값으로
                }else {
                    //TODO: (response as? HTTPURLResponse)?.statusCode를 얻어 각각의 오류에 맞는 처리 필요
                    error = .fetchError("데이터를 받아오지 못했습니다.")
                }
                return DispatchQueue.main.async {
                    resultHandler(.failure(error))
                }
            }
            
            DispatchQueue.main.async {
                resultHandler(.success(data))
            }
        }
        
        urlSessionTask.resume()
        task = urlSessionTask
    }
    
    func abortNetworking() {
        isCanceled = true
        task?.cancel()  //cancel 할 시 dataTask에서 완료 콜백 클로저 handler가 data nil인 상태로 작동
        task = nil
    }
    
    ///허가된 마스크 목록 개수를 스크래핑 해오는 메소드
    func scrapingNumberOfMasks(resultHandler: @escaping (Result<Int, Error>) -> Void){
        //GCD or OperationQueue?
        
        
        DispatchQueue.global().async {
            guard let scrapURL: URL = URL(string: "https://nedrug.mfds.go.kr/pbp/CCBCC01/getList?totalPages=439&page=1&limit=10&sort=&sortOrder=&searchYn=&itemSeq=&itemName=&maskModelName=&entpName=&grade=&classNo=#none") else {
                return resultHandler(.failure(ScrappingErrors.urlError as Error))
            }
            do {
                let content = try String(contentsOf: scrapURL)
                let doc: Document = try SwiftSoup.parse(content)
                let divs: Elements = try doc.select("div.board_count")
                guard let div = divs.first() else {
                    throw ScrappingErrors.parsingError
                }
                let spans: Elements = try div.select("span[title]")
                guard let span = spans.first() else {
                    throw ScrappingErrors.parsingError
                }
                let numberOfMasksText: String = try span.text()
                let numberOfMasks = Int(numberOfMasksText.trimmingCharacters(in: ["총", "건", " "]).replacingOccurrences(of: ",", with: ""))
                guard let number = numberOfMasks else {
                    throw ScrappingErrors.managementError
                }
                DispatchQueue.main.async {
                    resultHandler(.success(number))
                }
            } catch {
                DispatchQueue.main.async {
                    resultHandler(.failure(error))
                }
            }
        }
    }
    
    ///허가된 마스크 목록을 엑셀파일로 받아오는 메소드
    func getMaskData(resultHandler: @escaping (Result<URL, MaskDataError>) -> Void) {
        guard let documentURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return resultHandler(.failure(.documentURLError))
        }
        let localFileURL: URL = documentURL.appendingPathComponent("maskData.xlsx") //local에 저장될 파일 경로 + 파일명
        
        guard let remoteFileURL = URL(string: "https://nedrug.mfds.go.kr/pbp/CCBCC01/getExcel") else {
            return resultHandler(.failure(.remoteFileURLError))
        }
        var urlRequest = URLRequest(url: remoteFileURL)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = ["Cache-Control":"max-age=0", "Connection":"keep-alive", "Content-Length":"117", "Content-Type":"application/x-www-form-urlencoded"]
        
        let urlSession = URLSession.shared
        let task = urlSession.downloadTask(with: urlRequest) { fetchedFileTempUrl, response, error in   //Async
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200, let fetchedFileTempUrl = fetchedFileTempUrl else {
                return DispatchQueue.main.async {
                    resultHandler(.failure(.fetchError))
                }
            }

            do {
                //아하! 파일에 접근할 때에는 URL의 absoluteString을 이용하거나 직접 경로를 입력하기보다 URL.path(또는 relative)를 쓰는게 정확하다.
                //absoluteString을 쓰는 경우 접두어로 file://이 붙게 되어 제대로 인식이 안되는 것 같고.. 직접 String으로 path를 써주는 경우에는 실수하면 안될 듯.
                if FileManager.default.fileExists(atPath: localFileURL.path) {
                    _ = try FileManager.default.replaceItemAt(localFileURL, withItemAt: fetchedFileTempUrl)
                }else {
                    try FileManager.default.copyItem(at: fetchedFileTempUrl, to: localFileURL)
                }
                return DispatchQueue.main.async {
                    resultHandler(.success(localFileURL))
                }
            } catch {
                return DispatchQueue.main.async {
                    resultHandler(.failure(.move2LocalError))
                }
            }
            
        }
        
        task.resume()
    }
    
    func abortMaskNetworking() {
        
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
        case canceled
        case unknownError
    }
    
    enum MaskDataError: String, Error {
        case documentURLError = "저장경로 접근 중 오류 발생"
        case remoteFileURLError = "원격지 URL 오류"
        case fetchError = "파일을 받아오지 못했습니다."
        case move2LocalError = "파일을 저장하던 중 오류 발생"
    }
    
    enum ScrappingErrors: String, Error {
        case urlError = "통신 URL상의 오류"
        case parsingError = "파싱 오류"
        case managementError = "값 변환 상의 오류"
    }
}
