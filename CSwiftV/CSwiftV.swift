//
//  CSwiftV.swift
//  CSwiftV
//
//  Created by Daniel Haight on 30/08/2014.
//  Copyright (c) 2014 ManyThings. All rights reserved.
//

import Foundation

//TODO: make these prettier and probably not extensions
public extension String {
    func splitOnNewLine () -> ([String]) {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}

//MARK: Parser
public class CSwiftV {
    
    public let columnCount: Int
    public let headers : [String] = []
    public let keyedRows: [[String : String]]?
    public let rows: [[String]]
    
    public init(String string: String, headers:[String]?) {
        
        let lines : [String] = includeQuotedStringInFields(Fields:string.splitOnNewLine().filter{(includeElement: String) -> Bool in
            return !includeElement.isEmpty;
        } , "\r\n")
        
        var parsedLines = lines.map{
            (transform: String) -> [String] in
            let commaSanitized = includeQuotedStringInFields(Fields: transform.componentsSeparatedByString(",") , ",")
                .map
                {
                    (input: String) -> String in
                    return sanitizedStringMap(String: input)
                }
                .map
                {
                    (input: String) -> String in
                    return input.stringByReplacingOccurrencesOfString("\"\"", withString: "\"", options: NSStringCompareOptions.LiteralSearch)
            }
            
            return commaSanitized;
        }

        if let unwrappedHeaders = headers {
            self.headers = unwrappedHeaders
        }
        else {
            self.headers = parsedLines[0]
            parsedLines.removeAtIndex(0)
        }

        self.rows = parsedLines

        self.columnCount = self.headers.count
        
        self.keyedRows = self.rows.map{ (field :[String]) -> [String:String] in
            
            var row = [String:String]()
            
            for (index, value) in enumerate(field) {
                row[self.headers[index]] = value
            }
            
            return row
        }
    }

//TODO: Document that this assumes header string
    public convenience init(String string: String) {
        self.init(String: string, headers:nil)
    }
    
}

//MARK: Helpers
func includeQuotedStringInFields(Fields fields: [String], quotedString :String) -> [String] {
    
    var mergedField = ""
    
    var newArray = [String]()
    
    for field in fields {
        mergedField += field
        if (mergedField.componentsSeparatedByString("\"").count%2 != 1) {
            mergedField += quotedString
            continue
        }
        newArray.append(mergedField);
        mergedField = ""
    }
    
    return newArray;
}


func sanitizedStringMap(String string :String) -> String {
    
    let doubleQuote : String = "\""
    
    let startsWithQuote: Bool = string.hasPrefix("\"");
    let endsWithQuote: Bool = string.hasSuffix("\"");
    
    if (startsWithQuote && endsWithQuote) {
        let startIndex = advance(string.startIndex, 1)
        let endIndex = advance(string.endIndex,-1)
        let range = startIndex ..< endIndex
        
        let sanitizedField: String = string.substringWithRange(range)
        
        return sanitizedField
    }
    else {
        return string;
    }
    
}
