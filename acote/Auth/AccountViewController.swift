//
//  AccountViewController.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/12/04.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AccountViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var mailTextField2: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! ProfileViewController
        nextViewController.isFromAccountViewController = true
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        // チェックしてからユーザー登録処理して遷移
        
        // どれかが空のとき
        if self.mailTextField.text!.isEmpty || self.mailTextField2.text!.isEmpty || self.passwordTextField.text!.isEmpty || self.passwordTextField2.text!.isEmpty {
            SVProgressHUD.showError(withStatus: "すべての項目に入力してください")
            return
        }
        if self.mailTextField.text! != self.mailTextField2.text! {
            SVProgressHUD.showError(withStatus: "メールアドレスが一致しません")
            SVProgressHUD.dismiss(withDelay: 2)
            return
        }
        if self.passwordTextField.text! != self.passwordTextField2.text! {
            SVProgressHUD.showError(withStatus: "パスワードが一致しません")
            SVProgressHUD.dismiss(withDelay: 2)
            return
        }
        // 利用規約への同意を求める
        // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
        Auth.auth().createUser(withEmail: self.mailTextField.text!, password: self.passwordTextField.text!) { authResult, error in
            if let error = error {
                // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "メールアドレスかパスワードが正しくありません。")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            print("DEBUG_PRINT: ユーザー作成に成功しました。")
            self.performSegue(withIdentifier: "toProfile", sender: nil)
        }
    }

}
