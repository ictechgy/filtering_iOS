//
//  ItemXMLParser.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

class ItemXMLParser: NSObject, XMLParserDelegate {
    static let shared = ItemXMLParser()
    private var parser: XMLParser?
    private var resultHandler: ((Result<[NonMedicalItem], Error>, Int) -> Void)?
    
    ///파싱한 아이템이 담겨있는 배열
    var items: [NonMedicalItem] = []
    
    ///해당 검색어에 대해 서버에서 찾은 결과 값 개수
    var totalItemCount: Int = 0
    
    private var item: NonMedicalItem?
    private var currentElement: String?
    private var currentDocType: NonMedicalItem.DocType?
    private var currentArticle: NonMedicalItem.DocData.Article?
    
    private override init() {}
    
    ///Data를 받아 global dispatch queue를 이용해 비동기적으로 XML을 파싱합니다.
    func parseXML(xmlData: Data, resultHandler: @escaping ((Result<[NonMedicalItem], Error>, Int) -> Void)) {
        parser = XMLParser(data: xmlData)
        parser?.delegate = self
        //이 ItemXMLParser객체에서는 parser를 강한참조 하고 있지만 XMLParser클래스에서는 이 객체를 unowned로 참조한다.
        
        self.resultHandler = resultHandler    //참조
        DispatchQueue.global().async { [weak self] in
            self?.parser?.parse()
        }
    }
    
    func abortParse() {
        parser?.abortParsing()
        resultHandler = nil
        items = []
        parser = nil
    }
    
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        switch elementName {
        case "item":
            item = NonMedicalItem()
        case "EE_DOC_DATA":
            currentDocType = .EE
            item?.eeDocData = .init(title: .EE, articles: [])
        case "UD_DOC_DATA":
            currentDocType = .UD
            item?.udDocData = .init(title: .UD, articles: [])
        case "NB_DOC_DATA":
            currentDocType = .NB
            item?.nbDocData = .init(title: .NB, articles: [])
        case "ARTICLE":
            let articleTitle = attributeDict["title"] ?? ""
            currentArticle = .init(title: articleTitle, paragraphs: [])
        default:
            return
        }
        
    }
    
    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string == "" {
            return
        }
        
        switch currentElement {
        case "totalCount":
            totalItemCount = Int(string) ?? 0
        case "ITEM_SEQ":
            item?.itemSeq = string
        case "ITEM_NAME":
            item?.itemName = string
        case "PARAGRAPH":
            let paragraph = string.replacingOccurrences(of: "CDATA", with: "")
            currentArticle?.paragraphs.append(paragraph.trimmingCharacters(in: ["<", "!", "[", "]", ">"]))
        case "CLASS_NO":
            item?.classNo = string
        case "CLASS_NO_NAME":
            item?.classNoName = string
        case "ENTP_NAME":
            item?.entpName = string
        case "ITEM_PERMIT_DATE":
            item?.itemPermitDate = string
        case "CANCEL_CODE":
            item?.cancelCode = string
        case "CANCEL_DATE":
            item?.cancelDate = string
        default:
            return
        }
    }
    
    internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "item":
            guard let item = item else {
                return
            }
            items.append(item)
        case "items":
            //결과 return
            guard let resultHandler = resultHandler else {
                return
            }
            DispatchQueue.main.async { [self] in
                resultHandler(.success(items), totalItemCount)
                self.resultHandler = nil
                items = []
            }
            self.parser?.abortParsing()
            self.parser = nil
            
        case "ARTICLE":
            guard let currentArticle = currentArticle else {
                return
            }
            switch currentDocType {
            case .none:
                return
            case .EE:
                item?.eeDocData?.articles.append(currentArticle)
            case .UD:
                item?.udDocData?.articles.append(currentArticle)
            case .NB:
                item?.nbDocData?.articles.append(currentArticle)
            }
        default:
            return
        }
    }
    
    internal func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        if self.parser == nil {     //일부러 abort한 경우에는 아래쪽 구문 실행 안되도록
            return
        }
        
        guard let resultHandler = resultHandler else {
            return
        }
        DispatchQueue.main.async {
            resultHandler(.failure(parseError), self.totalItemCount)
            self.resultHandler = nil
        }
        items = []
        self.parser = nil
    }
}
