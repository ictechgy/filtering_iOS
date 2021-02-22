//
//  UIDropDownViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/31.
//

import UIKit

class UIDropDownViewCell: UITableViewCell {
    
    @IBOutlet weak var searchModeNameLabel: UILabel!
    @IBOutlet weak var searchModeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
