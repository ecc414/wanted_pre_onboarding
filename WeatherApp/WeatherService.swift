//
//  WeatherService.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/05.
//

import Foundation

//에러 정의
enum NetWorkError : Error{
    case badUrl
    case noData
    case decodingError
}

class WeatherService {
    
    //PropertyList.plist에서 API_KEY 가져오기
    private var apiKey : String {
        get{
            //PropertyList.plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "PropertyList", ofType: "plist") else {
                fatalError("Couldn't find the file 'PropertyList.plist'.")
            }
            
            //PropertyList.plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            //딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find the key 'OPENWEATHERMAP_KEY' in 'PropertyList.plist'.")
            }
            
            return value
        }
    }
    func getWeather(city : String, completion: @escaping (Result<WeatherResponse,NetWorkError>) -> Void){
        //API 호출을 위한 URL
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&lang=kr&units=metric")
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url){ data, response, error in
            guard let data = data, error == nil else{
                return completion(.failure(.noData))
            }
            
            //Data 타입으로 받은 리턴을 디코드
            let weatherResponse = try?  JSONDecoder().decode(WeatherResponse.self, from: data)
            
            //성공
            if let weatherResponse = weatherResponse {
                print(weatherResponse)
                completion(.success(weatherResponse))   //성공한 데이터 저장
            }else {
                completion(.failure(.decodingError))
            }
        }.resume()  //이 dataTask 시작
    }
    
}
