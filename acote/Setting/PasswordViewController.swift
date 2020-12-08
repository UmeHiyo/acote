//
//  PasswordViewController.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/11/10.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // この画面が閉じられたことを他の画面に伝える
        self.presentingViewController!.beginAppearanceTransition(true, animated: animated)
        self.presentingViewController!.endAppearanceTransition()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        if self.passwordTextField.text!.isEmpty || self.passwordTextField2.text!.isEmpty {
            SVProgressHUD.showError(withStatus: "すべての項目を入力してください")
            SVProgressHUD.dismiss(withDelay: 2)
            return
        }
        
        if self.passwordTextField.text! != self.passwordTextField2.text! {
            SVProgressHUD.showError(withStatus: "パスワードが一致しません")
            SVProgressHUD.dismiss(withDelay: 2)
            return
        }
        
        if let user = Auth.auth().currentUser {
            // HUDで処理中を表示
            SVProgressHUD.show()
            user.updatePassword(to: self.passwordTextField.text!) { error in
                if let error = error {
                    if AuthErrorCode(rawValue: error._code) == AuthErrorCode.requiresRecentLogin {
                        let alert: UIAlertController = UIAlertController(title: "注意", message: "最新のログイン情報が必要です。ログイン画面を開きます。", preferredStyle:  UIAlertController.Style.alert)
                        // OKボタン
                        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                            self.showLoginViewController()
                        })
                        // キャンセルボタン
                        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                            (action: UIAlertAction!) -> Void in
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    else {
                        // メールアドレス更新不可
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "パスワードが正しくありません")
                        SVProgressHUD.dismiss(withDelay: 2)
                        return
                    }
                    
                }
                print("DEBUG_PRINT: [displayName = \(String(describing: user.uid))]のパスワード設定に成功しました。")
                SVProgressHUD.showError(withStatus: "変更が完了しました！")
                SVProgressHUD.dismiss(withDelay: 1)
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showLoginViewController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        loginViewController.isFromSetting = true
        self.present(loginViewController, animated: true, completion: nil)
    }
}
