//
//  SplashView.swift
//  Virtusize
//
//  Created by Zaidin Amiot on 2018/11/15.
//  Copyright © 2018 Virtusize AB. All rights reserved.
//

import UIKit

internal class SplashView: UIView {
    private let logo: UIImageView = {
        let logo = UIImageView(image: Assets.logo)
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = Assets.primaryColor
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    internal let cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Assets.cancel, for: .normal)
        button.tintColor = .black
        return button
    }()

    override func willMove(toSuperview newSuperview: UIView?) {
        guard let superview = newSuperview else {
            return
        }

        // Setup view
        backgroundColor = .white
        frame = superview.bounds

        // Setup UI elements
        addSubview(logo)
        addSubview(activityIndicator)
        addSubview(cancelButton)
        activateConstraints()
    }

    func activateConstraints() {
        // Create and activate constraints
        let views = [
            "logo": logo,
            "cancelButton": cancelButton,
            "activity": activityIndicator,
            "view": self
        ]

        let logoHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[view]-(<=1)-[logo]", options: .alignAllCenterX, metrics: nil, views: views)
        let logoVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[view]-(<=1)-[logo]", options: .alignAllCenterY, metrics: nil, views: views)
        let activityHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[view]-(<=1)-[activity]", options: .alignAllCenterX, metrics: nil, views: views)
        let activityVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[logo]-16-[activity]", options: .alignAllCenterX, metrics: nil, views: views)

        let buttonVerticalConstraints: [NSLayoutConstraint]
        if #available(iOS 11.0, *) {
            let layoutGuide = safeAreaLayoutGuide
            buttonVerticalConstraints = [cancelButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 9)]
        } else {
            buttonVerticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-30-[cancelButton]", options: .alignAllTop, metrics: nil, views: views)
        }
        let buttonHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "[cancelButton]-12-|", options: .alignAllLeft, metrics: nil, views: views)

        NSLayoutConstraint.activate(buttonVerticalConstraints
            + buttonHorizontalConstraints
            + activityHorizontalConstraints
            + activityVerticalConstraints
            + logoVerticalConstraints
            + logoHorizontalConstraints)
    }
}
