//
//  SignInViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/02/08.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    //Variables
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var forgotPwButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var lodingIndicator: UIActivityIndicatorView!
    
    let segue2SignUpIdentifier = "segue2SignUp"
    let segue2ForgotPw = "segue2ForgotPw"

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logInButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        forgotPwButton.addTarget(self, action: #selector(otherButtonsTapped(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(otherButtonsTapped(_:)), for: .touchUpInside)
        
        //FirebaseApp.configure는 Analytics 이용으로 인해 SeceneDelegate에서 이미 호출
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
            lodingIndicator.startAnimating()
            Auth.auth().signIn(withEmail: email, password: pw) { [weak self] authResult, error in
                guard let self = self else {
                    return
                }
                self.lodingIndicator.stopAnimating()
                
                if let error = error {  //error 발생 시 nil이 아닌 값이 넘어온다.
                    self.handlingErrors(error: error as NSError)
                    return
                }
                //error가 nil일 시 로그인 성공
                self.loginSucceed()
            }
        }
    }
    
    @objc func otherButtonsTapped(_ sender: UIButton) {
        switch sender {
        case forgotPwButton:
            performSegue(withIdentifier: segue2ForgotPw, sender: self)
        case signUpButton:
            performSegue(withIdentifier: segue2SignUpIdentifier, sender: self)
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
    
    func handlingErrors(error: NSError) {
        var title: String
        var message: String
        switch error.code {
        case AuthErrorCode.invalidEmail.rawValue, AuthErrorCode.wrongPassword.rawValue:
            title = "로그인 실패"
            message = "이메일 또는 비밀번호가 올바르지 않습니다."
        case AuthErrorCode.networkError.rawValue:
            title = "네트워크 오류"
            message = "네트워크 연결을 확인하여 주십시오."
        case AuthErrorCode.userNotFound.rawValue:
            title = "계정 확인 불가"
            message = "사용자 계정을 찾을 수 없습니다."
        case AuthErrorCode.userTokenExpired.rawValue:
            title = "유저 로그인 인증정보 만료"
            message = "다시 로그인 해주십시오"
        case AuthErrorCode.tooManyRequests.rawValue:
            title = "비정상적인 로그인 시도 횟수"
            message = "비정상적인 로그인 시도가 감지되었습니다. 조금 후에 다시 시도하세요."
        case AuthErrorCode.invalidAPIKey.rawValue, AuthErrorCode.appNotAuthorized.rawValue, AuthErrorCode.keychainError.rawValue:
            title = "로그인 불가"
            message = "서버에 접근할 수 없습니다."
        case AuthErrorCode.internalError.rawValue:
            fallthrough
        default:
            title = "오류 발생"
            message = "알 수 없는 오류가 발생하였습니다."
        }
        self.presentAlert(title: title, message: message, presentCompletion: nil, okCompletion: nil)
    }
    
    func loginSucceed() {
        self.dismiss(animated: true, completion: nil)
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
