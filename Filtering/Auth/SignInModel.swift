//
//  SignInInfo.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/02/21.
//

import Foundation
import RxSwift
import FirebaseAuth

struct SignInInfo {
    var email: String
    var password: String
}

class SignInModel {
    
    static func signInWithInfo(info: SignInInfo)-> Observable<SignInResult>{
        return Observable.create { emitter in
            Auth.auth().signIn(withEmail: info.email, password: info.password) { result, error in
                
                if let error = error {  //error 발생 시 nil이 아닌 값이 넘어옴
                    emitter.onError(SignInResult.failure(error: error))
                }else {     //성공
                    emitter.onNext(SignInResult.success)
                    emitter.onCompleted()
                }
            }   //completion block - Invoked asynchronously on the main thread in the future.
            
            return Disposables.create()
        }
    }
}

enum SignInResult: Error {
    case success
    case failure(error: Error)
}
