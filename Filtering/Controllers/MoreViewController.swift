//
//  MoreViewController.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/12.
//

import UIKit

class MoreViewController: UITableViewController {
    
    let identifier2OpenSource = "move2OpenSourceVC"
    let identifier2About = "move2AboutVC"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var identifier: String
        switch indexPath.row {
        case 0:
            identifier = identifier2OpenSource
        case 1:
            identifier = identifier2About
        default:
            return
        }
        
        performSegue(withIdentifier: identifier, sender: self)
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
