//
//  Model.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import Foundation

struct WeatherResponse: Decodable {
    let name: String
    let main: Weather
    let weather: [TemperatureDetails]
}

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}


struct TemperatureDetails: Decodable {
    let icon: String
    let description: String
}


struct LocationName: Decodable {
    let name: String
}

struct WeatherDetails {
    let location: String
    let description: String
    let temperature: Double
    let icon: String
}
