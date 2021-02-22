//
//  UIDropDownView.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/29.
//
//  This swift file was created by referring to the posts posted on the following link: http://medium.com/@prathamsalvi27/ios-swift-dropdown-menu-3b2a69c34b23 - 'Prathamesh Salvi' medium blog, license: MIT
//  드롭다운 메뉴(안드로이드에서는 Spinner로 불린다)는 기본적으로 iOS에서 제공하는 UI요소가 아니다. 그러다보니 직접 구현해주어야 한다. (위의 medium 글을 참고하였다.)
//  https://github.com/AssistoLab/DropDown 의 오픈소스 라이브러리를 이용하여 쉽게 구현할 수도 있다.
//

import UIKit

//기존 코드를 조금 수정해서 쓰려고 한다. 전체적으로 보면 큰 틀은 TableView이다.
//주석은 나중에 다시 보기 쉽게 직접 작성하였다.

//MARK: - Protocols

//MARK: DataSource
///이 프로토콜을 채택하여 메소드 구현 후 DropDownView에 설정하면 안에 들어갈 Row의 수와 데이터를 지정할 수 있습니다.
@objc protocol UIDropDownViewDataSource {
    ///DropDownView에 보여질 행의 수를 지정
    /// - parameter identifier: DropDownView를 구분하는 고유 ID값(여러 DropDownView를 사용하는 경우 이용하세요)
    /// - Returns: number of rows to show
    @objc func dropDownView(numberOfRowsInDropDownViewWithID identifier: String) -> Int
    
    ///DropDownView의 각 셀에 데이터를 지정
    /// - parameters:
    ///   - cell: 데이터를 지정받을 셀
    ///   - index: cell이 위치하게 될 position index
    ///   - identifier: DropDownView를 구분하는 고유 ID
    /// - Returns: 반환 값은 없으며 parameter로 들어오는 cell에 데이터를 지정하기만 하면 됩니다.
    @objc func dropDownView(dequeuedCell cell: UITableViewCell, cellForRowAt index: Int, dropDownViewIdentifier identifier: String)
}

//MARK: Delegate
///이 프로토콜을 채택하여 메소드 구현 후 DropDownView에 설정하면 특정 아이템이 선택된 경우 어떤 행동을 할지 지정할 수 있습니다.
@objc protocol UIDropDownViewDelegate {
    ///DropDownView의 특정 아이템 셀이 선택된 경우 작동할 메소드
    /// - parameter index: 아이템 셀의 인덱스 값
    /// - parameter identifier: DropDownView를 구분하는 고유 ID
    @objc func dropDownView(didSelectRowAt index: Int, dropDownViewIdentifier identifier: String)
}

//MARK: - Class
///DropDownView - 콤보박스형 UIView
class UIDropDownView: UIView {
    
    //MARK: - Variables
    ///DropDownIdentifier는 여러개의 콤보박스를 사용하는 경우 각 객체를 구분하는 값이 됩니다.
    var dropDownViewIdentifier: String = "DROP_DOWN_VIEW"
    ///custom cell의 reusable identifier
    var dropDownViewCellReusableIdentifier: String = "DROP_DOWN_VIEW_CELL"
    
    ///DropDownView에 쓰일 TableView입니다. 이 TableView와 여러가지 효과를 이용하여 DropDownView를 만듭니다.
    var dropDownTableView: UITableView?
    ///View의 너비
    var width: CGFloat = 0
    ///View의 Y-frame position에 대한 offset 값
    var offset: CGFloat = 0
    
    //dataSource와 delegate - retain cycle에 주의한다. -> weak 약한 참조
    weak var dataSource: UIDropDownViewDataSource?
    weak var delegate: UIDropDownViewDelegate?
    
    //UINib - nib파일을 메모리에 캐시한다. 인스턴스화, 압축해제 준비용도로 쓰임. UITableViewCell같은 경우 Nib으로 미리 캐싱해두면 성능향상을 기대할 수 있다. (xib는 nib로 wrapping된다.)
    //동일한 xib 파일을 반복적으로 로드해서 쓰는 경우라면 nib파일로 미리 로드시키는 것이 좋다고 한다.
    var nib: UINib? {
        didSet {
            self.dropDownTableView?.register(nib, forCellReuseIdentifier: self.dropDownViewCellReusableIdentifier)
            //custom view cell에 대한 클래스와 xib파일을 만들고 연결한 뒤 nib로 cell xib를 캐싱한다. 이후에 해당 cell을 table view에 쓰려면 위의 register 과정을 거쳐야 한다.
            //tableView에 cell을 containing하는 nib object를 identifier이름과 함께 등록. cell을 deque하기 전에 tableView가 cell을 어떻게 생성할지 알게 해준다.
            //cell reusable identifier이름은 xib파일 내에서의 이름과 register에서 설정하는 forCellReuseIdentifier: 이름이 동일해야 한다.
        }
    }
    
