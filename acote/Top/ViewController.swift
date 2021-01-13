//
//  ViewController.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/09/24.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import Firebase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var changeViewSegment: UISegmentedControl!
    @IBOutlet weak var selectPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var haisouSegment: UISegmentedControl!
    // TODO：プロフィールの住所と照らし合わせてエラーにする
    @IBOutlet weak var honjitsuSegment: UISegmentedControl!
    @IBOutlet weak var dateSegment: UISegmentedControl!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var menuButton: UIButton!
    // 最初に処方箋を送信する時にユーザーのプロフィール情報が存在しないときはユーザー情報の登録を指示
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.selectPhotoLabel.text = "ここをタップして\n処方箋画像を選択"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.changeViewSegment.selectedSegmentIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        //セグメントが変更されたときの処理
        //選択されているセグメントのインデックス
        let selectedIndex = changeViewSegment.selectedSegmentIndex
        if selectedIndex == 1 {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.changeView), userInfo: nil, repeats: false)
            
        }
    }
    
    @objc func changeView() {
        self.performSegue(withIdentifier: "segue", sender: nil)
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "画像の選択方法を選んでください", message: nil, preferredStyle:  .actionSheet)
        // カメラボタン
        let cameraAction: UIAlertAction = UIAlertAction(title: "カメラを起動", style: .default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("カメラ")
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .camera
                self.present(pickerController, animated: true, completion: nil)
            }
        })
        // ライブラリボタン
        let libraryAction: UIAlertAction = UIAlertAction(title: "ライブラリ", style: .default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("ライブラリ")
            // フォトライブラリを表示する
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            }
            
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("キャンセル")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let myImage: AnyObject?  = info[UIImagePickerController.InfoKey.originalImage] as AnyObject
        self.imageView.image = myImage as? UIImage
        self.imageView.backgroundColor = .systemGray
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // ユーザー情報の取得
        // nilのときはプロフィール入力を促して送信処理をしない
        // 全て登録されているか
        SVProgressHUD.show(withStatus: "処方箋送信中")
        SVProgressHUD.dismiss(withDelay: 1.0)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.finishedSubmit), userInfo: nil, repeats: false)
        
    }
    
    @objc func finishedSubmit() {
        SVProgressHUD.showSuccess(withStatus: "送信完了しました！")
        SVProgressHUD.dismiss(withDelay: 0.8)
    }
}

