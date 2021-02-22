//
//  SignUpViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/02/15.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var nickNameCkLabel: UILabel!    //check label
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailCkLabel: UILabel!       //check label
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordCkLabel: UILabel!    //check label
    
    @IBOutlet weak var verifyPwField: UITextField!
    @IBOutlet weak var verifyPwCkLabel: UILabel!    //check label

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nickNameField.rx.text.orEmpty.
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
