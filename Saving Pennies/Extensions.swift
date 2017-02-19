//
//  Extensions.swift
//  Saving Pennies
//
//  Created by Rajeé Jones on 8/20/16.
//  Copyright © 2016 Rajee Jones. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    static func loadJSONFromBundle(_ filename: String) -> Dictionary <String, AnyObject>? {
        var dataOK: Data
        var dictionaryOK: Dictionary<String, AnyObject> = [:]
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            let _: NSError?
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions()) as Data!
                dataOK = data!
            }
            catch {
                print("Could not load level file: \(filename), error: \(error)")
                return nil
            }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: dataOK, options: JSONSerialization.ReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as? Dictionary <String, AnyObject>)!
            }
            catch {
                print("Level file '\(filename)' is not valid JSON: \(error)")
                return nil
            }
        }
        return dictionaryOK
    }
}


