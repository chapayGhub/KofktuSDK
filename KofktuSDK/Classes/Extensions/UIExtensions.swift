//
//  UIExtensions.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 6..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import CoreGraphics
import UIKit
import QuartzCore
import SDWebImage

/**
 UnableToScanHexValue:      "Scan hex error"
 MismatchedHexStringLength: "Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8"
 */
public enum UIColorInputError : Error {
    case UnableToScanHexValue,
    MismatchedHexStringLength
}

extension UIColor {
    
    public var isDarkColor: Bool {
        guard let rgb = self.cgColor.components else {
            return false
        }
        
        let rValue = 0.2126 * rgb[0]
        let gValue = 0.7152 * rgb[1]
        let bValue = 0.0722 * rgb[2]
        
        return (rValue + gValue + bValue) < 0.5
    }
    
    public var image: UIImage? {
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 1.0, height: 1.0))
        UIGraphicsBeginImageContext(rect.size)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(cgColor)
        contextRef?.fill(rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func colorWith255(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /**
     The shorthand three-digit hexadecimal representation of color.
     #RGB defines to the color #RRGGBB.
     
     - parameter hex3: Three-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #RRGGBBAA.
     
     - parameter hex4: Four-digit hexadecimal value.
     */
    public convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.
     
     - parameter hex6: Six-digit hexadecimal value.
     */
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
     
     - parameter hex8: Eight-digit hexadecimal value.
     */
    public convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.
     
     - parameter rgba: String value.
     */
    public convenience init(hexString: String) throws {
        let hexString = hexString.substring(from: hexString.hasPrefix("#") ? 1 : 0)
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            throw UIColorInputError.UnableToScanHexValue
        }
        
        switch (hexString.count) {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            throw UIColorInputError.MismatchedHexStringLength
        }
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.
     
     - parameter rgba: String value.
     */
    public convenience init(rgba: String, defaultColor: UIColor = UIColor.clear) {
        guard let color = try? UIColor(hexString: rgba) else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }
        self.init(cgColor: color.cgColor)
    }
    
    /**
     Hex string of a UIColor instance.
     
     - parameter rgba: Whether the alpha should be included.
     */
    public func hexString(_ includeAlpha: Bool) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    override open var description: String {
        return self.hexString(true)
    }
    
    override open var debugDescription: String {
        return self.hexString(true)
    }
}

public extension UIImage {
    public var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
    
