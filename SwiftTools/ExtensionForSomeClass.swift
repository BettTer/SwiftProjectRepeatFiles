//
//  ExtensionForSomeClass.swift
//  BirthdayManager
//
//  Created by X Young. on 2017/10/31.
//  Copyright © 2017年 X Young. All rights reserved.
//

import UIKit


// MARK: - 控制器;
extension UIViewController {
    
    /// 根据控制器类名&参数表(字典)创建控制器对象
    class public func createClassObjWithString(className: String!, classPropertyParam: Dictionary<String, Any>?) -> (UIViewController){
        
        //动态获取命名空间
        let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        //注意工程中必须有相关的类，否则程序会崩
        let viewControllerClass: AnyClass = NSClassFromString(nameSpace + "." + className)!
        
        // 告诉编译器它的真实类型
        guard let classType = viewControllerClass as? UIViewController.Type else{
            printWithMessage("无法获取到该控制器类型 在此跳出")
            return UIViewController()
        }
        let viewController = classType.init()
        if classPropertyParam != nil {
            viewController.setValuesForKeys(classPropertyParam!)
        }
        
        return viewController
    }
    
    /// 从故事板中初始化一个控制器 [控制器名] -> UIViewController
    class public func initVControllerFromStoryboard(_ vControllerName: String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: vControllerName)
        
    }// funcEnd
    

    /// 获取当前控制器头部高度 [] -> 高度
    func getStatusBarAndNaviBarHeight() -> CGFloat {
        
        return UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.getHeight()
    }// funcEnd
    

    
}

// MARK: - 表格视图控制器;
extension UITableViewController {
    
    
    
}


// MARK: - 视图;
extension UIView {
    
    /// 获取当前View的横坐标
    public func getX() -> CGFloat {
        return self.frame.origin.x
    }
    
    /// 获取当前View的纵坐标
    public func getY() -> CGFloat {
        return self.frame.origin.y
    }
    
    /// 获取当前View的宽
    public func getWidth() -> CGFloat {
        return self.frame.width
    }
    
