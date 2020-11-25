//
//  RatingView.swift
//  RatingView
//
//  Created by Abhijit Singh on 25/11/20.
//

import UIKit

final public class RatingView: UIView {
    
    public enum RatingType {
        case user(config: RatingConfig)
        case rated(_ rating: CGFloat, config: RatingConfig)
        
        static public func == (lhs: RatingType, rhs: RatingType) -> Bool {
            switch lhs {
            case .user(let lhsConfig):
                switch rhs {
                case .user(let rhsConfig):
                    return lhsConfig == rhsConfig
                case .rated:
                    break
                }
            case .rated(let lhsRating, let lhsConfig):
                switch rhs {
                case .user:
                    break
                case .rated(let rhsRating, let rhsConfig):
                    return lhsRating == rhsRating && lhsConfig == rhsConfig
                }
            }
            return false
        }
    }
    
    /// Dependency for rating view
    /// - Parameters:
    ///     - type: Determines if rating is already known or user input is required
    ///     - fillColor: Fill color of star
    ///     - spacing: Spacing between consecutive stars
    ///     - star: Dependency for star
    public struct Properties {
        let type: RatingType
        let fillColor: UIColor
        let spacing: CGFloat
        let star: StarView.Properties
        
        public init(type: RatingType, fillColor: UIColor, spacing: CGFloat, star: StarView.Properties) {
            self.type = type
            self.fillColor = fillColor
            self.spacing = spacing
            self.star = star
        }
    }
    
    private struct Style {
        let numberOfStars: Int = 5
        let animationDelay: TimeInterval = 0.1
        let scaleValue: CGFloat = 1.2
    }
    
    // MARK: - Lazy Vars
    private lazy var stackView: UIStackView = {
        return setupStackView()
    }()
    private lazy var starViews: [StarView] = {
        return createStars()
    }()
    
    private let style: Style = .init()
    private let properties: Properties
    private var ratingConfig: RatingConfig = (animated: false, duration: 0)
    private var didLayoutSubviews: Bool = false
    private var hasUserRated: Bool = false
    
    private weak var listener: RatingViewListener?
    
    public typealias RatingConfig = (animated: Bool, duration: TimeInterval)
    
    public init(properties: Properties, listener: RatingViewListener?) {
        self.properties = properties
        self.listener = listener
        super.init(frame: .init())
        performInitialSetup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard didLayoutSubviews else {
            addStars()
            didLayoutSubviews.toggle()
            return
        }
    }
    
}

// MARK: - Requirements Setup
private extension RatingView {
    
    func setupStackView() -> UIStackView {
        let stackView: UIStackView = .init(arrangedSubviews: starViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = properties.spacing
        return stackView
    }
    
    func createStars() -> [StarView] {
        return (0..<style.numberOfStars).map {_ in
            return .init(
                properties: .init(
                    numberOfCorners: properties.star.numberOfCorners,
                    outlineColor: properties.star.outlineColor,
                    radius: properties.star.radius
                )
            )
        }
    }
    
}

// MARK: - Private Helpers
private extension RatingView {
    
    func performInitialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addStackView()
    }
    
    func addStackView() {
        addSubview(stackView)
        let boundingBoxSize: CGSize = optimalSize
        [
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: boundingBoxSize.width),
            stackView.heightAnchor.constraint(equalToConstant: boundingBoxSize.height)
        ].forEach {
            $0.isActive = true
        }
    }
    
    func addStars() {
        starViews.forEach {
            stackView.addArrangedSubview($0)
            [
                $0.widthAnchor.constraint(equalToConstant: 2 * properties.star.radius),
                $0.heightAnchor.constraint(equalToConstant: 2 * properties.star.radius)
            ].forEach {
                $0.isActive = true
            }
        }
        configureStars()
    }
    
    func configureStars() {
        switch properties.type {
        case .user(let config):
            ratingConfig = config
        case .rated(let rating, let config):
            ratingConfig = config
            fillStars(with: rating)
        }
    }
    
    func fillStars(with rating: CGFloat) {
        guard rating > 0, rating <= CGFloat(style.numberOfStars) else { return }
        let starsToFill: Int = .init(rating)
        let extraStarToFill: CGFloat = rating - CGFloat(starsToFill)
        var fillLayer: CAShapeLayer?
        if !extraStarToFill.isZero {
            fillLayer = getExtraStarFillLayer(
                with: starsToFill,
                extraStars: extraStarToFill
            )
        }
        if ratingConfig.animated {
            performFillAnimation(
                on: fillLayer,
                for: starsToFill,
                extraRating: extraStarToFill
            )
        } else {
            (0..<starsToFill).forEach {
                starViews[$0].backgroundColor = properties.fillColor
            }
            fillLayer?.fillColor = properties.fillColor.cgColor
        }
    }
    
    func getExtraStarFillLayer(with starsToFill: Int, extraStars: CGFloat) -> CAShapeLayer {
        let fillLayer: CAShapeLayer = .init()
        fillLayer.path = UIBezierPath(
            rect: .init(
                x: bounds.minX + StarView.Style.diameterIncrement,
                y: bounds.minY,
                width: extraStars * 2 * (properties.star.radius - StarView.Style.diameterIncrement),
                height: 2 * properties.star.radius
            )
        ).cgPath
        fillLayer.fillColor = UIColor.clear.cgColor
        starViews[starsToFill].layer.addSublayer(fillLayer)
        return fillLayer
    }
    
}

