//
//  Schedule+Notification+Date.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

import Foundation

extension Date {
    func formatted(as format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
