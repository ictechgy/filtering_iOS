//
//  SearchItemTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/17.
//

import UIKit

///NonMedicalItem TableViewCell Without UIImage
class NMItemCellWithoutImage: UITableViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var entpName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

///NonMedicalItem TableViewCell With UIImage
class NMItemCellWithImage: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var entpName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
