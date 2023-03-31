//
//  Button.swift
//  WeatherApp
//
//  Created by M_AMBIN05145 on 31/03/23.
//

import UIKit

extension UIButton{

    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }

}