    /// 获取当前View的高
    public func getHeight() -> CGFloat {
        return self.frame.height
    }
    
    
    /// 根据当前View截图
    static public func cutImageWithView(view:UIView) -> UIImage
    {
        // 参数①：截屏区域  参数②：是否透明  参数③：清晰度
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
    
    /// 根据当前scrollView截图
    public func cutFullImageWithView(scrollView:UIScrollView) -> UIImage
    {
        // 记录当前的scrollView的偏移量和坐标
        let currentContentOffSet:CGPoint = scrollView.contentOffset
        let currentFrame:CGRect = scrollView.frame;
        
        // 设置为zero和相应的坐标
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect.init(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        
        // 参数①：截屏区域  参数②：是否透明  参数③：清晰度
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, true, UIScreen.main.scale)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // 重新设置原来的参数
        scrollView.contentOffset = currentContentOffSet
        scrollView.frame = currentFrame
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func createAnimationWithRotation(_ isNeedRotation: Bool) -> Void {
        
        if isNeedRotation == true {
            
            let rotation = ToolClass.baseAnimationWithKeyPath("transform.rotation.z", fromValue: nil, toValue: 1.0 * Double.pi, duration: 1, repeatCount: MAXFLOAT, timingFunction: kCAMediaTimingFunctionLinear)
            self.layer.add(rotation, forKey: nil)
            
        }else{
            
            self.layer.removeAllAnimations()
        }
        
        
    }
    
    /// 类方法:从类名初始化该类下的View
    /*
     class public func loadPolicyQuickSearchQuestionV() -> PolicyQuickSearchQuestionV {
     let selfClassString = NSStringFromClass(self)
     var newStr = String(selfClassString[selfClassString.index(of: ".")!...])
     newStr.removeFirst()
     
     return Bundle.main.loadNibNamed(newStr, owner: nil, options: nil)?.last as! PolicyQuickSearchQuestionV
     }
     */
}

extension UILabel {
    
    /// 设置Label为动态行高
    public func setAutoFitHeight(x: CGFloat, y: CGFloat, width: CGFloat) -> CGFloat {
        self.numberOfLines = 0
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        let autoSize: CGSize = self.sizeThatFits(CGSize.init(width: width, height: CGFloat(MAXFLOAT)))
        self.frame = CGRect.init(x: x, y: y, width: width, height: autoSize.height)
        return autoSize.height
    }
    
    /// 设置Label为动态宽
    public func setAutoFitWidth(x: CGFloat, y: CGFloat, height: CGFloat) -> CGFloat {
        self.numberOfLines = 0
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        let autoSize: CGSize = self.sizeThatFits(CGSize.init(width: CGFloat(MAXFLOAT), height: height))
        self.frame = CGRect.init(x: x, y: y, width: autoSize.width, height: height)
        return autoSize.width
    }
    
    /// 设置系统字体的label [文字 文字颜色 背景色 字体大小] -> Void
    public func setLabel(text: String, textColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> Void {
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.font = UIFont.systemFont(ofSize: fontSize)
    }// funcEnd
}

extension UITextView {
    
    /// 设置UITextView为动态高 [内容, 字体大小, 宽度] -> 动态高 
    public func setAutoFitHeight(text: String, fontSize: CGFloat, fixedWidth: CGFloat) -> CGFloat {
        
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize)
        
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let constraint = self.sizeThatFits(size)
        return constraint.height
    }// funcEnd
}



// MARK: - 按钮相关;
extension UIBarButtonItem {
    
    /// 绑定点击事件
    public func addTargetWithoutControlEvents(viewController: UIViewController, selector: Selector) -> Void {
        self.target = viewController
        self.action = selector
    }
}

extension UIButton {
    
    /// 点击时隐藏键盘
    open override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        UIApplication.shared.keyWindow?.endEditing(true)
        super.addTarget(target, action: action, for: controlEvents)
    }
    
    /// 设置Button为动态宽
    public func setAutoFitWidth(x: CGFloat, y: CGFloat, height: CGFloat) -> CGFloat {
        let w = self.titleLabel?.setAutoFitWidth(x: x, y: y, height: height)
        self.frame = CGRect.init(x: x, y: y, width: w!, height: height)
        return w!
    }

}

// MARK: - 归/解档相关;
extension FileManager{
    
    
}

// MARK: - Int数字转汉字数字;
extension Int {
    /// 汉字数字
    var cn: String {
        get {
            if self == 0 {
                return "零"
            }
            var zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            var units = ["", "十", "百", "千", "万", "十", "百", "千", "亿", "十","百","千"]
            var cn = ""
            var currentNum = 0
            var beforeNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                if index == 0{
                    if currentNum != 0 {
                        cn = zhNumbers[currentNum]
                        continue
                    }
                } else {
                    beforeNum = self/Int(pow(10.0,Double(index-1)))%10
                }
                if [1,2,3,5,6,7,9,10,11].contains(index) {
                    if currentNum == 1 && [1,5,9].contains(index) && index == intLength { // 处理一开头的含十单位
                        cn = units[index] + cn
                    } else if currentNum != 0 {
                        cn = zhNumbers[currentNum] + units[index] + cn
                    } else if beforeNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                    continue
                }
                if [4,8,12].contains(index) {
                    cn = units[index] + cn
                    if (beforeNum != 0 && currentNum == 0) || currentNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                }
            }
            return cn
        }
    }
}

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

//extension Date{
//    public static func today() -> Date {
//        let now = Date()
//
//        return Date(year: now.year, month: now.month, day: now.day).addingTimeInterval(TimeInterval.init(8 * 60 * 60))
//    }
//}


/*
 /// 获取某个中文字符串的首字母
 static func getChineseStringInitial(aString: String) -> String {
 
 // 注意,这里一定要转换成可变字符串
 let mutableString = NSMutableString.init(string: aString)
 // 将中文转换成带声调的拼音
 CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
 // 去掉声调(用此方法大大提高遍历的速度)
 let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
 // 将拼音首字母装换成大写
 let strPinYin = self.polyphoneStringHandle(nameString: aString, pinyinString: pinyinString).uppercased()
 // 截取大写首字母
 let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
 // 判断姓名首位是否为大写字母
 let regexA = "^[A-Z]$"
 let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
 return predA.evaluate(with: firstString) ? firstString : "#"
 
 }
 
 /// 多音字处理
 static func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
 if nameString.hasPrefix("长") {return "chang"}
 if nameString.hasPrefix("沈") {return "shen"}
 if nameString.hasPrefix("厦") {return "xia"}
 if nameString.hasPrefix("地") {return "di"}
 if nameString.hasPrefix("重") {return "chong"}
 
 return pinyinString;
 }
 */
