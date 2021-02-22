//
//  AuthViewModel.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/02/21.
//

import Foundation
import RxSwift
import RxCocoa

class AuthViewModel {
    var userEmail: PublishRelay<String> = PublishRelay()
    var emailValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var userPassword: PublishRelay<String> = PublishRelay()
    var passwordValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var logInAvailable: Driver<Bool>
    var tapLogIn: PublishRelay<Void> = PublishRelay()
    
    var disposeBag = DisposeBag()
    
    init() {
        userEmail.map(isEmailValid)
            .distinctUntilChanged()
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        
        userPassword.map(isPasswordValid)
            .distinctUntilChanged()
            .bind(to: passwordValid)
            .disposed(by: disposeBag)
        
        logInAvailable = Observable.combineLatest(emailValid, passwordValid) { $0 && $1 }
            .asDriver(onErrorJustReturn: false)
        
        
    }
    
    private func isEmailValid(email: String)-> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return predicate.evaluate(with: email)
    }
    
    private func isPasswordValid(password: String)-> Bool {
        return password.count > 0
    }
}
