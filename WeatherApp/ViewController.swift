//
//  ViewController.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/05.
//

import UIKit

class ViewController: UIViewController {
    
    //받아온 데이터를 저장할 프로퍼티
    var weather : Weather?
    var main    : Main?
    var name    : String?

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setWeatherUI()
        //data fetch
        WeatherService().getWeather{ result in
            switch result {
            case .success(let weatherResponse) :
                DispatchQueue.main.async {
                    self.weather = weatherResponse.weather.first
                    self.main    = weatherResponse.main
                    self.name    = weatherResponse.name
                    self.setWeatherUI()
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
    
    private func setWeatherUI() {
        let url = URL(string: "https://openweathermap.org/img/wn/\(self.weather?.icon ?? "00")@2x.png")

        let data = try? Data(contentsOf: url!)
        if let data = data{
            iconImageView.image = UIImage(data: data)
        }
        mainLabel.text = "\(weather?.main ?? "")"
        descriptionLabel.text = "\(weather?.description ?? "")"
        tempLabel.text = "\(main?.temp ?? 0.0)"
        maxTempLabel.text = "\(main?.temp_max ?? 0.0)"
        minTempLabel.text = "\(main?.temp_min ?? 0.0)"
    }

    
    


}


