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
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    
    //MARK: - ViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        intialSetUp()
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
    
    
    @IBAction func didSelectFahrenheit(_ sender: Any) {
        viewModel.getFahrenheit { temp in
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(temp)°"
                self.fahrenheitButton.titleLabel?.tintColor = UIColor.black
                self.celsiusButton.titleLabel?.tintColor = UIColor.gray
            }
        }
    }
    
    @IBAction func didSelectCelsius(_ sender: Any) {
        viewModel.getCelsius { temp in
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(temp)°"
                self.fahrenheitButton.titleLabel?.tintColor = UIColor.gray
                self.celsiusButton.titleLabel?.tintColor = UIColor.black
            }
        }
    }
    //MARK: Custom Methods
    
    //Method which will performs Location Management
    private func setupLocation(){
        locationManager.delegate = self
        // Ask for Authorisation from the User.
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func intialSetUp() {
        searchButton.setImageTintColor(UIColor.black)
        fahrenheitButton.titleLabel?.tintColor = UIColor.black
        celsiusButton.titleLabel?.tintColor = UIColor.gray
        if cityTextField.text == "" {
           hideElements(hide: true)
        }
    }
    
    private func hideElements(hide: Bool) {
        cityNameLabel.isHidden = hide
        descriptionLabel.isHidden = hide
        temperatureLabel.isHidden = hide
        fahrenheitButton.isHidden = hide
        celsiusButton.isHidden = hide
    }
    
    // Method which will fetch temperature details from city
    private func performSerch(city: String){
        UserDefaults.standard.set(city, forKey: "Location")
        viewModel.fetchWeatherDetailsByCity(city: city){ [weak self] data, error in
            guard let data = data else {
                self?.showAlert(title: "Please Enter a valid City", message: "Data not found")
                return
            }
            self?.updateUIElements(data: data)
        }
    }
    
    // Method which will fetch temperature details from Location Details
    
    private func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let longitude = currentLocation.coordinate.longitude
        
        let latitude = currentLocation.coordinate.latitude
        
        do {
            try viewModel.fetchWeatherDetailsByLocation(latitude: latitude, longitude: longitude) { [weak self] data, error in
                guard let data = data else {
                    self?.showAlert(title: "Alert", message: "Data not found")
                    return
                }
                self?.updateUIElements(data: data)
                
            }
        } catch let error {
            switch error {
            case weatherError.invalidLocation:
                showAlert(title: "failed to  fetch weather", message: "Please enter city name ")
            default:
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateUIElements(data: WeatherDataViewModel){
        DispatchQueue.main.async { [weak self] in
            self?.cityNameLabel.text = "\(data.weatherDetails.location) Temperature"
            self?.temperatureLabel.text = "\(data.temperature)°"
            self?.descriptionLabel.text = data.weatherDetails.description
            self?.hideElements(hide: false)
        }
        do{
            try self.viewModel.getWeatherImageFromIcon(icon: data.weatherDetails.icon) { [weak self] image in
                DispatchQueue.main.async {
                    self?.weatherImageView.image = image
                }
            }
        } catch{
            self.showAlert(title: "Alert", message: "Unable to fetch weather Image")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){ [weak self] _ in
            self?.temperatureLabel.text = ""
            self?.descriptionLabel.text = ""
            self?.cityNameLabel.text = ""
            self?.weatherImageView.image = nil
            self?.fahrenheitButton.isHidden = true
            self?.celsiusButton.isHidden = true
            self?.cityTextField.text = ""
            UserDefaults.standard.removeObject(forKey: "Location")
        }
        alertController.addAction(okAction)
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

