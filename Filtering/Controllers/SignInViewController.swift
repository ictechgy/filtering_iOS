//
//  SignInViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/02/08.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var forgotPwButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logInButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        forgotPwButton.addTarget(self, action: #selector(otherButtonsTapped(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(otherButtonsTapped(_:)), for: .touchUpInside)
    }
    
    //MARK:- Target Action
    @objc func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text, let pw = pwField.text else {
            presentAlert(title: "오류 발생", message: "이메일과 비밀번호를 읽는 도중 문제가 발생하였습니다. 다시 시도해주세요.", presentCompletion: nil, okCompletion: nil)
            return
        }
        //email, password 입력 값 검증
        switch verifyEmailAndPw(email: email, password: pw) {
        case .emptyEmail:
            presentAlert(title: "이메일을 입력하여 주십시오", message: "이메일 칸이 비어있습니다. 올바른 이메일을 입력하여 주십시오.", presentCompletion: nil) { [unowned self] _ in
                self.emailField.becomeFirstResponder()
                return
            }
        case .emptyPw:
            presentAlert(title: "비밀번호 형식 오류", message: "비밀번호 입력 칸이 비어있습니다. 올바른 비밀번호를 입력하여 주십시오.", presentCompletion: nil) { [unowned self] _ in
                self.pwField.becomeFirstResponder()
                return
            }
        case .unValidFormat:
            presentAlert(title: "이메일 형식 오류", message: "올바르지 않은 이메일 형식입니다. 다시 입력하여 주십시오.", presentCompletion: nil) { [unowned self] _ in
                self.emailField.becomeFirstResponder()
                return
            }
        case .validFormat: //서버와 통신
            <#code#>
        }
    }
    
    @objc func otherButtonsTapped(_ sender: UIButton) {
        switch sender {
        case forgotPwButton:
            <#code#>
        case signUpButton:
            <#code#>
        default:
            return
        }
    }
    
    //MARK:- Custom Methods
    func verifyEmailAndPw(email: String, password: String) -> logInValidity {
        if email.isEmpty { return .emptyEmail }
        else if password.isEmpty { return .emptyPw }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return predicate.evaluate(with: email) ? .validFormat : .unValidFormat
    }
    
    func presentAlert(title: String, message: String, presentCompletion: (()-> Void)?, okCompletion: ((UIAlertAction)-> Void)?) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAlertAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: okCompletion)
        alertController.addAction(okAlertAction)
        
        self.present(alertController, animated: true, completion: presentCompletion)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK:- Enum
    enum logInValidity {
        case emptyEmail              //이메일 입력창이 비어있음
        case emptyPw            //비밀번호 입력창이 비어있음
        case unValidFormat     //유효한 이메일 형식이 아님
        case validFormat        //유효한 이메일 형식
    }
}
