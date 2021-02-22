//
//  AppearanceTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/24.
//

import UIKit
//다크모드 설정화면에서 쓰이는 UITableViewCell
class AppearanceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var appearanceName: UILabel!
    @IBOutlet weak var appearanceButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
