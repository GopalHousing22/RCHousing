import Foundation

public protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: URL
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
     public init(baseURL: URL,
                 headers: [String: String] = [:],
                 queryParameters: [String: String] = [:]) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}

var HIDE_FREE_LISTING = false
var RENT_RELEVANCE_V2 = false
var DIRECT_CALL = false

var globalHeaders : [String:String] {
    get {
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
        let buildNo = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")
        var header = ["Content-Type":"application/json",
                      "User-Agent":"Native/ios",
                      "app_name":Bundle.main.bundleIdentifier ?? "",
                      "app_version": "\(version) (\(buildNo))",
                      //                      "js_bundle_version": "",
                      "client_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
                      "hideFreeListings": HIDE_FREE_LISTING.description,
                      "rent_relevance_v2": RENT_RELEVANCE_V2.description,
                      "direct_call": DIRECT_CALL.description]
        
        
        
        if let authToken = AppStorage.authToken {
            header["Authorization"] = authToken
        }
        
        return header
    }
}
