//
//  ViewController.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/05.
//

import UIKit

//MARK: - ViewController
class ViewController: UIViewController{

    let cityList = ["Gongju":"공주","Gwangju":"광주","Gumi":"구미","Gunsan":"군산","Daegu":"대구","Daejeon":"대전","Mokpo":"목포","Busan":"부산","Seosan%20City":"서산","Seoul":"서울","Sokcho":"속초","Suwon-si":"수원","Suncheon":"순천","Ulsan":"울산","Iksan":"익산","Jeonju":"전주","Jeju%20City":"제주","Cheonan":"천안","Cheongju-si":"청주","Chuncheon":"춘천"]
    
    //데이터를 가져와서 담을 배열
    var infoList = [WeatherResponse]()
            
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToDetail" {
            if let destination = segue.destination as? DetailViewController {
                if let index = sender as? Int{
                    //두 번째 화면의 data 변수를, 첫 번째 화면에서 클릭한 도시의 index.item에 해당하는 데이터로 초기화
                    destination.data = infoList[index]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        print(cityList.count)
        super.viewDidLoad()
        //네이게이션 바 가림
        //isHidden = true 를 사용하면 두 번째 화면에서 돌아올 수 없다
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        
        collectionView.delegate   = self
        collectionView.dataSource = self
        
        //날씨 데이터를 가져와서 infoList에 넣는다. infoList 데이터를 collectionView에 삽입한다
        cityList.forEach{ info in
            WeatherService().getWeather(city:info.key){ result in
                switch result {
                case .success(var weatherResponse) :
                    DispatchQueue.main.async {
                        weatherResponse.name = info.value
                        self.infoList.append(weatherResponse)
                        self.collectionView.insertItems(at: [IndexPath(item: self.infoList.count-1, section: 0)])
                    }
                case .failure(_ ):
                    print("error")
                }
            }
        }
        
    }
}



//MARK: - Delegate
extension ViewController : UICollectionViewDelegate{
    //셀을 클릭하면 해당 셀의 indexPath.item을 넘김
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "moveToDetail", sender: indexPath.item )
    }
    
}



//MARK: - FlowLayout
extension ViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat = collectionView.frame.width - 20
        let height : CGFloat = collectionView.frame.height / 5
        return CGSize(width: width, height: height)
    }
}



//MARK: - DataSource
extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoList.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else{
            return UICollectionViewCell()
        }
        
        let iconCode = infoList[indexPath.row].weather.first!.icon

        //셀 배경화면 적용
        cell.setBackgroundView(cell.pickBackgroundImage(iconCode))
        
        //셀 모서리 둥글게
        cell.layer.cornerRadius = 10
        
        //도시, 온도, 습도
        cell.city.text = infoList[indexPath.row].name
        cell.temp.text = "현재 기온 : \(infoList[indexPath.row].main.temp)℃"
        cell.hum.text = "현재 습도 : \(infoList[indexPath.row].main.humidity)%"
        
        //캐시를 이용한 현재 날씨 아이콘 이미지 처리
        let url = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey){
            cell.icon.image = cachedImage
            return cell
        }
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, err) in
            DispatchQueue.main.async {
                if let data = data , let image = UIImage(data: data){
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    cell.icon.image = image
                }
            }
        }.resume()
        
        return cell
    }
 
}



//MARK: - 요약 정보를 나타내는 셀
class CustomCell : UICollectionViewCell {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var hum: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    //셀 배경 그림 적용
    func setBackgroundView(_ image:UIImage?){
        guard let image = image else { return }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.image = image
        self.backgroundView = UIView()
        self.backgroundView!.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
    }
    
    //현재 날씨에 맞는 셀 배경 그림 선택
    func pickBackgroundImage(_ code:String) -> UIImage?{
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
            return UIImage(named: "cloudy_day")
        case "03n","04n":
            return UIImage(named: "cloudy_night")
        case "09d","10d","50d":
            return UIImage(named: "rain_day")
        case "09n","10n","50n":
            return UIImage(named: "rain_night")
        case "11d":
            return UIImage(named: "thunderstorm_day")
        case "11n":
            return UIImage(named: "thunderstorm_night")
        case "13d":
            return UIImage(named: "snow_day")
        case "13n":
            return UIImage(named: "snow_night")
        default :
            return nil
        }
    }
}



//MARK: - 이미지 캐시
class ImageCacheManager{
    static let shared = NSCache<NSString, UIImage>()
    private init (){}
}


