//
//  CSVDataCell.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 28/05/2024.
//

import Foundation
import UIKit

class CSVDataCell: UITableViewCell {
    
    @IBOutlet weak var firstNameLable: UILabel!
    @IBOutlet weak var surNameLable: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
