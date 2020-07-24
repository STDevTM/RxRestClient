//
//  UIScrollView+Extensions.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 2/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