    //MARK: Other Variables
    ///View 위치에 대한 참조 값
    var viewPositionRef: CGRect?
    ///DropDown이 현재 열려 있는지 여부
    var isDropDownPresent: Bool = false
    
    //MARK: - DropDown Methods
    ///UIDropDownView를 동적으로 생성하는 메소드
    func setUpDropDown(viewPositionReference: CGRect,  offset: CGFloat){
        self.addBorders()
        self.addShadowToView()
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + offset, width: 0, height: 0)
        dropDownTableView = UITableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        //위와같이 설정하는 이유는 DropDownView를 특정 프레임 하단에 위치시킬 것이기 때문이다. 클릭하면 아래에 DropDown이 뜨게 하기 위해 특정 뷰를 기준으로 한다. 
        self.width = viewPositionReference.width
        self.offset = offset
        self.viewPositionRef = viewPositionReference
        dropDownTableView?.showsVerticalScrollIndicator = false
        dropDownTableView?.showsHorizontalScrollIndicator = false
        dropDownTableView?.backgroundColor = .white
        dropDownTableView?.separatorStyle = .none
        //dropDownTableView 자체에 대한 dataSource와 delegate는 self에서 구현합니다. 구현한 메소드 내에서 UIDropDownViewDataSource/Delegate로 처리를 넘길 것임.
        dropDownTableView?.delegate = self
        dropDownTableView?.dataSource = self
        dropDownTableView?.allowsSelection = true
        dropDownTableView?.isUserInteractionEnabled = true
        dropDownTableView?.tableFooterView = UIView()
        self.addSubview(dropDownTableView!)
    }
    
    ///DropDown 메뉴 보여주기
    func showDropDown(height: CGFloat){
        
        isDropDownPresent = true
        self.frame = CGRect(x: (self.viewPositionRef?.minX)!, y: (self.viewPositionRef?.maxY)! + self.offset, width: width, height: 0)
        self.dropDownTableView?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        self.dropDownTableView?.reloadSections(IndexSet(integer: 0), with: .none)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear
            , animations: {
            self.frame.size = CGSize(width: self.width, height: height)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: height)
        })  //에니메이션으로 보여주는 부분
    }
    
    ///DropDown 메뉴 감추기
    func hideDropDown(){
        isDropDownPresent = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear
            , animations: {
            self.frame.size = CGSize(width: self.width, height: 0)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: 0)
        })
    }
    
    ///높이를 계속 변경하기 위한 메소드. ex) UISearchBar의 DropDownMenu에서 쓰는 경우
    func reloadDropDown(height: CGFloat){
        self.frame = CGRect(x: (self.viewPositionRef?.minX)!, y: (self.viewPositionRef?.maxY)! + self.offset, width: width, height: 0)
        self.dropDownTableView?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        self.dropDownTableView?.reloadSections(IndexSet(integer: 0), with: .none)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear
            , animations: {
            self.frame.size = CGSize(width: self.width, height: height)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: height)
        })
    }
    
    ///Custom XIB 파일의 높이를 설정하는 메소드(TableView의 각각의 row height 값)
    func setRowHeight(height: CGFloat){
        self.dropDownTableView?.rowHeight = height
        self.dropDownTableView?.estimatedRowHeight = height
    }
    
    ///DropDown을 제거하는 메소드. 필요할 때만 사용하세요.
    func removeDropDown(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear
            , animations: {
            self.dropDownTableView?.frame.size = CGSize(width: 0, height: 0)
        }) { (_) in
            self.removeFromSuperview()
            self.dropDownTableView?.removeFromSuperview()
            self.dropDownTableView?.dataSource = nil
            self.dropDownTableView?.delegate = nil
        }
    }
}

//MARK: - UIDropDownView Extension About TableView Protocols
///아래의 extension에서는 '내부 tableView의 데이터 구성 및 작동에 대한 부분'을 외부 프로토콜로 이관합니다.
extension UIDropDownView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataSource?.dropDownView(numberOfRowsInDropDownViewWithID: self.dropDownViewIdentifier) ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (dropDownTableView?.dequeueReusableCell(withIdentifier: self.dropDownViewCellReusableIdentifier, for: indexPath) ?? UITableViewCell())
        self.dataSource?.dropDownView(dequeuedCell: cell, cellForRowAt: indexPath.row, dropDownViewIdentifier: self.dropDownViewIdentifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownView(didSelectRowAt: indexPath.row, dropDownViewIdentifier: self.dropDownViewIdentifier)
    }
}

//MARK: - UIView Extension
extension UIView{
    func addBorders(borderWidth: CGFloat = 0.2, borderColor: CGColor = UIColor.lightGray.cgColor){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    func addShadowToView(shadowRadius: CGFloat = 2, alphaComponent: CGFloat = 0.6) {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: alphaComponent).cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1
    }
}
