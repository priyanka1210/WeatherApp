//
//  WeatherDataWebService.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import Foundation
import UIKit

enum weatherImageError: Error {
    case imageIconNotFound
}

class WeatherDataWebService {
    func fetchWeatherDetails(url: URL , completion: @escaping (Data, Error?) -> Void)   {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(data,nil)
            }
            
        }.resume()
    }
    
    func getWeatherIconImage(url: URL, completion: @escaping (UIImage?, Error?)  -> Void)   {
        DispatchQueue.global().async {
            do {
                // fetches Image data from URL
                let data = try Data(contentsOf: url)
                guard  let image = UIImage(data: data) else {
                    completion(nil, weatherImageError.imageIconNotFound)
                    return
                }
                completion(image, nil)
            } catch  {
                print("error in webservice file")
            }
            
        }
    }
}
