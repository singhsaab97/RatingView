//
//  RatingViewProtocol.swift
//  RatingView
//
//  Created by Abhijit Singh on 25/11/20.
//

import UIKit

public protocol RatingViewListener: class {
    func userDidRate(with rating: CGFloat)
}
