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
import CalculateCalendarLogic

class TopViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var changeViewSegment: UISegmentedControl!
    @IBOutlet weak var selectPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myView: UIView!
    // ⚠️セグメントの活性非活性はisEnabledへの代入を行わないこと！！
    @IBOutlet weak var haisouSegment: UISegmentedControl!
    @IBOutlet weak var honjitsuSegment: UISegmentedControl!
    @IBOutlet weak var dateSegment: UISegmentedControl!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var menuButton: UIButton!
    var existProfile = false
    var currentProfile: User!
    
    var limitedHour = 2
    // 最初に処方箋を送信する時にユーザーのプロフィール情報が存在しないときはユーザー情報の登録を指示
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.selectPhotoLabel.text = "ここをタップして\n処方箋画像を選択"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 日付セグメントに値を設定
        let dateArray = self.getArrayForDateSegment()
        for i in 0..<dateArray.count {
            self.dateSegment.setTitle(self.getDateString(date: dateArray[i]), forSegmentAt: i)
        }
        self.changeViewSegment.selectedSegmentIndex = 0
        self.checkSegments()
        self.checkSelectedSegmentIndex(segment: self.timeSegment)
        self.checkSelectedSegmentIndex(segment: self.dateSegment)
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
        SVProgressHUD.show(withStatus: "プロフィール取得中")
        SVProgressHUD.dismiss(withDelay: 0.8)
        // ユーザープロフィールの取得
        let userId = Auth.auth().currentUser!.uid // ログイン状態でしかこの画面を開けない
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("<<プロフィール取得エラー>>: documentの取得に失敗しました。 \(error)")
            }
            if let document = document, document.exists {
                print("<<プロフィール取得成功>>: 既存プロフィールデータがあります。")
                self.existProfile = true
                self.currentProfile = User(document: document)
            }
            else {
                print("<<プロフィールなし>>:　\(userId)←←←このユーザーのプロフィール情報はありません。")
            }
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
    
    // 受け取りor配達
    @IBAction func haisouSegmentChanged(_ sender: Any) {
        self.checkSegments()
        self.checkSelectedSegmentIndex(segment: self.dateSegment)
        self.checkSelectedSegmentIndex(segment: self.timeSegment)
    }
    
    // 本日or翌日以降
    @IBAction func honjitsuSegmentChanged(_ sender: Any) {
        self.checkSegments()
        self.checkSelectedSegmentIndex(segment: self.dateSegment)
        self.checkSelectedSegmentIndex(segment: self.timeSegment)
    }
    
    // 日付
    @IBAction func dateSegmentChanged(_ sender: Any) {
        self.checkSegments()
        self.checkSelectedSegmentIndex(segment: self.timeSegment)
    }
    
    // 送信ボタン
    @IBAction func submitButtonTapped(_ sender: Any) {
        // ユーザー情報の取得
        // nilのときはプロフィール入力を促して送信処理をしない
        // 町名に半角が含まれる場合は全角にする
        // 本日希望かつ受け取り希望時間を超える場合のエラー
        // 本日希望かつ配達可能時間を超える場合のエラー
        
        
        // プロフィール情報がない場合
        if !existProfile {
            SVProgressHUD.showError(withStatus: "メッセージを送信するには個人情報の登録が必要です。\n[MENU]\n↓\n[個人情報登録および変更]\n\n※登録済みの場合は少し待ってから再度お試しください。")
            return
        }
        // 処方箋画像がない場合
        if self.imageView.image == nil {
            SVProgressHUD.showError(withStatus: "処方箋画像を登録してください。")
            return
        }
        // 薬局で受け取り希望かつ時間選択されていない場合
        if self.haisouSegment.selectedSegmentIndex == 0 && self.timeSegment.selectedSegmentIndex == -1 {
            //
            SVProgressHUD.showError(withStatus: "時間を選択してください。\n選択できる時間が表示されない場合は翌日以降の日付を指定してください。")
            return
        }
        // 配達希望
        if self.haisouSegment.selectedSegmentIndex == 1 {
            // 配達できる住所じゃない場合
            let userAddress = self.currentProfile.address!
            let townNames = AddressUtil.townNames
            var canPostFlag = false
            for townName in townNames {
                if userAddress.contains(townName) {
                    canPostFlag = true
                }
            }
            if !canPostFlag {
                SVProgressHUD.showError(withStatus: "登録されている住所が配達可能エリアではありません。")
                return
            }
            // 本日希望で受付可能時間を過ぎている場合
            if  self.honjitsuSegment.selectedSegmentIndex == 0 {
                let now = Date()
                let current = Calendar.current
                let intHour = current.component(.hour, from: now)
                // 12時台までOKとする（13時を含まない）
                if intHour > 12 {
                    SVProgressHUD.showError(withStatus: "本日の配達希望受付時間を過ぎています。\n配達をご希望の場合は翌日以降の日付を指定してください。")
                    return
                }
            }
        }
        let prescRef = Firestore.firestore().collection("prescription").document()
        // 画像をJPEG形式に変換する
        let imageData = self.imageView.image!.jpegData(compressionQuality: 0.75)
        let imageRef = Storage.storage().reference().child("image").child(prescRef.documentID + ".jpg")
                // HUDで投稿処理中の表示を開始
                SVProgressHUD.show()
                // Storageに画像をアップロードする
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        // 画像のアップロード失敗
                        print(error!)
                        SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                        // 投稿処理をキャンセルし、先頭画面に戻る
                        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    let userId = Auth.auth().currentUser!.uid
                    var deliveryFlag = false
                    if self.haisouSegment.selectedSegmentIndex == 1 {
                        deliveryFlag = true
                    }
                    var pickUpDate = "希望日: " + self.dateSegment.titleForSegment(at: self.dateSegment.selectedSegmentIndex)! // 1/2
                    if !deliveryFlag {
                        pickUpDate += "　希望時間: " + self.timeSegment.titleForSegment(at: self.timeSegment.selectedSegmentIndex)!
                    }
                    
                    // ドキュメントIDは自動採番
                    let prescDic = [ "userId" : userId,
                                       "deliveryFlag" : deliveryFlag,
                                       "pickUpDate" : pickUpDate
                    ] as [String : Any]
                    prescRef.setData(prescDic)
                    // スクリーンショットを撮影してUserDefaultsに保存
                    let image = self.getImage(self.myView)
                    // imageをカメラロールに保存
                    // UserDefaultsの宣言
                    let ud = UserDefaults.standard
                    // UserDefaultsへ保存するとき
                    // UIImageをData型へ変換
                    let data = image.pngData()
                    // UserDefaultsへ保存
                    ud.set(data, forKey: "image")
                    // HUDで投稿完了を表示する
                    SVProgressHUD.showSuccess(withStatus: "処方箋を送信しました！")
                }
    }
    
    @objc func finishedSubmit() {
        SVProgressHUD.showSuccess(withStatus: "送信完了しました！")
        SVProgressHUD.dismiss(withDelay: 0.8)
    }
    
    // 現在日付から連続４日(日祝を除く)のDate配列を作成する
    private func getArrayForDateSegment() -> [Date] {
        var dateArray: [Date] = []
        let nowDate = Date()
        var nowIndex = 0
        let calendar = Calendar.current
        while dateArray.count < self.dateSegment.numberOfSegments {
            let addedDate = calendar.date(byAdding: .day, value: nowIndex + 1, to: nowDate)! // 現在日付からnowIndex + 1足した日付
            let calendarLogic = CalculateCalendarLogic()
            let year = calendar.component(.year, from: addedDate)
            let month = calendar.component(.month, from: addedDate)
            let day = calendar.component(.day, from: addedDate)
            let isHoliday: Bool = calendarLogic.judgeJapaneseHoliday(year: year, month: month, day: day)
            let weekday = self.getWeekDayIndex(date: addedDate)
            // 祝日でも日曜でもない場合のみ配列に追加
            if !isHoliday && weekday != 1 {
                dateArray.append(addedDate)
            }
            nowIndex += 1
        }
        return dateArray
    }
    // 1/20のような形式でStringを返却する
    private func getDateString(date: Date) -> String {
        var dateString = ""
        let current = Calendar.current
        let intMonth = current.component(.month, from: date)
        let intDay = current.component(.day, from: date)
        // 土曜日の場合は()をつける
        if self.getWeekDayIndex(date: date) == 7 {
            dateString = "( " + String(intMonth) + "/" + String(intDay) + " )"
        }
        else {
            dateString = String(intMonth) + "/" + String(intDay)
        }
        return dateString
    }
    
    
    // 現在選択のセグメントの状態から各セグメントの活性非活性を制御する
    private func checkSegments() {
        if self.haisouSegment.selectedSegmentIndex == 0 {
            if self.honjitsuSegment.selectedSegmentIndex == 0 {
                // ①受け取り希望かつ本日希望
                self.disableAllSegment(segment: self.dateSegment) // 日付全非活性
                self.disableLimitedTimeSegment() // 時間一部活性
            }
            else {
                self.enableAllSegment(segment: self.dateSegment) // 日付全活性
                let selectedDateIndex = self.dateSegment.selectedSegmentIndex
                let firstDate = self.dateSegment.titleForSegment(at: 0)!
                if selectedDateIndex == -1 {
                    if firstDate.contains("(") {
                        // 日付の最初が土曜日でまだどの日付も選択されていないとき
                        self.disableAllSegment(segment: self.timeSegment) // いったん時間全非活性
                        self.timeSegment.setEnabled(true, forSegmentAt: 0) // 10:00-12:00だけ活性化
                    }
                    else {
                        // 日付の最初が土曜日以外でまだどの日付も選択されていないとき
                        self.enableAllSegment(segment: self.timeSegment) // 時間全活性
                    }
                }
                else {
                    // 日付がなにかしら選択されている時
                    if self.dateSegment.titleForSegment(at: selectedDateIndex)!.contains("(") {
                        // 土曜日の場合
                        self.enableAllSegment(segment: self.dateSegment) // 日付全活性
                        self.disableAllSegment(segment: self.timeSegment) // いったん時間全非活性
                        self.timeSegment.setEnabled(true, forSegmentAt: 0) // 10:00-12:00だけ活性化
                    }
                    else {
                        self.enableAllSegment(segment: self.timeSegment) // 時間全活性
                    }
                }
            }
        }
        else {
            if self.honjitsuSegment.selectedSegmentIndex == 0 {
                // ④配達希望かつ本日希望
                self.disableAllSegment(segment: self.dateSegment) // 日付全非活性
                self.disableAllSegment(segment: self.timeSegment) // 時間全非活性
            }
            else {
                // ⑤配達希望かつ本日希望
                self.enableAllSegment(segment: self.dateSegment) // いったん日付全活性
                for i in 0..<self.dateSegment.numberOfSegments {
                    if self.dateSegment.titleForSegment(at: i)!.contains("(") {
                        // ()のついている土曜を非活性
                        self.dateSegment.setEnabled(false, forSegmentAt: i)
                    }
                }
                self.disableAllSegment(segment: self.timeSegment) // 時間全非活性
            }
            
        }
    }
    
    // 選択状態のセグメントを移動する
    private func checkSelectedSegmentIndex(segment: UISegmentedControl) {
        for i in 0..<segment.numberOfSegments {
            if segment.isEnabledForSegment(at: i) {
                // 最初に活性状態のセグメントが見つかったときにそのセグメントを選択状態にする
                segment.selectedSegmentIndex = i
                return
            }
            // 最後まで活性状態のセグメントが見つからなかった場合は選択状態のセグメントはなし
            segment.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
    
    // 時間セグメントの選択可能なものだけを活性化する
    private func disableLimitedTimeSegment() {
        let nowDate = Date() // 現在日時(例:2020/1/1 10:00)
        let addedDate = Calendar.current.date(byAdding: .hour, value: self.limitedHour, to: nowDate)! // 現在時刻からリミット時間を足した日時(例:2020/1/1 12:00)
        let intHour = Calendar.current.component(.hour, from: addedDate) // リミット時間を足した日時から時間のInt取得(例:12)
        var segmentIndex = 0
        for i in 0...3 {
//            if i == 1 {
//                // 12時台は飛ばす
//                continue
//            }
            let limitInt = 10 + (i*2)
            if limitInt > intHour {
                self.timeSegment.setEnabled(true, forSegmentAt: segmentIndex)
            }
            else {
                self.timeSegment.setEnabled(false, forSegmentAt: segmentIndex)
            }
            segmentIndex += 1
        }
    }
    
    // すべてのセグメントを非活性化する
    private func disableAllSegment(segment: UISegmentedControl) {
        for i in 0..<segment.numberOfSegments {
            segment.setEnabled(false, forSegmentAt: i)
        }
    }
    
    // すべてのセグメントを活性化する
    private func enableAllSegment(segment: UISegmentedControl) {
        for i in 0..<segment.numberOfSegments {
            segment.setEnabled(true, forSegmentAt: i)
        }
    }
    
    // 週番号の取得
    private func getWeekDayIndex(date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date)
    }
    
    // UIViewからUIImageに変換する
    private func getImage(_ view : UIView) -> UIImage {
        
        // キャプチャする範囲を取得する
        let rect = view.bounds
        
        // ビットマップ画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        // view内の描画をcontextに複写する
        view.layer.render(in: context)
        
        // contextのビットマップをUIImageとして取得する
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる
        UIGraphicsEndImageContext()
        
        return image
    }
}

