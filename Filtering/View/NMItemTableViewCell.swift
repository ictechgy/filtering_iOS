//
//  SearchItemTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2020/12/17.
//

import UIKit

//검색결과, 즐겨찾기 화면용 TableViewCell
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

///NonMedicalItem TableViewCell With UIImage - Inherited from 'NMItemCellWithoutImage'
class NMItemCellWithImage: NMItemCellWithoutImage {
    
    @IBOutlet weak var itemImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
