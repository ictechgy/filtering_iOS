//
//  AppearanceViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/24.
//

import UIKit

let appearanceKey: String = "Appearance"
//다크모드 설정화면 VC
class AppearanceViewController: UITableViewController {
    
    lazy var userDefaults = UserDefaults.standard
    lazy var interfaceStyle: InterfaceStyle = {
        //저장되어있는 userDefault설정 값 없는 경우 0 반환 -> default로 인식
        InterfaceStyle(rawValue: userDefaults.integer(forKey: appearanceKey)) ?? .default
    }()
    lazy var symbolScaleConfiguration = UIImage.SymbolConfiguration(scale: .large)
    lazy var circleIcon: UIImage? = {
        let image = UIImage(systemName: "circle")
        image?.applyingSymbolConfiguration(symbolScaleConfiguration)
        return image
    }()
    lazy var checkmarkCircleIcon: UIImage? = {
        let image = UIImage(systemName: "checkmark.circle.fill")
        image?.applyingSymbolConfiguration(symbolScaleConfiguration)
        return image
    }()
    
    lazy var buttons: [UIButton] = {
        tableView.visibleCells.map {
            guard let cell = $0 as? AppearanceTableViewCell else {
                let tmpButton = UIButton()
                tmpButton.setImage(circleIcon, for: .normal)
                tmpButton.isUserInteractionEnabled = false
                return tmpButton
            }
            return cell.appearanceButton    //UserInteraction Disabled. 버튼부분이 눌려도 tableView(_, didSelectRowAt)이 작동되게 하기 위해.
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //일단 viewDidAppear이 되어야 테이블 뷰가 그려진 상태이고 그 이후에 lazy var buttons에서 visibleCells에 접근하는 것이 가능하다.
        for (i, button) in buttons.enumerated() {
            if i == interfaceStyle.rawValue {
                button.setImage(checkmarkCircleIcon, for: .normal)
            }else {
                button.setImage(circleIcon, for: .normal)
            }
        }
        //현재 시스템 설정 값 읽기
        //UITraitCollection.current.userInterfaceStyle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        userDefaults.setValue(interfaceStyle.rawValue, forKey: appearanceKey)   //상태 값 저장
    }
    //TODO: default상태 및 앱이 켜져있는 상태에서 제어센터를 통해 다크모드 온오프를 하는 경우 - tabBarController같은 곳의 viewWillAppear나.. SceneDelegate의 특정 메소드에서 해주면 되나?? or Observing?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buttons[interfaceStyle.rawValue].setImage(circleIcon, for: .normal)
        
        var userInterfaceStyle: UIUserInterfaceStyle
        switch indexPath.row {
        case 0:
            userInterfaceStyle = UITraitCollection.current.userInterfaceStyle   //.unspecified로 하면 안된다. 앱이 시작될 때 window에 설정 된 값을 따라가는 것으로 보임.
            interfaceStyle = .default
        case 1:
            userInterfaceStyle = .light
            interfaceStyle = .light
        case 2:
            userInterfaceStyle = .dark
            interfaceStyle = .dark
        default:
            return
        }
        buttons[interfaceStyle.rawValue].setImage(checkmarkCircleIcon, for: .normal)
        
        //컨트롤러 중 최상위에 tabBarController가 있음. UITraitCollection 아래로 쭉 전파
        self.tabBarController?.overrideUserInterfaceStyle = userInterfaceStyle
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
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

enum InterfaceStyle: Int {
    case `default` = 0
    case light = 1
    case dark = 2
}
