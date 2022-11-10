//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by AmritPandey on 28/07/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ (target as NSObject).perform(Selector($0))
            })
        })
    }
}
