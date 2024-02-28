//
//  Date+.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import Foundation

extension Date {
    var convertFormmtedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: self)
    }
}
