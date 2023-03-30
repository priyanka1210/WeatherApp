//
//  WeatherDetailsViewModel.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import Foundation
import UIKit
import CoreLocation

enum IconError: Error {
    case invalidIcon
}

class WeatherDetailsViewModel {
    
    
    //function which fetches weather details by latitude and longitude
    
    func fetchWeatherDetailsByLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees , completion: @escaping (_ location: String, _ description: String,_ temperature: String,_ icon: String)  -> Void) {
        guard let url = URL(string: "http://api.openweathermap.org/geo/1.0/reverse?lat=\(latitude)&lon=\(longitude)&limit=5&appid=a87de3e978286424bf3e516ba15074d7") else {
            print("invalid Location URL")
            return
        }
        print(url)
        //API call to fetch city name
        WeatherDataWebService().fetchWeatherDetails(url: url) { [ weak self] data,error  in
            do {
                //JSON decoding
                let weatherResponse = try  JSONDecoder().decode([LocationName].self, from: data)
                guard let city = weatherResponse.first?.name else {
                    return
                }
                
                //Making API call using the city name fetched
                self?.fetchWeatherDetailsByCity(city: city) { location,desc,temperature, icon in
                    completion(location,desc,temperature, icon)
                }
            } catch  {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    //fetches weather details using city
    
    func fetchWeatherDetailsByCity(city: String, completion: @escaping (_ location: String, _ description: String,_ temperature: String,_ icon: String)  -> Void)  {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=a87de3e978286424bf3e516ba15074d7&units=imperial") else {
            print("Invalid URL")
            return
        }
        print(url)
        WeatherDataWebService().fetchWeatherDetails(url: url) { data, error  in
            do {
                let weatherResponse = try  JSONDecoder().decode(WeatherResponse.self, from: data)
                let location = weatherResponse.name
                let temp = weatherResponse.main.temp
                let icon = weatherResponse.weather.first?.icon
                let desc = weatherResponse.weather.first?.description
                if let icon = icon , let desc = desc {
                    completion(location,desc,"\(temp) °F", icon)
                }
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
       
    
    //fetches the WeatherIcon from the iconName passesd
    
    func getWeatherImageFromIcon(icon: String , completion: @escaping (UIImage) -> ()) throws {
        
        let imageCache = NSCache<AnyObject,UIImage>()
        if let cachedImage = imageCache.object(forKey: icon as NSString)
        {
            completion(cachedImage)
        }
        else
        {
            guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else {
                throw IconError.invalidIcon
            }
            WeatherDataWebService().getWeatherIconImage(url: url){ weatherIcon, error  in
                if let weatherIcon = weatherIcon {
                    imageCache.setObject(weatherIcon, forKey: icon as AnyObject)
                    completion(weatherIcon)
                }
                
            }
            
        }
    }
    
}
