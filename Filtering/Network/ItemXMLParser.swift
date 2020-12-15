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
    func parseXML(xmlData: Data) {
        parser = XMLParser(data: xmlData)
        parser?.delegate = self
        //이 ItemXMLParser객체에서는 parser를 강한참조 하고 있지만 XMLParser클래스에서는 이 객체를 unowned로 참조한다.
        
        DispatchQueue.global().async { [weak self] in
            self?.parser?.parse()
        }
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
            self.parser?.abortParsing()
            //결과 return
            print(items)
            DispatchQueue.main.async {
                
            }
            
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
        
    }
}
