//
//  ItemXMLParser.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/13.
//

import Foundation

class ItemXMLParser: NSObject, XMLParserDelegate {
    static let shared = ItemXMLParser()
    
    var items: [NonMedicalItem] = []
    var totalItemCount: Int
    var item: NonMedicalItem
    
    var currentElement: String
    var currentDocType: NonMedicalItem.docType
    
    private override init() {}
    
    ///Data를 받아 global dispatch queue를 이용해 비동기적으로 XML을 파싱합니다.
    func parseXML(xmlData: Data) {
        let parser: XMLParser = XMLParser(data: xmlData)
        parser.delegate = self
        DispatchQueue.global().async {
            parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
         currentElement = elementName
        switch elementName {
        case "item":
            item = NonMedicalItem()
        case "EE_DOC_DATA":
            currentDocType = .EE
        case "UD_DOC_DATA":
            currentDocType = .UD
        case "NB_DOC_DATA":
            currentDocType = .NB
        default:
            return
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "totalCount":
            totalItemCount = Int(string) ?? 0
        case "ITEM_SEQ":
            item.itemSeq = string
        case "ITEM_NAME":
            item.itemName = string
        default:
            <#code#>
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }else if elementName == "items" {
            
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        <#code#>
    }
}
