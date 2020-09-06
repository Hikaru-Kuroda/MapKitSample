//
//  ViewController.swift
//  MapKitSample
//
//  Created by 黑田光 on 2020/09/06.
//  Copyright © 2020 Hikaru Kuroda. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //storyboardのインスペクタエリアでmapViewのUser Locationにチェック
    @IBOutlet weak var mapView: MKMapView!
    
    let myLocationManager: CLLocationManager! = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザーに許可してもらう
        myLocationManager.requestWhenInUseAuthorization()
        
        //許可の結果(?)
        let status = CLLocationManager.authorizationStatus()
        myLocationManager.delegate = self
        
        //許可されてたら実行
        if (status == CLLocationManager.authorizationStatus()) {
            myLocationManager.distanceFilter = 10
            myLocationManager.startUpdatingLocation()
        }

        mapView.setCenter(mapView.userLocation.coordinate, animated: false)
        
        //mapViewにジェスチャーを追加
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longTap.delegate = self
        mapView.addGestureRecognizer(longTap)
    }
    
    //ロングタップのアクションを定義
    @objc func longTap(_ sender:UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            //タップされた座標を取得
            let tapPoint = sender.location(in: mapView)
            let pinPoint = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            //ピンを生成
            let pin = MKPointAnnotation()
            pin.coordinate = pinPoint
            
            //アラート画面を生成
            let alert = UIAlertController(title: "場所の名前を入力", message: "場所の名前を入力してください", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField(configurationHandler: nil)
            //追加ボタン
            let okAction = UIAlertAction(title: "追加", style: UIAlertAction.Style.default) { (UIAlertAction) in
                if let textField = alert.textFields?.first {
                    pin.title = textField.text
                    self.mapView.addAnnotation(pin)
                }
            }
            //キャンセルボタン
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //現在地の座標の取得
        //メソッドの引数のlocationsに入ってる緯度軽度(?)を取得してる
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        //中央の場所、縮尺の設定
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center = CLLocationCoordinate2DMake(latitude!, longitude!)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        //テスト用
        print(latitude!)
        print(longitude!)
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print(error)
    }
}
