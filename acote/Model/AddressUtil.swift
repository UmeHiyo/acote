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
    
    let townNames = [
    "~町",
    "~町",
    "~町",
    "~町",
    "~町",
    "~町"
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
