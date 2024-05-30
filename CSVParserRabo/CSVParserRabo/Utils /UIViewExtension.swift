//
//  UIViewExtension.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 30/05/2024.
//

import Foundation
import UIKit

extension UIView {
    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
}
