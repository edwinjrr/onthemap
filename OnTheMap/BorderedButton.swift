//
//  BorderedButton.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/25/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit

//UIButton class to configure round edges and font of the "Login", "Find On Map" and "Submit" Buttons.

class BorderedButton: UIButton {
    
    /* Constants for styling and configuration */
    let titleLabelFontSize : CGFloat = 18.0
    let borderedButtonCornerRadius : CGFloat = 4.0
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.themeBorderedButton()
    }
    
    func themeBorderedButton() -> Void {
        self.layer.cornerRadius = borderedButtonCornerRadius
        self.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: titleLabelFontSize)
    }
}
