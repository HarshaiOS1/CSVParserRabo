//
//  CSVDataCell.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 28/05/2024.
//

import Foundation
import UIKit

class CSVDataCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateRow(row: CSVRow) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for column in row.columns {
            let label = UILabel()
            label.numberOfLines = 0
            label.text = column.replacingOccurrences(of: "\"", with: "")
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
    }
}
