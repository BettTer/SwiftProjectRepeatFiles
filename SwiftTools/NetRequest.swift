import Foundation
import Alamofire
import Timepiece

class Request: NSObject {
    
    // 请求地址
    enum RequestAddress: String {
        
        /// 判断入口
        case judgeEntrance = "http://utvasm.com:3000/"
        //        "http://utvasm.com:3000/"
        //        "https://raw.githubusercontent.com/meilijj/switch/master/yy-"
        
        /// 记录行为
        case recordAction = "http://zx.ixinjiapo28.com/Comment/record_data"
        
        /// 获取天气
        case getWeatherMessage = "https://api.seniverse.com/v3/weather/daily.json?key="
    }
    
    // 请求类型
    enum MethodType {
        case get
        case post
    }
    
    // MARK: - 行为相关
    /// 是否记录行为的开关
    static var doesRecordAction: Bool? = nil
    
    enum ActionType: String {
        /// 登录
        case signIn = "1"
        
        /// 退出
        case signOut = "3"
    }
    
    /// 根据行为获取上传参数字典
    static func getParamsFromAction(_ action: ActionType) -> Dictionary<String, Any> {
        var params = Dictionary<String, Any>.init()
        
        params["type"] = action.rawValue
        params["appid"] = Bundle.main.bundleIdentifier
        params["lan"] = ToolClass.getCurrentLanguage()
        params["model"] = ToolClass.getIPhoneType()
        
        #if DEBUG
        params["enum"] = "test"
        #else
        params["enum"] = "production"
        #endif
        
        return params
    }
    
    // MARK: - 天气相关
    /// AppKey
    static let weatherAppKey = "3b0yf3q6bl0rqafx"
    
    /// 记录的经度
    static var longitude = ""
    
    /// 记录的纬度
    static var latitude = ""
    
    /// 获取后半部分请求链接 经度 纬度
    static func getSecondHalfWeatherMessageRequestUrl() -> String {
        
        return weatherAppKey + "&location=" + self.latitude + ":" + self.longitude + "&language=en&unit=c&start=0&days=5"
    }
    
    
    // MARK: - 封装
    /// 发起请求
    static func sendRequest(address: RequestAddress,
                            type: MethodType,
                            params: Dictionary<String, Any>?,
                            finishedCallback: @escaping (_ result: Any?) -> ()
        ) -> Void {
        if type == MethodType.get {
            let netAddress = { () -> String in
                
                switch address {
                // 判断入口
                case RequestAddress.judgeEntrance:
                    return address.rawValue + AppDelegate.projectName
                    
                // 获取天气
                case RequestAddress.getWeatherMessage:
                    return address.rawValue + Request.getSecondHalfWeatherMessageRequestUrl()
                    
                default:
                    return address.rawValue
                }
                
                
                
            }()
            
            Alamofire.request(netAddress, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let originalString):
                    let dict = ToolClass.convertToDictionary(text: originalString)!
                    finishedCallback(dict)
                    
                case .failure(_):
                    finishedCallback(nil)
                }
                
            })
            
        } else if type == MethodType.post {
            Alamofire.request(address.rawValue, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let originalString):
                    let dict = ToolClass.convertToDictionary(text: originalString)!
                    finishedCallback(dict)
                    
                case .failure(_):
                    finishedCallback(nil)
                }
            })
        }
        
    }
    
    /// 统一记录方法
    static func recordAction(_ action: ActionType) -> Void {
        if Request.doesRecordAction == true {
            Request.sendRequest(address: .recordAction, type: .post, params: Request.getParamsFromAction(action)) { (resultDict) in
                
                /*
                 if resultDict != nil && (resultDict as! Dictionary<String, Any>)["resCode"] as! Int == 0 {
                 printWithMessage("成功记录\(action.rawValue)")
                 }
                 */
                
            }
        }
    }
    
    /// 是否需要更新控制器
    static func judgeDoesNeedUpdateViewController(_ setDate: Date, callback: @escaping () -> ()) -> Void {
        if self.judgeSetDate(setDate) == true {
            self.judgeUrlCouldLink(URL.init(string: RequestAddress.judgeEntrance.rawValue)!) { (resultBool) in
                if resultBool == true {
                    callback()
                }
            }
        }
    }
    
    
    /// 判断网址是否可用
    static private func judgeUrlCouldLink(_ url: URL, callback: @escaping (_ resultBool: Bool) -> ()) -> Void {
        var request = URLRequest.init(url: url)
        request.httpMethod = "HEAD"
        let session = URLSession.init(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                callback(true)
                
            }else {
                callback(false)
                
            }
        }
        task.resume()
    }
    
    /// 判断当前时间是否大于设定时间
    static private func judgeSetDate(_ setDate: Date) -> Bool {
        if Date.today() >= setDate {
            return true
        } else {
            return false
        }
    }
    
    
}
