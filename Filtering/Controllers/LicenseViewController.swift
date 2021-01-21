//
//  LicenseViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/20.
//

import UIKit

class LicenseViewController: UIViewController, UITableViewDataSource {
    
    let cellIdentifier = "CardCell"
    @IBOutlet weak var tableView: UITableView!
    
    lazy var licenseList: [LicenseInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
