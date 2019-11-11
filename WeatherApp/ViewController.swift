//
//  ViewController.swift
//  WeatherApp
//
//  Created by Apple on 10/18/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

struct WeatherResponseData : Codable {
    struct Weather : Codable {
        let airPressure : Float?
        let applicableDate : String
        let humidity : Int?
        let maxTemp : Float?
        let minTemp : Float?
        let weatherStateAbbr : String
        let weatherStateName : String
        let windDirectionCompass : String
        let windSpeed : Float?
    }

    let consolidatedWeather : [Weather]
}

class ViewController: UIViewController {
    private let _weatherApiUrl = "https://www.metaweather.com/"
    private let _londonWeatherEndpoint =  "api/location/44418"
    private let _weatherStateImgEndpoint = "static/img/weather/png/64/"
    
    private var _weatherResponseData : WeatherResponseData? = nil
    private var _currentIndex = 0
    
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtWeatherState: UILabel!
    @IBOutlet weak var txtTemperature: UILabel!
    @IBOutlet weak var txtWind: UILabel!
    @IBOutlet weak var txtHumidity: UILabel!
    @IBOutlet weak var txtAirPressure: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeatherData()
    }

    private func getWeatherData() {
        guard let weatherUrl = URL(string: _weatherApiUrl + _londonWeatherEndpoint) else { return }
        
        let task = URLSession.shared.dataTask(with: weatherUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try jsonDecoder.decode(WeatherResponseData.self, from: data)
                
                self._weatherResponseData = decodedData
                self.getWeatherImage(self._currentIndex)
                self.updateView(self._currentIndex)
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    private func getWeatherImage(_ index : Int) {
        guard let weatherResponseData = _weatherResponseData, let weatherImageUrl = URL(string: _weatherApiUrl + _weatherStateImgEndpoint +  weatherResponseData.consolidatedWeather[index].weatherStateAbbr + ".png") else { return }
        
        let task = URLSession.shared.dataTask(with: weatherImageUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self.imgWeather.image = UIImage(data: data)
            }
        }
        task.resume()
    }
    
    private func updateView(_ index : Int) {
        guard let weatherResponseData = _weatherResponseData else { return }
        
        DispatchQueue.main.async {
            self.txtDate.text = weatherResponseData.consolidatedWeather[index].applicableDate
            self.txtWeatherState.text = weatherResponseData.consolidatedWeather[index].weatherStateName
            self.txtTemperature.text = "from \(Int(round(weatherResponseData.consolidatedWeather[index].minTemp!)))°C to \(Int(round(weatherResponseData.consolidatedWeather[index].maxTemp!)))°C"
            self.txtWind.text = "\(Int(round(weatherResponseData.consolidatedWeather[index].windSpeed!))) mph \(weatherResponseData.consolidatedWeather[index].windDirectionCompass)"
            self.txtHumidity.text = "\(weatherResponseData.consolidatedWeather[index].humidity!)%"
            self.txtAirPressure.text = "\(Int(round(weatherResponseData.consolidatedWeather[index].airPressure!))) hPa"
        }
    }
    
    @IBAction func onPreviousBtnClick(_ sender: UIButton) {
        _currentIndex -= 1
        btnNext.isEnabled = true
        
        getWeatherImage(_currentIndex)
        updateView(_currentIndex)
        
        if _currentIndex == 0 {
            btnPrevious.isEnabled = false
        }
    }
    
    @IBAction func onNextBtnClick(_ sender: UIButton) {
        guard let weatherResponseData = _weatherResponseData else { return }
        
        _currentIndex += 1
        btnPrevious.isEnabled = true
        
        getWeatherImage(_currentIndex)
        updateView(_currentIndex)

        if _currentIndex + 1 == weatherResponseData.consolidatedWeather.count {
            btnNext.isEnabled = false
        }
    }
}

