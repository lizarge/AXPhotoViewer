//
//  OverlayView.swift
//  Pods
//
//  Created by Alex Hill on 5/28/17.
//
//

import UIKit

@objc(AXOverlayView) open class OverlayView: UIView, CaptionViewDelegate {
    
    /// The caption view to be used in the overlay.
    public var captionView: CaptionViewProtocol = CaptionView() {
        didSet {
            (oldValue as? UIView)?.removeFromSuperview()
            self.captionView.delegate = self
            self.setNeedsLayout()
        }
    }
    
    /// The title view displayed in the navigation bar. This view is sized and centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// This is prioritized over `title`.
    public var titleView: OverlayTitleViewProtocol? {
        set(value) {
            self.navigationItem.titleView = value as? UIView
        }
        get {
            return self.navigationItem.titleView as? OverlayTitleViewProtocol
        }
    }
    
    /// The title displayed in the navigation bar. This string is centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    public var title: String? {
        set(value) {
            self.navigationItem.title = value
        }
        get {
            return self.navigationItem.title
        }
    }
    
    /// The title text attributes inherited by the `title`.
    public var titleTextAttributes: [String: Any]? {
        set(value) {
            self.navigationBar.titleTextAttributes = value
        }
        get {
            return self.navigationBar.titleTextAttributes
        }
    }
    
    /// The bar button item that appears in the top left corner of the overlay.
    public var leftBarButtonItem: UIBarButtonItem? {
        set(value) {
            self.navigationItem.setLeftBarButton(value, animated: false)
        }
        get {
            return self.navigationItem.leftBarButtonItem
        }
    }
    
    /// The bar button items that appear in the top left corner of the overlay.
    public var leftBarButtonItems: [UIBarButtonItem]? {
        set(value) {
            self.navigationItem.setLeftBarButtonItems(value, animated: false)
        }
        get {
            return self.navigationItem.leftBarButtonItems
        }
    }

    /// The bar button item that appears in the top right corner of the overlay.
    public var rightBarButtonItem: UIBarButtonItem? {
        set(value) {
            self.navigationItem.setRightBarButton(value, animated: false)
        }
        get {
            return self.navigationItem.rightBarButtonItem
        }
    }
    
    /// The bar button items that appear in the top right corner of the overlay.
    public var rightBarButtonItems: [UIBarButtonItem]? {
        set(value) {
            self.navigationItem.setRightBarButtonItems(value, animated: false)
        }
        get {
            return self.navigationItem.rightBarButtonItems
        }
    }
    
    /// The navigation bar used to set the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`
    public let navigationBar = UINavigationBar()
    public let navigationBarUnderlay = UIView()
    
    /// The underlying `UINavigationItem` used for setting the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`.
    fileprivate var navigationItem = UINavigationItem()
    
    /// The inset of the contents of the `OverlayView`. Use this property to adjust layout for things such as status bar height.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero
    
    fileprivate let OverlayAnimDuration: TimeInterval = 0.25
    
    init() {
        super.init(frame: .zero)
        
        self.captionView.delegate = self
        
        self.navigationBarUnderlay.backgroundColor = (self.captionView as? UIView)?.backgroundColor
        self.addSubview(self.navigationBarUnderlay)
        
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.barTintColor = nil
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.items = [self.navigationItem]
        self.addSubview(self.navigationBar)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var insetSize = self.bounds.size
        insetSize.width -= (self.contentInset.left + self.contentInset.right)
        insetSize.height -= (self.contentInset.top + self.contentInset.bottom)
        
        let navigationBarSize: CGSize = self.navigationBar.sizeThatFits(insetSize)
        self.navigationBar.frame = CGRect(origin: CGPoint(x: self.contentInset.left, y: self.contentInset.top),
                                          size: navigationBarSize)
        self.navigationBar.setNeedsLayout()
        
        self.navigationBarUnderlay.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: self.frame.size.width,
                                                               height: self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height))
        
        if let captionView = self.captionView as? UIView {
            if captionView.superview == nil {
                self.addSubview(captionView)
            }
            
            let captionViewSize = captionView.sizeThatFits(insetSize)
            captionView.frame = CGRect(origin: CGPoint(x: self.contentInset.left, y: self.frame.size.height -
                                                                                     self.contentInset.bottom -
                                                                                     captionViewSize.height),
                                       size: captionViewSize)
            captionView.setNeedsLayout()
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) as? UIButton {
            return view
        }
        
        return nil
    }
    
    // MARK: - Show / hide interface
    // For internal use only.
    func setShowInterface(_ show: Bool, animateWith closure: (() -> Void)?) {
        let alpha: CGFloat = show ? 1 : 0
        guard self.alpha != alpha else {
            return
        }
        
        if alpha == 1 {
            self.isHidden = false
        }
        
        UIView.animate(withDuration: OverlayAnimDuration, animations: { [weak self] in
            self?.alpha = alpha
            closure?()
        }) { (finished) in
            guard alpha == 0 else {
                return
            }
            
            self.isHidden = true
        }
    }
    
    // MARK: - CaptionViewDelegate
    public func captionView(_ captionView: CaptionViewProtocol, contentSizeDidChange newSize: CGSize) {
        (captionView as? UIView)?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - newSize.height), size: newSize)
    }
}