    public var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }
    
    public func resize(_ newSize: CGSize, scale: CGFloat = 0.0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    public func averageColor() -> UIColor? {
        guard #available(iOS 9, *) else {
            Log.w("available iOS 9.x")
            return nil
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext(options: nil)
        let cgImg = context.createCGImage(CoreImage.CIImage(cgImage: self.cgImage!), from: CoreImage.CIImage(cgImage: self.cgImage!).extent)
        
        let inputImage = CIImage(cgImage: cgImg!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        
        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Compute result.
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
}

extension UIView: NibLoadableView {}
public extension UIView {
    
    public var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }
    
    public var x: CGFloat {
        get {
            return frame.minX
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    public var y: CGFloat {
        get {
            return frame.minY
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    public var right: CGFloat {
        return frame.maxX
    }
    
    public var bottom: CGFloat {
        return frame.maxY
    }
    
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    
    public var width: CGFloat {
        get {
            return frame.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    public var height: CGFloat {
        get {
            return frame.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    public func circlize() {
        clipsToBounds = true
        layer.cornerRadius = width / 2.0
    }
    
    public func capture(_ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let alpha = self.alpha
        let isHidden = self.isHidden
        
        defer {
            self.alpha = alpha
            self.isHidden = isHidden
            UIGraphicsEndImageContext()
        }
        
        self.alpha = 1.0
        self.isHidden = false
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: contextRef)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func drawBorder(_ color: UIColor = UIColor.red, width: CGFloat = 1.0 / UIScreen.main.scale) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    public func showGuideLines(_ width: CGFloat = 1.0 / UIScreen.main.scale, recursive: Bool = true) {
        drawBorder(UIColor(
            red: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            green: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            blue: CGFloat(arc4random_uniform(255) + 1) / 255.0,
            alpha: 1.0),
                   width: width)
        
        if recursive {
            for subview in subviews {
                subview.showGuideLines()
            }
        }
    }
    
    public func addSubviewAtFit(_ view: UIView, edge: UIEdgeInsets = UIEdgeInsets.zero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(edge.left)-[view]-\(edge.right)-|", views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(edge.top)-[view]-\(edge.bottom)-|", views: ["view": view]))
    }
    
}

public extension NSLayoutConstraint {
    public class func constraints(withVisualFormat format: String, views: [String : Any]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
    }
}

public enum UIButtonAlignment {
    case left
    case right
}

public extension UIButton {
    public func clearImage(state: UIControl.State) {
        sd_cancelImageLoad(for: state)
        setImage(nil, for: state)
        setBackgroundImage(nil, for: state)
    }
    
    public func setBackgroundImage(with urlString: String?, for state: UIControl.State, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        clearImage(state: state)
        setBackgroundImage(placeholder, for: state)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setBackgroundImage(with: url, for: state, completed: { [weak self] (image, error, type, url) in
                self?.setBackgroundImage(image ?? placeholder, for: state)
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
    public func setImage(with urlString: String?, for state: UIControl.State, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        clearImage(state: state)
        setImage(placeholder, for: state)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setImage(with: url, for: state, completed: { [weak self] (image, error, type, url) in
                self?.setImage(image ?? placeholder, for: state)
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
    public func strechBackgroundImage() {
        let states: [UIControl.State] = [ .normal, .highlighted, .selected, .disabled ]
        
        for state in states {
            guard let image = backgroundImage(for: state) else { continue }
            let size = image.size
            setBackgroundImage(image.stretchableImage(withLeftCapWidth: Int(size.width / 2.0), topCapHeight: Int(size.height / 2.0)), for: state)
        }
    }
    
    public func centerVerticallyWithPadding(padding: CGFloat = 6.0) {
        sizeToFit()
        
        guard let imageSize = imageView?.size, let titleSize = titleLabel?.size else {
            return
        }
        
        let iw = imageSize.width
        let ih = imageSize.height
        let tw = titleSize.width
        let th = titleSize.height
        
        let totalHeight = ih + th + padding
        
        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - ih), left: 0.0, bottom: 0.0, right: -tw)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -iw, bottom: -(totalHeight - th), right: 0.0)
    }
    
    public func imageAlignment(alignment: UIButtonAlignment) {
        sizeToFit()
        
        guard let imageBounds = imageView?.bounds  else { return }
        guard let titleBounds = titleLabel?.bounds else { return }
        
        switch alignment {
        case .left:
            titleEdgeInsets = UIEdgeInsets.zero
            imageEdgeInsets = UIEdgeInsets.zero
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: titleEdgeInsets.top + 0, left: titleEdgeInsets.left - imageBounds.width, bottom: titleEdgeInsets.bottom, right: titleEdgeInsets.right + imageBounds.width)
            imageEdgeInsets = UIEdgeInsets(top: imageEdgeInsets.top + 0, left: imageEdgeInsets.left + titleBounds.width, bottom: imageEdgeInsets.bottom, right: imageEdgeInsets.right - titleBounds.width)
        }
    }
    
}

public extension UIImageView {
    
    public func clearImage() {
        sd_cancelCurrentImageLoad()
        image = nil
    }
    
    public func setImage(with urlString: String?, placeholder: UIImage? = nil, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        sd_cancelCurrentImageLoad()
        image = placeholder
        
        if let urlString = urlString, let url = URL(string: urlString) {
            sd_setImage(with: url, completed: { [weak self] (image, error, type, url) in
                self?.image = image ?? placeholder
                completion?(image, error as NSError?)
            })
        } else {
            completion?(nil, NSError(domain: "UIImageView.Extension", code: -1, userInfo: [NSLocalizedDescriptionKey: "urlString is null"]))
        }
    }
    
}

public extension UIRefreshControl {
    
    public func moveTo(offsetY: CGFloat) {
        bounds = CGRect(origin: CGPoint(x: bounds.origin.x, y: offsetY), size: bounds.size)
        beginRefreshing()
        endRefreshing()
    }
    
}


public extension UIScrollView {
    
    public func scrollToTop(animated: Bool = true) {
        let offset = CGPoint(x: 0.0, y: -contentInset.top)
        setContentOffset(offset, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool = true) {
        let y = max(-contentInset.top, contentSize.height - height + contentInset.bottom)
        let offset = CGPoint(x: 0.0, y: y)
        setContentOffset(offset, animated: animated)
    }
}

public extension UITableViewCell {
    
    public func hiddenSepratorLine() {
        separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 10000000.0)
    }
    
}

extension UITableViewCell: ReusableView {}
public extension UITableView {
    
    public func register<T: UITableViewCell>(withReuseIdentifier: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    public func register<T: UITableViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.reusableIdentifier)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(`for` indexPath: IndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
    public func selectedAll(`in` section: Int) {
        for row in 0 ..< numberOfRows(inSection: section) {
            selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
        }
    }
    
    public func deselectedAll(`in` section: Int) {
        for row in 0 ..< numberOfRows(inSection: section) {
            deselectRow(at: IndexPath(row: row, section: section), animated: false)
        }
    }
    
}

extension UICollectionViewCell: ReusableView {}
public extension UICollectionView {
    
    public func register<T: UICollectionViewCell>(withReuseIdentifier: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    public func register<T: UICollectionViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.reusableIdentifier)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(`for` indexPath: IndexPath) -> T {
        let reuseIdentifier = T.reusableIdentifier
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusableIdentifier)")
        }
        return cell
    }
    
}

extension UIViewController: NibLoadableView {}
public extension UIViewController {
    
    public var topMostViewController: UIViewController {
        return topViewControllerWithRootViewController(self)
    }
    
    public var modalTopViewController: UIViewController {
        if let viewController = presentedViewController {
            return viewController.modalTopViewController
        }
        return self
    }
    
    public var modalTopMostViewController: UIViewController {
        if let viewController = presentedViewController {
            return viewController.modalTopViewController
        }
        return topMostViewController
    }
    
    private func topViewControllerWithRootViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        } else if let naviController = rootViewController as? UINavigationController {
            return topViewControllerWithRootViewController(naviController.viewControllers.last!)
        } else if let viewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(viewController)
        }
        
        return rootViewController
    }
    
    public func dismissAllModalViewController() {
        if let viewController = presentedViewController {
            viewController.dismiss(animated: false, completion: { 
                self.dismissAllModalViewController()
            })
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
}

public extension UIApplication {
    public var enabledRemoteNotification: Bool {
        return UIApplication.shared.currentUserNotificationSettings?.types.contains([.alert]) ?? false
    }
}

extension UIDevice {
    public var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    public var isIPad: Bool {
        return UIScreen.main.traitCollection.userInterfaceIdiom == .pad
    }
    
    public var isIPhoneX: Bool {
        if #available(iOS 11.0, *) {
            if let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets, UIScreen.main.traitCollection.userInterfaceIdiom == .phone {
                return safeAreaInsets.bottom > 0.0
            }
        }
        return false
    }
    
    public func set(orientation value: UIInterfaceOrientation) {
        UIDevice.current.setValue(value.rawValue, forKey: "orientation")
    }
}