// MARK: - Touch Events
extension RatingView {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard properties.type == .user(config: ratingConfig) else { return }
        guard !hasUserRated else { return }
        let touchLocation: CGPoint = touches.first?.location(in: stackView) ?? .init()
        let selectedRating: CGFloat = touchLocation.x / stackView.bounds.width * CGFloat(style.numberOfStars)
        fillStars(with: selectedRating)
        listener?.userDidRate(with: selectedRating)
        hasUserRated.toggle()
    }
    
}

// MARK: - Animation
private extension RatingView {
    
    func performFillAnimation(on layer: CAShapeLayer?, for starsToFill: Int, extraRating: CGFloat) {
        (0..<starsToFill).forEach {
            let delay: TimeInterval = TimeInterval($0) * style.animationDelay
            animateSolidStarFill(
                starViews[$0],
                delay: delay
            )
            animateSolidStarScale(
                starViews[$0],
                delay: delay
            )
        }
        guard !extraRating.isZero else { return }
        let lastStarDelay: TimeInterval = TimeInterval(starsToFill) * style.animationDelay
        animateExtraStarFill(
            for: layer,
            delay: lastStarDelay
        )
        animateExtraStarScale(
            for: layer,
            extraRating: extraRating,
            delay: lastStarDelay
        )
    }
    
    func animateSolidStarFill(_ star: UIView, delay: TimeInterval) {
        let backgroundColor: CABasicAnimation = getAnimation(
            for: "backgroundColor",
            finalValue: properties.fillColor.cgColor,
            duration: ratingConfig.duration,
            delay: delay
        )
        backgroundColor.fillMode = .forwards
        backgroundColor.isRemovedOnCompletion = false
        star.layer.add(backgroundColor, forKey: nil)
    }
    
    func animateSolidStarScale(_ star: StarView, delay: TimeInterval) {
        let scale: CABasicAnimation = getAnimation(
            for: "transform.scale",
            finalValue: style.scaleValue,
            duration: ratingConfig.duration,
            delay: delay
        )
        scale.autoreverses = true
        star.layer.add(scale, forKey: nil)
    }
    
    func animateExtraStarFill(for layer: CAShapeLayer?, delay: TimeInterval) {
        let fillColor: CABasicAnimation = getAnimation(
            for: "fillColor",
            finalValue: properties.fillColor.cgColor,
            duration: ratingConfig.duration,
            delay: delay
        )
        fillColor.fillMode = .forwards
        fillColor.isRemovedOnCompletion = false
        layer?.add(fillColor, forKey: nil)
    }
    
    func animateExtraStarScale(for layer: CAShapeLayer?, extraRating: CGFloat, delay: TimeInterval) {
        let proportionateScaleValue: CGFloat = 1 + (style.scaleValue - 1) * extraRating
        let scale: CABasicAnimation = getAnimation(
            for: "transform.scale",
            finalValue: proportionateScaleValue,
            duration: ratingConfig.duration,
            delay: delay
        )
        scale.autoreverses = true
        layer?.add(scale, forKey: nil)
    }
    
    func getAnimation(for keyPath: String, finalValue: Any, duration: TimeInterval, delay: TimeInterval) -> CABasicAnimation {
        let animation: CABasicAnimation = .init(keyPath: keyPath)
        animation.beginTime = CACurrentMediaTime() + delay
        animation.toValue = finalValue
        animation.duration = duration
        return animation
    }
    
}

// MARK: - Public APIs
public extension RatingView {
    
    var optimalSize: CGSize {
        return .init(
            width: 2 * CGFloat(style.numberOfStars) * properties.star.radius + CGFloat(style.numberOfStars - 1) * properties.spacing,
            height: 2 * properties.star.radius
        )
    }
    
}

