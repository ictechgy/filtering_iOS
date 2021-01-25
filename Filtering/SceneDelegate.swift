//
//  SceneDelegate.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /*
     앱이 처음 켜질 때 - scene -> sceneWillEnterForeground -> sceneDidBecomeActive
     제어센터를 내렸을 때 - sceneWillResignActive
     제어센터를 올려서 다시 화면으로 돌아왔을 때 - sceneDidBecomeActive
     화면 밑단을 끌어올려서 앱 목록들을 보고 있을 때 - sceneWillResignActive
     앱 목록화면에서 복귀 - sceneDidBecomeActive
     홈화면으로 이동 - sceneWillResignActive -> sceneDidEnterBackground
     홈화면에서 복귀 - sceneWillEnterForeground -> sceneDidBecomeActive
     화면 밑단을 끌어올려서 앱을 종료 할 경우 - sceneWillResignActive -> sceneDidDisconnect
     
     카톡이나 은행, 증권 앱들은 위의 메소드들을 이용하여 화면가리기를 하는 것으로 보인다.
     */

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        //기존에는 맨 위의 scene 메소드에 썼었는데 다크모드 변경을 (제어센터나 홈화면 이동등의 방법을 써서) 앱이 실행중인 상태에서도 가능하므로 이곳으로 옮겼다.
        //AppDelegate의 application(_, didFinishLaunchingWithOptions)에 써도 되지만... Scene이 하나이므로 이곳에 작성.
        //앱의 라이트모드 다크모드 설정
        let interfaceStyle: InterfaceStyle = InterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: appearanceKey)) ?? .default
        switch interfaceStyle {
        case .light:
            self.window?.overrideUserInterfaceStyle = .light
        case .dark:
            self.window?.overrideUserInterfaceStyle = .dark
        case .default:  //systemColor나 다크모드 지원 Asset을 추가/사용한 경우 모드에 따라서 색이 알아서 되겠지만 명시적으로 표기.
            self.window?.overrideUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

