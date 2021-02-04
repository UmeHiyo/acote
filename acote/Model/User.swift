//
//  User.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/12/08.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import Firebase

class User: NSObject {
    var id: String
    var name: String?
    var postNo: String?
    var address: String?
    var tel: String?
    var sex: String?
    var birthday: Date?
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        
        let userDic = document.data()!
        
        self.name = userDic["name"] as? String
        self.postNo = userDic["postNo"] as? String
        self.address = userDic["address"] as? String
        self.tel = userDic["tel"] as? String
        self.sex = userDic["sex"] as? String
        
        let timestamp = userDic["birthday"] as? Timestamp
        self.birthday = timestamp!.dateValue()
    }
}
