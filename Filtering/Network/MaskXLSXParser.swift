//
//  MaskXLSXParser.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/11.
//

import Foundation
import CoreXLSX

class MaskXLSXParser {
    private init(){}
    
    static func parseXLSX(fileURL: URL, resultHandler: @escaping (Result<[MaskItem], Error>)->Void) {
        
        DispatchQueue.global().async {
            let filePath = fileURL.absoluteString
            guard let file: XLSXFile = XLSXFile(filepath: filePath) else{
                //do something
                return DispatchQueue.main.async {
                    resultHandler(.failure(XLSXParsingError.fileNotExist))
                }
            }
            
            do {
                let path = try file.parseWorksheetPaths().first
                guard let worksheetPath = path else {
                    throw XLSXParsingError.worksheetNotExist
                }
                let worksheet = try file.parseWorksheet(at: worksheetPath)
                
                var maskLists: [MaskItem] = []
                for (i, row) in worksheet.data?.rows.enumerated() ?? [].enumerated() {
                    if i == 0 { continue }  //맨 윗줄은 칼럼명으로써 스킵해줌
                    
                    let cells = row.cells
                    let mask = MaskItem(itemSeq: cells[0].value ?? "", itemName: cells[1].value ?? "", modelName: cells[2].value, entpName: cells[3].value ?? "", grade: MaskItem.Grade(rawValue: cells[4].value ?? nil) ?? .undefined, classification: MaskItem.MaskType(rawValue: cells[5].value ?? nil) ?? .undefined)
                    
                    maskLists.append(mask)
                }
                return DispatchQueue.main.async {
                    resultHandler(.success(maskLists))
                }
            } catch {
                return DispatchQueue.main.async {
                    resultHandler(.failure(error))
                }
            }
        }
    }
    
    enum XLSXParsingError: String, Error {
        case fileNotExist = "파일이 존재하지 않거나 손상되었습니다."
        case worksheetNotExist = "찾고자 하는 워크시트를 찾지 못했습니다."
    }
}
