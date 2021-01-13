//
//  MaskItemTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/13.
//

import UIKit

class MaskItemTableViewCell: SearchItemTableViewCell {
    //기본 구성은 SearchItemTableViewCell과 유사.
    @IBOutlet weak var maskTypeLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
