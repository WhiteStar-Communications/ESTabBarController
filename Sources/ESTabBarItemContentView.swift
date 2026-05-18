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
    
    // MARK: - PROPERTY SETTING
    
    /// The title displayed on the item, default is `nil`
    open var title: String? {
        didSet {
            self.titleLabel.text = title
            self.updateLayout()
        }
    }
    
    /// The image used to represent the item, default is `nil`
    open var image: UIImage? {
        didSet {
            if !selected { self.updateDisplay() }
        }
    }
    
    /// The image displayed when the tab bar item is selected, default is `nil`.
    open var selectedImage: UIImage? {
        didSet {
            if selected { self.updateDisplay() }
        }
    }
    
    /// A Boolean value indicating whether the item is enabled, default is `YES`.
    open var enabled = true
    
    /// A Boolean value indicating whether the item is selected, default is `NO`.
    open var selected = false
    
    /// A Boolean value indicating whether the item is highlighted, default is `NO`.
    open var highlighted = false
    
    /// Text color, default is `UIColor(white: 0.57254902, alpha: 1.0)`.
    open var textColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet {
            if !selected { titleLabel.textColor = textColor }
        }
    }
    
    /// Text color when highlighted, default is `UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0)`.
    open var highlightTextColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected { titleLabel.textColor = highlightTextColor }
        }
    }
    
    /// Icon color, default is `UIColor(white: 0.57254902, alpha: 1.0)`.
    open var iconColor = UIColor(white: 0.57254902, alpha: 1.0) {
        didSet {
            if !selected { imageView.tintColor = iconColor }
        }
    }
    
    /// Icon color when highlighted, default is `UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0)`.
    open var highlightIconColor = UIColor(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected { imageView.tintColor = highlightIconColor }
        }
    }
    
    /// Background color, default is `UIColor.clear`.
    open var backdropColor = UIColor.clear {
        didSet {
            if !selected { backgroundColor = backdropColor }
        }
    }
    
    /// Background color when highlighted, default is `UIColor.clear`.
    open var highlightBackdropColor = UIColor.clear {
        didSet {
            if selected { backgroundColor = highlightBackdropColor }
        }
    }
    
    /// Icon imageView renderingMode, default is `.alwaysTemplate`.
    open var renderingMode: UIImage.RenderingMode = .alwaysTemplate {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// Item content mode, default is `.alwaysTemplate`
    open var itemContentMode: ESTabBarItemContentMode = .alwaysTemplate {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// The offset to use to adjust the title position, default is `UIOffset.zero`.
    open var titlePositionAdjustment: UIOffset = UIOffset.zero {
        didSet {
            self.updateLayout()
        }
    }
    
    /// The insets that you use to determine the insets edge for contents, default is `UIEdgeInsets.zero`
    open var insets = UIEdgeInsets.zero
    {
        didSet {
            self.updateLayout()
        }
    }
    
    open var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.zero)
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    open var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .clear
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    /// Badge value, default is `nil`.
    open var badgeValue: String? {
        didSet {
            if let _ = badgeValue {
                self.badgeView.badgeValue = badgeValue
                self.addSubview(badgeView)
                self.updateLayout()
            } else {
                // Remove when nil.
                self.badgeView.removeFromSuperview()
            }
            badgeChanged(animated: true, completion: nil)
        }
    }
    
    /// Badge color, default is `nil`.
    open var badgeColor: UIColor? {
        didSet {
            if let _ = badgeColor {
                self.badgeView.badgeColor = badgeColor
            } else {
                self.badgeView.badgeColor = ESTabBarItemBadgeView.defaultBadgeColor
            }
        }
    }
    
    /// Badge view, default is `ESTabBarItemBadgeView()`.
    open var badgeView: ESTabBarItemBadgeView = ESTabBarItemBadgeView() {
        willSet {
            if let _ = badgeView.superview {
                badgeView.removeFromSuperview()
            }
        }
        didSet {
            if let _ = badgeView.superview {
                self.updateLayout()
            }
        }
    }
    
    /// Badge offset, default is `UIOffset(horizontal: 6.0, vertical: -22.0)`.
    open var badgeOffset: UIOffset = UIOffset(horizontal: 6.0, vertical: -22.0) {
        didSet {
            if badgeOffset != oldValue {
                self.updateLayout()
            }
        }
    }
    
    // MARK: -
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        titleLabel.textColor = textColor
        imageView.tintColor = iconColor
        backgroundColor = backdropColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func updateDisplay() {
        imageView.image = (selected ? (selectedImage ?? image) : image)?.withRenderingMode(renderingMode)
        imageView.tintColor = selected ? highlightIconColor : iconColor
        titleLabel.textColor = selected ? highlightTextColor : textColor
        backgroundColor = selected ? highlightBackdropColor : backdropColor
    }
    
    open func updateLayout() {
        let w = bounds.width
        let h = bounds.height

        imageView.isHidden = imageView.image == nil
        titleLabel.isHidden = titleLabel.text == nil

        if itemContentMode == .alwaysTemplate {
            var s: CGFloat = 0.0
            var f: CGFloat = 0.0

            var isLandscape = false
            if let keyWindow = UIApplication.shared.keyWindow {
                isLandscape = keyWindow.bounds.width > keyWindow.bounds.height
            }

            let isWide = isLandscape || traitCollection.horizontalSizeClass == .regular

            if #available(iOS 11.0, *), isWide {
                s = UIScreen.main.scale == 3.0 ? 21.0 : 20.0
                f = UIScreen.main.scale == 3.0 ? 12.0 : 11.0
            } else {
                s = 20.0
                f = 10.0
            }

            if !imageView.isHidden && !titleLabel.isHidden {
                titleLabel.font = UIFont.systemFont(ofSize: f)
                titleLabel.sizeToFit()

                if #available(iOS 11.0, *), isWide {
                    titleLabel.frame = CGRect(
                        x: (w - titleLabel.bounds.width) / 2.0 + (UIScreen.main.scale == 3.0 ? 14.25 : 12.25) + titlePositionAdjustment.horizontal,
                        y: (h - titleLabel.bounds.height) / 2.0 + titlePositionAdjustment.vertical,
                        width: titleLabel.bounds.width,
                        height: titleLabel.bounds.height
                    )

                    imageView.frame = CGRect(
                        x: titleLabel.frame.minX - s - (UIScreen.main.scale == 3.0 ? 6.0 : 5.0),
                        y: (h - s) / 2.0,
                        width: s,
                        height: s
                    )
                } else {
                    imageView.frame = CGRect(
                        x: (w - s) / 2.0,
                        y: 8.0,
                        width: s,
                        height: s
                    )

                    titleLabel.frame = CGRect(
                        x: (w - titleLabel.bounds.width) / 2.0 + titlePositionAdjustment.horizontal,
                        y: imageView.frame.maxY + 3.0 + titlePositionAdjustment.vertical,
                        width: titleLabel.bounds.width,
                        height: titleLabel.bounds.height
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
                    x: (w - titleLabel.bounds.width) / 2.0 + titlePositionAdjustment.horizontal,
                    y: (h - titleLabel.bounds.height) / 2.0 + titlePositionAdjustment.vertical,
                    width: titleLabel.bounds.width,
                    height: titleLabel.bounds.height
                )
            }

            if badgeView.superview != nil {
                let size = badgeView.sizeThatFits(frame.size)

                if #available(iOS 11.0, *), isWide {
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
                titleLabel.font = UIFont.systemFont(ofSize: 10.0)
                titleLabel.sizeToFit()
                imageView.sizeToFit()

                imageView.frame = CGRect(
                    x: (w - imageView.bounds.width) / 2.0,
                    y: 8.0,
                    width: imageView.bounds.width,
                    height: imageView.bounds.height
                )

                titleLabel.frame = CGRect(
                    x: (w - titleLabel.bounds.width) / 2.0 + titlePositionAdjustment.horizontal,
                    y: imageView.frame.maxY + 3.0 + titlePositionAdjustment.vertical,
                    width: titleLabel.bounds.width,
                    height: titleLabel.bounds.height
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

    // MARK: - INTERNAL METHODS
    internal final func select(animated: Bool, completion: (() -> ())?) {
        selected = true
        if enabled && highlighted {
            highlighted = false
            dehighlightAnimation(animated: animated, completion: { [weak self] in
                self?.updateDisplay()
                self?.selectAnimation(animated: animated, completion: completion)
            })
        } else {
            updateDisplay()
            selectAnimation(animated: animated, completion: completion)
        }
    }
    
    internal final func deselect(animated: Bool, completion: (() -> ())?) {
        selected = false
        updateDisplay()
        self.deselectAnimation(animated: animated, completion: completion)
    }
    
    internal final func reselect(animated: Bool, completion: (() -> ())?) {
        if selected == false {
            select(animated: animated, completion: completion)
        } else {
            if enabled && highlighted {
                highlighted = false
                dehighlightAnimation(animated: animated, completion: { [weak self] in
                    self?.reselectAnimation(animated: animated, completion: completion)
                })
            } else {
                reselectAnimation(animated: animated, completion: completion)
            }
        }
    }
    
    internal final func highlight(animated: Bool, completion: (() -> ())?) {
        if !enabled {
            return
        }
        if highlighted == true {
            return
        }
        highlighted = true
        self.highlightAnimation(animated: animated, completion: completion)
    }
    
    internal final func dehighlight(animated: Bool, completion: (() -> ())?) {
        if !enabled {
            return
        }
        if !highlighted {
            return
        }
        highlighted = false
        self.dehighlightAnimation(animated: animated, completion: completion)
    }
    
    internal func badgeChanged(animated: Bool, completion: (() -> ())?) {
        self.badgeChangedAnimation(animated: animated, completion: completion)
    }
    
    // MARK: - ANIMATION METHODS
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
