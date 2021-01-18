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
    
    func parseXLSX(fileURL: URL, resultHandler: @escaping (Result<[MaskItem], Error>)->Void) {
        
        DispatchQueue.global().async {
            let filePath = fileURL.path
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
                
                guard let sharedStrings = try file.parseSharedStrings() else {
                    throw XLSXParsingError.sharedStringError
                }
                
                var maskLists: [MaskItem] = []
                
                let extractTextFromCell: (Cell) -> String = {
                    $0.stringValue(sharedStrings) ?? $0.inlineString?.text ?? $0.value ?? ""
                }
                
                for (i, row) in worksheet.data?.rows.enumerated() ?? [].enumerated() {
                    if i == 0 { continue }  //맨 윗줄은 칼럼명으로써 스킵해줌
                    
                    let cells = row.cells
                    let mask = MaskItem(itemSeq: extractTextFromCell(cells[0]), itemName: extractTextFromCell(cells[1]), modelName: extractTextFromCell(cells[2]), entpName: extractTextFromCell(cells[3]), grade: MaskItem.Grade(rawValue: extractTextFromCell(cells[4])) ?? .undefined, classification: MaskItem.MaskType(rawValue: extractTextFromCell(cells[5])) ?? .undefined)
                    
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
        case sharedStringError = "SharedString관련 에러"
    }
}
