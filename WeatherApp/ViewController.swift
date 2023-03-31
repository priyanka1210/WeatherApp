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
        viewModel.fetchWeatherDetailsByCity(city: city){ [weak self] location, desc, temp, icon, error in
            guard let location = location,let desc = desc, let temp = temp, let icon = icon else {
                self?.showAlert(title: "Alert", message: "Data not found")
                return
            }
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
                case weatherError.invalidIcon :
                    print("Unable to makeURL from Icon")
                default:
                    self?.showAlert(title: "Alert", message: error.localizedDescription)
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
        
        viewModel.fetchWeatherDetailsByLocation(latitude: latitude, longitude: longitude) { [weak self] location, desc, temperature, icon, error in
            guard let location = location,let desc = desc, let temperature = temperature, let icon = icon else {
                self?.showAlert(title: "Alert", message: "Data not found")
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.cityNameLabel.text = "\(location) Temperature"
                self?.temperatureLabel.text = temperature
                self?.descriptionLabel.text = desc
            }
            do{
                try self?.viewModel.getWeatherImageFromIcon(icon: icon) { image in
                    DispatchQueue.main.async { [weak self] in
                        self?.weatherImageView.image = image
                    }
                }
            } catch{
                self?.showAlert(title: "Alert", message: "Unable to fetch Weather by Location")
            }
            
        }
        
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){ [weak self] _ in
            self?.temperatureLabel.text = ""
            self?.descriptionLabel.text = ""
            self?.cityNameLabel.text = ""
            self?.weatherImageView.image = nil
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
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

