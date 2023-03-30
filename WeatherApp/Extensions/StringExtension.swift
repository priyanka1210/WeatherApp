//
//  StringExtension.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import Foundation

extension String {
    func escaped() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
