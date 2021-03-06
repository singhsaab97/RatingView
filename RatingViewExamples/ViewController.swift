//
//  ViewController.swift
//  RatingViewExamples
//
//  Created by Abhijit Singh on 25/11/20.
//

import UIKit
import RatingView

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRatingViews()
    }
    
    private func addRatingViews() {
        // FYI: Experiment with these values
        let types: [RatingView.RatingType] = [
            .user(config: (animated: true, duration: 0.3)),
            .user(config: (animated: false, duration: 0)),
            .user(config: (animated: true, duration: 0.3)),
            .user(config: (animated: false, duration: 0)),
            .user(config: (animated: true, duration: 0.3)),
            .user(config: (animated: false, duration: 0))
        ]
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemPurple, .systemYellow, .systemTeal, .systemOrange]
        let spacings: [CGFloat] = [2, 2, 2, 2, 2, 2]
        let corners: [Int] = [4, 5, 6, 7, 8, 9]
        let radii: [CGFloat] = [20, 20, 20, 20, 20, 20]
        // Experimentation ends here
        let ratingViewHeight: CGFloat = view.bounds.height / CGFloat(types.count)
        (0..<types.count).enumerated().forEach { (index, _) in
            let properties: RatingView.Properties = .init(
                type: types[index],
                fillColor: colors[index],
                spacing: spacings[index],
                star: .init(
                    numberOfCorners: corners[index],
                    outlineColor: colors[index],
                    radius: radii[index]
                )
            )
            let ratingView: RatingView = .init(
                properties: properties,
                listener: self
            )
            view.addSubview(ratingView)
            ratingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            ratingView.centerYAnchor.constraint(
                equalTo: view.topAnchor,
                constant: CGFloat(index) * ratingViewHeight + ratingViewHeight / 2
            ).isActive = true
            ratingView.widthAnchor.constraint(equalToConstant: ratingView.optimalSize.width).isActive = true
            ratingView.heightAnchor.constraint(equalToConstant: ratingView.optimalSize.height).isActive = true
        }
    }

}

extension ViewController: RatingViewListener {
    
    func userDidRate(with rating: CGFloat) {
        print("Selected user rating is \(rating)")
    }
    
}
