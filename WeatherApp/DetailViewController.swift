//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by 엄철찬 on 2022/09/06.
//

import Foundation
import UIKit


//MARK: - ViewController
class DetailViewController : UIViewController {
    //첫 번째 화면에서 클릭한 도시의 데이터로 초기화 될 변수
    var data : WeatherResponse?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {      
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        //네이게이션 바의 텍스트 색 변경
        self.navigationController?.navigationBar.tintColor = .white
        //현재 데이터에 맞는 날씨로 collectionView의 배경 화면 설정
        setBackgroundView(pickBackgroundImage())
    }
    
    //현재 데이터에 맞는 배경 그림 선정
    func pickBackgroundImage() -> UIImage? {
        guard let data = data else { return nil}
        switch data.weather.first?.icon {
        case "01d":
            return UIImage(named: "clearDay")
        case "01n":
            return UIImage(named: "clearNight")
        case "02d","03d","04d":
            return UIImage(named: "cloudyDay")
        case "02n","03n","04n":
            return UIImage(named: "cloudyNight")
        case "09d","10d","50d":
            return UIImage(named: "rainDay")
        case "09n","10n","50n":
            return UIImage(named: "rainNight")
        case "11d":
            return UIImage(named: "thunderDay")
        case "11n":
            return UIImage(named: "thunderNight")
        case "13d":
            return UIImage(named: "snowDay")
        case "13n":
            return UIImage(named: "snowNight")
        default :
            return nil
        }
    }
    
    //collectionView 배경 화면에 그림 적용
    func setBackgroundView(_ image : UIImage?){
        guard let image = image else {return}
        let backgroundView = UIImageView()
        backgroundView.image = image
        collectionView.backgroundView = backgroundView
    }

    
}


//MARK: - FlowLayout
extension DetailViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat
        let height : CGFloat
        if indexPath.item == 0{     //처음 셀은 크게
            width  = collectionView.frame.width - 20
            height = collectionView.frame.height / 2.5
        }else {                     //나머지 셀은 작게
            width  = collectionView.frame.width / 2 - 15
            height = collectionView.frame.height / 5
        }
        return CGSize(width: width, height: height)
    }
    
}


//MARK: - DataSource
extension DetailViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let data = data else { return UICollectionViewCell() }
          
            switch indexPath.item {
            case 0 :let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath) as! TitleCell  //첫 번째 셀
                //캐시된 이미지 활용
                cell.updateCell(data)
                return cell
            case 1 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath) as! CellWith3
                cell.updateCell(title: "온도", data)
                return cell
            case 2 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! CellWith1
                cell.updateCell(title: "기압", data)
                return cell
            case 3 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! CellWith1
                cell.updateCell(title: "가시거리", data)
                return cell
            case 4 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! CellWith2
                cell.updateCell(title: "바람", data)
                return cell
            case 5 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! CellWith1
                cell.updateCell(title: "습도", data)
                return cell
            case 6 : let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! CellWith1
                cell.updateCell(title: "구름", data)
                return cell
            default : return UICollectionViewCell()
            }
    }
  
}


//MARK: - Cell
class TitleCell : UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var city: UILabel!
    //셀 업데이트
    func updateCell(_ data:WeatherResponse){
        setData(data)
        cellShape()
    }
    //데이터를 받아 셀의 컴포넌트들에 내용 전달
    func setData(_ data:WeatherResponse){
        city.text = data.name
        temp.text = "\(data.main.temp)℃"
        setIcon(data)
    }
    //캐시를 활용한 아이콘 이미지 획득
    func setIcon(_ data:WeatherResponse){
        if let first = data.weather.first{
            descript.text = first.description
            let url = "https://openweathermap.org/img/wn/\(first.icon)@2x.png"
            let cacheKey = NSString(string: url)
            if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey){
                icon.image = cachedImage
            }
        }
    }
    
    func cellShape(){
        self.layer.cornerRadius = 10
    }
}

class CellWith1 : UICollectionViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var label1: UILabel!
    //셀 업데이트
    func updateCell(title:String,_ data:WeatherResponse){
        setData(title: title, data)
        cellShape()
    }
    //타이틀에 맞는 내용을 레이블에 전달
    func setData(title:String,_ data:WeatherResponse){
        cellTitle.text = title
        let text : String
        switch title{
        case "가시거리" :
            text = "\(data.visibility)m"
        case "습도" :
            text = "\(data.main.humidity)%"
        case "구름" :
            text = "\(data.clouds.all)%"
        case "기압" :
            text = "\(data.main.pressure)hPa"
        default :
            text = ""
        }
        label1.text = text
    }
    
    func cellShape(){
        self.layer.cornerRadius = 10
    }
    
}

class CellWith2 : UICollectionViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    //셀 업데이트
    func updateCell(title:String,_ data:WeatherResponse){
        setData(title: title, data)
        cellShape()
    }
    //타이틀에 맞는 내용을 레이블에 전달
    func setData(title:String,_ data:WeatherResponse){
        cellTitle.text = title
        let text  : String
        let text2 : String
        switch title{
        case "바람" :
            text  = "풍속 : \(data.wind.speed) m/s"
            text2 = "방향 : \(windDegree(data.wind.deg))"
        default :
            text  = ""
            text2 = ""
        }
        label1.text = text
        label2.text = text2
    }
    //풍향을 텍스트로 변환
    func windDegree(_ deg:Int) -> String{
        let direction : String
        switch deg{
        case 23...67:
            direction = "북동쪽"
        case 68...112:
            direction = "동쪽"
        case 113...157:
            direction = "남동쪽"
        case 158...202:
            direction = "남쪽"
        case 203...247:
            direction = "남서쪽"
        case 248...292:
            direction = "서쪽"
        case 293...337:
            direction = "북서쪽"
        default:
            direction = "북쪽"
        }
        return direction
    }
    
    func cellShape(){
        self.layer.cornerRadius = 10
    }
}

class CellWith3 : UICollectionViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    //셀 업데이트
    func updateCell(title:String,_ data:WeatherResponse){
        setData(title: title, data)
        cellShape()
    }
    //타이틀에 맞는 내용을 레이블에 전달
    func setData(title:String,_ data:WeatherResponse){
        cellTitle.text = title
        let text  : String
        let text2 : String
        let text3 : String
        switch title{
        case "온도" :
            text  = "최고 기온 : \(data.main.temp_max)℃"
            text2 = "최저 기온 : \(data.main.temp_min)℃"
            text3 = "체감 기온 : \(data.main.feels_like)℃"
        default :
            text  = ""
            text2 = ""
            text3 = ""
        }
        label1.text = text
        label2.text = text2
        label3.text = text3
    }
    
    func cellShape(){
        self.layer.cornerRadius = 10
    }
}
