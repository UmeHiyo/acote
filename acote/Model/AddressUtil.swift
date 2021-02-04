//
//  AddressUtil.swift
//  acote
//
//  Created by Yuiko Umekawa on 2021/01/06.
//  Copyright © 2021 Yuiko Umekawa. All rights reserved.
//

import UIKit
import CoreLocation

struct AddressUtil {
    
    static let townNames = [
    "西禁町１",
    "西禁町２",
    "禁野本町１",
    "禁野本町２",
    "渚南町",
    "渚西１",
    "渚西２",
    "渚西３",
    "渚本町",
    "天之川町",
    "磯島北町",
    "磯島元町",
    "磯島南町",
    "磯島茶屋町",
    "中宮北町",
    "中宮本町",
    "宮之阪１",
    "宮之阪２",
    "上野１",
    "上野２",
    "御殿山町",
    "御殿山南町"
    ]
}
    
extension CLGeocoder {

    struct Address {
        var administrativeArea: String? // 都道府県 例) 東京都
        var locality: String? // 市区町村 例) 墨田区
        var subLocality: String? // 地名 例) 押上
    }

    func convertAddress(from postalCode: String, completion: @escaping (Address?, Error?) -> Void) {
        CLGeocoder().geocodeAddressString(postalCode) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let placemark = placemarks?.first {
                let location = CLLocation(
                    latitude: (placemark.location?.coordinate.latitude)!,
                    longitude: (placemark.location?.coordinate.longitude)!
                )
                 CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard let placemark = placemarks?.first, error == nil else {
                        completion(nil, error)
                        return
                    }
                    var address: Address = Address()
                    address.administrativeArea = placemark.administrativeArea
                    address.locality = placemark.locality
                    address.subLocality = placemark.subLocality
                    completion(address, nil)
                }
            }
        }
    }
}
