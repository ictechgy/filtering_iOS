//
//  LicenseViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/20.
//

import UIKit

class LicenseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "CardCell"
    let titleForHeader = "\nThis application is Copyright © JINHONG AN. All rights reserved.\nthe following sets forth attribution notices for third party software that may be contained in this application\nI express my infinite gratitude to the open source community.\n\tdeveloper email : ictechgy@gmail.com"
    @IBOutlet weak var tableView: UITableView!
    
    lazy var licenseList: [LicenseInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        guard let licenseModel: LicenseModel = LicenseModel() else {
            let alert: UIAlertController = UIAlertController(title: "오류 발생", message: "라이선스 정보를 가져오던 도중 문제가 발생하였습니다. 다음에 다시 시도하십시오.", preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.licenseList = licenseModel.list
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        licenseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CardTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CardTableViewCell ?? CardTableViewCell()
        
        cell.title.text = licenseList[indexPath.row].title
        cell.content.text = licenseList[indexPath.row].contents
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titleForHeader
    }
    //tableView에 별도의 View와 Label을 넣는 것도 해봤는데 높이 조절에 대한 부분이 애매해서 titleForHeader로 바꿨다.
    //tableView에 View와 Label을 넣고 해당 Label에 대한 outlet을 만든 다음 여기서 텍스트를 지정해주면 그냥 될까..?
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        headerView.textLabel?.text = titleForHeader
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
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
