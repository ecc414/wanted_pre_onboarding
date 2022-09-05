//
//  Weather.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/05.
//

import Foundation
import UIKit

//API로부터 받을 값을 저장할 모델
struct WeatherResponse : Decodable {
    let weather : [Weather]
    let main    : Main
    let name    : String
}

struct Preview {
    let city     : String
    let temp     : Double
    let humidity : Double
    var icon     : String
}

struct Main : Decodable {
    let humidity : Double
    let temp     : Double
    let temp_min : Double
    let temp_max : Double
}

struct Weather : Decodable {
    let id          : Int
    let main        : String
    let description : String
    let icon        : String
}
