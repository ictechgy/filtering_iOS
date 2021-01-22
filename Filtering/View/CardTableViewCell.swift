//
//  CardTableViewCell.swift
//  Filtering
//
//  Created by JINHONG AN on 2021/01/20.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //컨테이너 뷰 외곽에 외곽선 추가
        containerStackView.layer.borderWidth = 1.3
        containerStackView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
