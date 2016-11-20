//
//  ConditionsCell.swift
//  SimpleWeather
//
//  Created by Ryan Nystrom on 11/19/16.
//  Copyright © 2016 Ryan Nystrom. All rights reserved.
//

import UIKit

class ConditionsCell: UICollectionViewCell {
    
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var highLowLabel: UILabel!

    func configure(viewModel: ConditionsCellViewModel) {
        temperatureLabel.text = viewModel.temperatureLabelText
        highLowLabel.text = viewModel.highLowLabelText
    }
    
}