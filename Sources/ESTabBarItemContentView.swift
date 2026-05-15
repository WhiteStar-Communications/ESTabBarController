//
//  ESTabBarContentView.swift
//
//  Created by Vincent Li on 2017/2/8.
//  Copyright (c) 2013-2020 ESTabBarController (https://github.com/eggswift/ESTabBarController)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public enum ESTabBarItemContentMode : Int {
    
    case alwaysOriginal // Always set the original image size
    
    case alwaysTemplate // Always set the image as a template image size
}

open class ESTabBarItemContentView: UIView {

    open var title: String? {
        didSet {
            titleLabel.text = title
            updateDisplay()
            updateLayout()
        }
    }

    open var image: UIImage? {
        didSet {
            updateDisplay()
            updateLayout()
        }
    }

    open var selectedImage: UIImage? {
        didSet {
            updateDisplay()
            updateLayout()
        }
    }

    open var enabled = true
    open var selected = false
    open var highlighted = false

    open var textColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet { updateDisplay() }
    }

    open var highlightTextColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet { updateDisplay() }
    }

    open var iconColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet { updateDisplay() }
    }

    open var highlightIconColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet { updateDisplay() }
    }

    open var backdropColor = UIColor.clear {
        didSet { updateDisplay() }
    }

    open var highlightBackdropColor = UIColor.clear {
        didSet { updateDisplay() }
    }

    open var renderingMode: UIImage.RenderingMode = .alwaysTemplate {
        didSet {
            updateDisplay()
            updateLayout()
        }
    }

    open var itemContentMode: ESTabBarItemContentMode = .alwaysTemplate {
        didSet {
            updateDisplay()
            updateLayout()
        }
    }

    open var titlePositionAdjustment: UIOffset = .zero {
        didSet { updateLayout() }
    }

    open var insets = UIEdgeInsets.zero {
        didSet { updateLayout() }
    }

    open var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        return imageView
    }()

    open var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UIColor(white: 0.57254902, alpha: 1.0)
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    open var badgeValue: String? {
        didSet {
            if badgeValue != nil {
                badgeView.badgeValue = badgeValue
                if badgeView.superview == nil {
                    addSubview(badgeView)
                }
                updateLayout()
            } else {
                badgeView.removeFromSuperview()
            }

            badgeChanged(animated: true, completion: nil)
        }
    }

    open var badgeColor: UIColor? {
        didSet {
            badgeView.badgeColor = badgeColor ?? ESTabBarItemBadgeView.defaultBadgeColor
        }
    }

    open var badgeView: ESTabBarItemBadgeView = ESTabBarItemBadgeView() {
        willSet {
            badgeView.removeFromSuperview()
        }
        didSet {
            if badgeView.superview != nil {
                updateLayout()
            }
        }
    }

    open var badgeOffset: UIOffset = UIOffset(horizontal: 6.0, vertical: -22.0) {
        didSet {
            if badgeOffset != oldValue {
                updateLayout()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false

        addSubview(imageView)
        addSubview(titleLabel)

        updateDisplay()
        updateLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        isUserInteractionEnabled = false

        if imageView.superview == nil {
            addSubview(imageView)
        }

        if titleLabel.superview == nil {
            addSubview(titleLabel)
        }

        updateDisplay()
        updateLayout()
    }

    open func updateDisplay() {
        let currentImage = selected ? (selectedImage ?? image) : image

        imageView.image = currentImage?.withRenderingMode(renderingMode)
        imageView.tintColor = selected ? highlightIconColor : iconColor
        titleLabel.textColor = selected ? highlightTextColor : textColor
        backgroundColor = selected ? highlightBackdropColor : backdropColor
    }

    open func updateLayout() {
        updateDisplay()

        let w = bounds.size.width
        let h = bounds.size.height

        imageView.isHidden = imageView.image == nil
        titleLabel.isHidden = titleLabel.text?.isEmpty ?? true

        if itemContentMode == .alwaysTemplate {
            var s: CGFloat = 0.0
            var f: CGFloat = 0.0
            var isLandscape = false

            if let keyWindow = UIApplication.shared.keyWindow {
                isLandscape = keyWindow.bounds.width > keyWindow.bounds.height
            }

            let isWide = isLandscape || traitCollection.horizontalSizeClass == .regular

            if #available(iOS 11.0, *), isWide {
                s = UIScreen.main.scale == 3.0 ? 23.0 : 20.0
                f = UIScreen.main.scale == 3.0 ? 13.0 : 12.0
            } else {
                s = 23.0
                f = 10.0
            }

            if !imageView.isHidden && !titleLabel.isHidden {
                titleLabel.font = UIFont.systemFont(ofSize: f)
                titleLabel.sizeToFit()

                if #available(iOS 11.0, *), isWide {
                    titleLabel.frame = CGRect(
                        x: (w - titleLabel.bounds.size.width) / 2.0 + (UIScreen.main.scale == 3.0 ? 14.25 : 12.25) + titlePositionAdjustment.horizontal,
                        y: (h - titleLabel.bounds.size.height) / 2.0 + titlePositionAdjustment.vertical,
                        width: titleLabel.bounds.size.width,
                        height: titleLabel.bounds.size.height
                    )

                    imageView.frame = CGRect(
                        x: titleLabel.frame.origin.x - s - (UIScreen.main.scale == 3.0 ? 6.0 : 5.0),
                        y: (h - s) / 2.0,
                        width: s,
                        height: s
                    )
                } else {
                    titleLabel.frame = CGRect(
                        x: (w - titleLabel.bounds.size.width) / 2.0 + titlePositionAdjustment.horizontal,
                        y: h - titleLabel.bounds.size.height - 1.0 + titlePositionAdjustment.vertical,
                        width: titleLabel.bounds.size.width,
                        height: titleLabel.bounds.size.height
                    )

                    imageView.frame = CGRect(
                        x: (w - s) / 2.0,
                        y: (h - s) / 2.0 - 6.0,
                        width: s,
                        height: s
                    )
                }
            } else if !imageView.isHidden {
                imageView.frame = CGRect(
                    x: (w - s) / 2.0,
                    y: (h - s) / 2.0,
                    width: s,
                    height: s
                )
            } else if !titleLabel.isHidden {
                titleLabel.font = UIFont.systemFont(ofSize: f)
                titleLabel.sizeToFit()

                titleLabel.frame = CGRect(
                    x: (w - titleLabel.bounds.size.width) / 2.0 + titlePositionAdjustment.horizontal,
                    y: (h - titleLabel.bounds.size.height) / 2.0 + titlePositionAdjustment.vertical,
                    width: titleLabel.bounds.size.width,
                    height: titleLabel.bounds.size.height
                )
            }

            if badgeView.superview != nil {
                let size = badgeView.sizeThatFits(frame.size)

                if #available(iOS 11.0, *), isWide, !imageView.isHidden {
                    badgeView.frame = CGRect(
                        origin: CGPoint(
                            x: imageView.frame.midX - 3 + badgeOffset.horizontal,
                            y: imageView.frame.midY + 3 + badgeOffset.vertical
                        ),
                        size: size
                    )
                } else {
                    badgeView.frame = CGRect(
                        origin: CGPoint(
                            x: w / 2.0 + badgeOffset.horizontal,
                            y: h / 2.0 + badgeOffset.vertical
                        ),
                        size: size
                    )
                }

                badgeView.setNeedsLayout()
            }
        } else {
            if !imageView.isHidden && !titleLabel.isHidden {
                titleLabel.sizeToFit()
                imageView.sizeToFit()

                titleLabel.frame = CGRect(
                    x: (w - titleLabel.bounds.size.width) / 2.0 + titlePositionAdjustment.horizontal,
                    y: h - titleLabel.bounds.size.height - 1.0 + titlePositionAdjustment.vertical,
                    width: titleLabel.bounds.size.width,
                    height: titleLabel.bounds.size.height
                )

                imageView.frame = CGRect(
                    x: (w - imageView.bounds.size.width) / 2.0,
                    y: (h - imageView.bounds.size.height) / 2.0 - 6.0,
                    width: imageView.bounds.size.width,
                    height: imageView.bounds.size.height
                )
            } else if !imageView.isHidden {
                imageView.sizeToFit()
                imageView.center = CGPoint(x: w / 2.0, y: h / 2.0)
            } else if !titleLabel.isHidden {
                titleLabel.sizeToFit()
                titleLabel.center = CGPoint(x: w / 2.0, y: h / 2.0)
            }

            if badgeView.superview != nil {
                let size = badgeView.sizeThatFits(frame.size)
                badgeView.frame = CGRect(
                    origin: CGPoint(
                        x: w / 2.0 + badgeOffset.horizontal,
                        y: h / 2.0 + badgeOffset.vertical
                    ),
                    size: size
                )
                badgeView.setNeedsLayout()
            }
        }
    }

    internal final func select(animated: Bool, completion: (() -> ())?) {
        selected = true

        if enabled && highlighted {
            highlighted = false
            dehighlightAnimation(animated: animated) { [weak self] in
                self?.updateDisplay()
                self?.updateLayout()
                self?.selectAnimation(animated: animated, completion: completion)
            }
        } else {
            updateDisplay()
            updateLayout()
            selectAnimation(animated: animated, completion: completion)
        }
    }

    internal final func deselect(animated: Bool, completion: (() -> ())?) {
        selected = false
        updateDisplay()
        updateLayout()
        deselectAnimation(animated: animated, completion: completion)
    }

    internal final func reselect(animated: Bool, completion: (() -> ())?) {
        if selected == false {
            select(animated: animated, completion: completion)
        } else {
            if enabled && highlighted {
                highlighted = false
                dehighlightAnimation(animated: animated) { [weak self] in
                    self?.updateDisplay()
                    self?.updateLayout()
                    self?.reselectAnimation(animated: animated, completion: completion)
                }
            } else {
                updateDisplay()
                updateLayout()
                reselectAnimation(animated: animated, completion: completion)
            }
        }
    }

    internal final func highlight(animated: Bool, completion: (() -> ())?) {
        guard enabled, highlighted == false else {
            return
        }

        highlighted = true
        highlightAnimation(animated: animated, completion: completion)
    }

    internal final func dehighlight(animated: Bool, completion: (() -> ())?) {
        guard enabled, highlighted == true else {
            return
        }

        highlighted = false
        dehighlightAnimation(animated: animated, completion: completion)
    }

    internal func badgeChanged(animated: Bool, completion: (() -> ())?) {
        badgeChangedAnimation(animated: animated, completion: completion)
    }

    open func selectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }

    open func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }

    open func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }

    open func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }

    open func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }

    open func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
}
