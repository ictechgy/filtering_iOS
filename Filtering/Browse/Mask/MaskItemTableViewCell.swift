//
//  MaskItemTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/13.
//

import UIKit
//마스크 허가목록 화면용 TableViewCell
class MaskItemTableViewCell: NMItemCellWithoutImage {
    //기본 구성은 NMItemCellWithoutImage과 유사.
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
