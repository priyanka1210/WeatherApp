//
//  ViewController.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 30/03/23.
//

import UIKit
import CoreLocation
import Foundation


class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    let viewModel = WeatherDetailsViewModel()
    
    //IBOutlets Declarations
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    //MARK: - ViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocation()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // setupLocation()
        if currentLocation == nil {
            if let location = UserDefaults.standard.value(forKey: "Location") as? String {
                cityTextField.text = location
                performSerch(city: location )
            }
        }
    }
    //MARK: IBActions
    
    @IBAction func searchTapped(_ sender: Any) {
        if let city = cityTextField.text {
            performSerch(city: city)
        }
    }
    
    //MARK: Custom Methods
    
    //Method which will performs Location Management
    func setupLocation(){
        locationManager.delegate = self
        // Ask for Authorisation from the User.
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Method which will fetch temperature details from city
    func performSerch(city: String){
        UserDefaults.standard.set(city, forKey: "Location")
        viewModel.fetchWeatherDetailsByCity(city: city){ [weak self] location, desc, temp, icon in
            DispatchQueue.main.async {
                self?.cityNameLabel.text = "\(location) Temperature"
                self?.descriptionLabel.text = desc
                self?.temperatureLabel.text = temp
            }
            do {
                try WeatherDetailsViewModel().getWeatherImageFromIcon(icon: icon) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.weatherImageView.image = image
                    }
                }
            } catch let error {
                switch error {
                case IconError.invalidIcon :
                    print("Unable to makeURL from Icon")
                default:
                    print("Faile to make request")
                }
            }
            
        }
    }
    
    // Method which will fetch temperature details from Location Details
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let longitude = currentLocation.coordinate.longitude
        
        let latitude = currentLocation.coordinate.latitude
        
        viewModel.fetchWeatherDetailsByLocation(latitude: latitude, longitude: longitude) { [self] location,desc,  temperature, icon in
            DispatchQueue.main.async { [weak self] in
                self?.cityNameLabel.text = "\(location) Temperature"
                self?.temperatureLabel.text = temperature
                self?.descriptionLabel.text = desc
            }
            
            do{
                try viewModel.getWeatherImageFromIcon(icon: icon) { image in
                    DispatchQueue.main.async { [weak self] in
                        self?.weatherImageView.image = image
                    }
                }
            } catch{
                print(error.localizedDescription)
            }
            
        }
        
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        searchButton.imageView?.tintColor = UIColor.black
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.startUpdatingLocation()
            self.requestWeatherForLocation()
        }
    }
}

