//
//  WeatherDetailsViewModel.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import Foundation
import UIKit
import CoreLocation

enum weatherError: Error {
    case invalidIcon
    case invalidInfo
    case invalidLocation
}



class WeatherDetailsViewModel {
    
    private var weatherdataViewModel: WeatherDataViewModel?
    
    //function which fetches weather details by latitude and longitude
    func fetchWeatherDetailsByLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees , completion: @escaping (WeatherDataViewModel?,Error?) -> Void) throws {
        guard let url = URL(string: "http://api.openweathermap.org/geo/1.0/reverse?lat=\(latitude)&lon=\(longitude)&limit=5&appid=a87de3e978286424bf3e516ba15074d7") else {
            throw weatherError.invalidLocation
        }
        //API call to fetch city name
        WeatherDataWebService().fetchWeatherDetails(url: url) { [ weak self] data,error  in
            if let data = data {
                do {
                    //JSON decoding
                    let weatherResponse = try  JSONDecoder().decode([LocationName].self, from: data)
                    guard let city = weatherResponse.first?.name else {
                        return
                    }
                    
                    //Making API call using the city name fetched to get temp details
                    
                    self?.fetchWeatherDetailsByCity(city: city) { weatherDetails, error in
                        if let weatherDetails = weatherDetails {
                            completion(weatherDetails, nil)
                        }
                        
                    }
                } catch {
                    completion(nil,error)
                }
            } else {
                completion(nil,error)
            }
        }
        
        
    }
    
    
    //fetches weather details using city
    
    func fetchWeatherDetailsByCity(city: String, completion: @escaping (WeatherDataViewModel?, Error?)  -> Void)  {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=a87de3e978286424bf3e516ba15074d7&units=imperial") else {
            print("Invalid URL")
            return
        }
        print(url)
        WeatherDataWebService().fetchWeatherDetails(url: url) { [weak self] data, error  in
            if let data = data {
                do {
                    let weatherResponse = try  JSONDecoder().decode(WeatherResponse.self, from: data)
                    let location = weatherResponse.name
                    let temp = weatherResponse.main.temp
                    let icon = weatherResponse.weather.first?.icon
                    let desc = weatherResponse.weather.first?.description
                    if let icon = icon , let desc = desc {
                        let weatherDetails = WeatherDetails(location: location, description: desc, temperature: temp, icon: icon)
                        let vm = WeatherDataViewModel(weatherDetails: weatherDetails)
                        self?.weatherdataViewModel = vm
                        completion(vm, nil)
                    }
                } catch  {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
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
                throw weatherError.invalidIcon
            }
            WeatherDataWebService().getWeatherIconImage(url: url){ weatherIcon, error  in
                if let weatherIcon = weatherIcon {
                    imageCache.setObject(weatherIcon, forKey: icon as AnyObject)
                    completion(weatherIcon)
                }
                
            }
            
        }
    }
    
    func getCelsius(completion: @escaping (Double) -> Void)  {
        if let weatherdataViewModel = weatherdataViewModel {
            let temp = weatherdataViewModel.temperature
            weatherdataViewModel.temperature = (temp - 32) * 5/9
            completion(weatherdataViewModel.temperature.rounded(toPlaces: 2))
        }
    }
    
    
     func getFahrenheit(completion: @escaping (Double) -> Void)  {
        if let weatherdataViewModel = weatherdataViewModel {
            let temp = weatherdataViewModel.temperature
            weatherdataViewModel.temperature = (temp * 9/5) + 32
            completion(weatherdataViewModel.temperature.rounded(toPlaces: 2))
            
        }
    }
}


class WeatherDataViewModel {
    let weatherDetails: WeatherDetails
    var temperature: Double
    init(weatherDetails: WeatherDetails) {
        self.weatherDetails = weatherDetails
        self.temperature = weatherDetails.temperature
    }
    
}
