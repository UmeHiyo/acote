//
//  ProfileViewController.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/11/10.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var postNo1TextField: UITextField!
    @IBOutlet weak var postNo2TextField: UITextField!
    @IBOutlet weak var adressTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var sexSegment: UISegmentedControl!
    
    // 新規登録画面からの遷移時は戻るボタンを消す
    // 新規登録画面からの遷移時は登録するボタンを押した時に利用規約への同意を求める
    var isFromAccountViewController: Bool = false
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromAccountViewController {
            closeButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // この画面が閉じられたことを他の画面に伝える
        self.presentingViewController!.beginAppearanceTransition(true, animated: animated)
        self.presentingViewController!.endAppearanceTransition()
    }
    
}
