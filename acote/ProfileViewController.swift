//
//  ProfileViewController.swift
//  acote
//
//  Created by Yuiko Umekawa on 2020/11/10.
//  Copyright © 2020 Yuiko Umekawa. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
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
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
