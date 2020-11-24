//
//  StarView.swift
//  RatingView
//
//  Created by Abhijit Singh on 25/11/20.
//

import UIKit

final public class StarView: UIView {

    /// Dependency for star
    /// - Parameters:
    ///     - numberOfCorners: Number of corners of star
    ///     - outlineColor: Outline color of star
    ///     - radius: Determines the radius of circumcircle of star
    public struct Properties {
        let numberOfCorners: Int
        let outlineColor: UIColor
        let radius: CGFloat
        
        public init(numberOfCorners: Int, outlineColor: UIColor, radius: CGFloat) {
            self.numberOfCorners = numberOfCorners
            self.outlineColor = outlineColor
            self.radius = radius
        }
    }
    
    struct Style {
        static let diameterIncrement: CGFloat = 1 // taking masking into account
    }
    
    private let properties: Properties
    private var didLayoutSubviews: Bool = false
    
    public init(properties: Properties) {
        self.properties = properties
        super.init(frame: .init())
        performInitialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard didLayoutSubviews else {
            createStar()
            didLayoutSubviews.toggle()
            return
        }
    }
    
}

// MARK: - Private Helpers
private extension StarView {
    
    func performInitialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    func createStar() {
        let starLayer: CAShapeLayer = .init()
        let path: UIBezierPath = starPath
        starLayer.path = path.cgPath
        starLayer.strokeColor = properties.outlineColor.cgColor
        starLayer.fillColor = UIColor.clear.cgColor
        starLayer.lineWidth = 2 * Style.diameterIncrement
        starLayer.lineJoin = .round
        layer.addSublayer(starLayer)
        clipView(to: path)
    }
    
    var starPath: UIBezierPath {
        let center: CGPoint = .init(
            x: bounds.midX,
            y: bounds.midY
        )
        let radius: CGFloat = properties.radius + Style.diameterIncrement / 2
        let angleIncrement: CGFloat = 2 * .pi / CGFloat(properties.numberOfCorners)
        var startAngle: CGFloat = -.pi / 2
        let startPoint: CGPoint = makePoint(
            with: radius,
            startAngle,
            center
        )
        let path: UIBezierPath = .init()
        path.move(to: startPoint)
        (0..<properties.numberOfCorners).forEach {_ in
            let midPoint: CGPoint = makePoint(
                with: radius / 2,
                startAngle + angleIncrement / 2,
                center
            )
            let nextPoint: CGPoint = makePoint(
                with: radius,
                startAngle + angleIncrement,
                center
            )
            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)
            startAngle += angleIncrement
        }
        path.close()
        return path
    }
    
    func makePoint(with radius: CGFloat, _ angle: CGFloat, _ center: CGPoint) -> CGPoint {
        return .init(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
    
    func clipView(to path: UIBezierPath) {
        let maskLayer: CAShapeLayer = .init()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
}
