//
//  CupTableViewCell.swift
//  Drift
//
//  Created by Ignat Urbanovich on 12.11.21.
//

import UIKit

class CupTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cupName: UILabel!
    @IBOutlet weak var cupImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cupImage.clipsToBounds = true
        cupImage.layer.cornerRadius = 15
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
