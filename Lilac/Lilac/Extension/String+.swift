//
//  String+.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(value: String) -> String {
        return String(format: self.localized, value)
    }
    
    func localized(values: [String]) -> String {
        return String(format: self.localized, arguments: values)
    }
}
