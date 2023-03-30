//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {

    func test_should_check_serch_functionality(){
        let viewController = ViewController()
        viewController.performSerch(city: "London")
        XCTAssertEqual(viewController.temperatureLabel.text, "59")
    }

}
