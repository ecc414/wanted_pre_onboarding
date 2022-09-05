//
//  ViewController.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/05.
//

import UIKit

class ViewController: UIViewController{
    
    //공주, 광주(전라남도), 구미, 군산, 대구, 대전, 목포, 부산, 서산, 서울, 속초, 수원, 순천, 울산, 익산, 전주, 제주시, 천안, 청주, 춘천
//    let cityList = ["Gongju","Gwangju","Gumi","Gunsan","Daegu","Daejeon","Mokpo","Busan","Seosan","Seoul","Sokcho","Suwon","SunCheon","Ulsan","Iksan","Jeonju","Jeju","Cheonan","Cheongju","Chuncheon"]
    let cityList = ["Gongju":"공주","Gwangju":"광주","Gumi":"구미","Gunsan":"군산","Daegu":"대구","Daejeon":"대전","Mokpo":"목포","Busan":"부산","Seosan City":"서산","Seoul":"서울","Sokcho":"속초","Suwon-si":"수원","Suncheon":"순천","Ulsan":"울산","Iksan":"익산","Jeonju":"전주","Jeju City":"제주","Cheonan":"천안","Cheongju-si":"청주","Chuncheon":"춘천"]
    
    var previewList = [Preview]()
            
    @IBOutlet weak var collectionView: UICollectionView!
    
    //화면 회전 시 뷰 다시 그림
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.delegate   = self
        collectionView.dataSource = self
        
        cityList.forEach{ info in
            WeatherService().getWeather(city:info.key){ result in
                switch result {
                case .success(let weatherResponse) :
                    DispatchQueue.main.async {
                        let city     = info.value
                        let temp     = weatherResponse.main.temp
                        let humidity = weatherResponse.main.humidity
                        let icon     = weatherResponse.weather.first!.icon
                        self.previewList.append(Preview(city: city, temp: temp, humidity: humidity, icon: icon))
                        self.collectionView.insertItems(at: [IndexPath(item: self.previewList.count-1, section: 0)])
                    }
                case .failure(_ ):
                    print("error")
                }
            }
        }
        
    }

}

extension ViewController : UICollectionViewDelegate{
    
}

extension ViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat
        let height : CGFloat
        if collectionView.frame.width < collectionView.frame.height{ //세로
            width = collectionView.frame.width - 20
            height = collectionView.frame.height / 5
        }else{                                                       //가로
            width = collectionView.frame.width / 2 - 15
            height = collectionView.frame.height / 2
        }
        return CGSize(width: width, height: height)
    }
}

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewList.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else{
            return UICollectionViewCell()
        }
        let iconCode = previewList[indexPath.row].icon
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        let image = getBackgroundImage(iconCode)
        imageView.image = image
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        cell.layer.cornerRadius = 10
        
        //도시, 온도, 습도
        cell.city.text = previewList[indexPath.row].city
        cell.temp.text = "현재 기온 : \(previewList[indexPath.row].temp)℃"
        cell.hum.text = "현재 습도 : \(previewList[indexPath.row].humidity)%"
        
        //아이패드와 아이폰에 다른 텍스트 사이즈 적용
        cell.textSize(UIDevice.current.model)
        
        //낮과 밤에 다른 텍스트 색 적용
        if iconCode.last == "d" {
            cell.city.textColor = .black
            cell.temp.textColor = .black
            cell.hum.textColor = .black
        }else{
            cell.city.textColor = .white
            cell.temp.textColor = .white
            cell.hum.textColor = .white
        }
        
        //현재 날씨 아이콘 이미지 처리
        let url = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey){
            print("use cached Image")
            cell.icon.image = cachedImage
            return cell
        }
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, err) in
            print("get Image from url")
            DispatchQueue.main.async {
                if let data = data , let image = UIImage(data: data){
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    cell.icon.image = image
                }
            }
        }.resume()

        return cell
    }
    
    //현재 날씨에 맞는 배경화면
    func getBackgroundImage(_ code:String) -> UIImage?{
        switch code{
        case "01d":
            return UIImage(named: "clearsky_day")
        case "01n":
            return UIImage(named: "clearsky_night")
        case "02d":
            return UIImage(named: "fewClouds_day")
        case "02n":
            return UIImage(named: "fewClouds_night")
        case "03d","04d":
            return UIImage(named: "scatteredClouds_day")
        case "03n","04n":
            return UIImage(named: "scatteredClouds_night")
        case "09d","10d":
            return UIImage(named: "rain_day")
        case "09n","10n":
            return UIImage(named: "rain_night")
        case "11d":
            return UIImage(named: "thunderstorm_day")
        case "11n":
            return UIImage(named: "thunderstorm_night")
        case "13d":
            return UIImage(named: "snow_day")
        case "13n":
            return UIImage(named: "snow_night")
        case "50d":
            return UIImage(named: "mist_day")
        case "50n":
            return UIImage(named: "mist_night")
        default :
            return nil
        }
    }
        
}

class CustomCell : UICollectionViewCell {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var hum: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    func textSize(_ device : String){
        if device == "iPad"{
            city.font = .systemFont(ofSize: 50)
            temp.font = .systemFont(ofSize: 30)
            hum.font = .systemFont(ofSize: 30)
        }
    }
}

class ImageCacheManager{
    static let shared = NSCache<NSString, UIImage>()
    private init (){}
}

