/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import Foundation
import BMSCore

/// An alias for a network request completion handler, receives back error, status, headers and data
internal typealias NetworkRequestCompletionHandler = (HttpError?, Int?, [String:String]?, Data?) -> Void

internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

/// Use HttpClient to make Http requests
internal class HttpClient{
    
    static let logger = Logger(forName: "HttpClient")
    static fileprivate let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    /**
     Send a GET request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    internal class func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.sendRequest(to: resource, method: HttpMethod.GET , headers: headers, completionHandler: completionHandler)
    }
    
    /**
     Send a PUT request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    internal class func put(resource: HttpResource, headers:[String:String]? = nil, data:Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.sendRequest(to: resource, method: HttpMethod.PUT , headers: headers, data: data, completionHandler: completionHandler)
    }
    
    /**
     Send a DELETE request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    internal class func delete(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.sendRequest(to: resource, method: HttpMethod.DELETE, headers: headers, completionHandler: completionHandler)
    }
    
    /**
     Send a POST request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter data: The data to send in request body
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    internal class func post(resource: HttpResource, headers:[String:String]? = nil, data:Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.sendRequest(to: resource, method: HttpMethod.POST , headers: headers, data: data, completionHandler: completionHandler)
    }
    
    /**
     Send a HEAD request
     - Parameter resource: HttpResource instance describing URI schema, host, port and path
     - Parameter headers: Dictionary of Http headers to add to request
     - Parameter completionHandler: NetworkRequestCompletionHandler instance
     */
    internal class func head(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.sendRequest(to: resource, method: HttpMethod.HEAD , headers: headers, completionHandler: completionHandler)
    }
}

// For BMSCore
private extension HttpClient{
    class func sendRequest(to resource: HttpResource, method:HttpMethod, headers:[String:String]? = nil, data: Data? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        
        let request = Request(url: resource.uri, method: method)
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        
        if let headers = headers {
            request.headers = headers
        }
        
        let networkRequestCompletionHandler = { (response: Response?, _: Error?) -> Void in
            guard response != nil else {
                self.logger.error(String(describing: HttpError.connectionFailure))
                completionHandler(HttpError.connectionFailure, nil, nil, nil)
                return
            }
            
            let response = response!
            let httpStatus = response.statusCode!
            var headers:[String:String] = [:]
            
            for (name, value) in response.headers!{
                let headerName = name as! String
                let headerValue = value as! String
                headers.updateValue(headerValue, forKey: headerName)
            }
            
            let responseData = response.responseData
            
            switch httpStatus {
            case 401:
                self.logger.error(String(describing: HttpError.unauthorized))
                self.logger.debug(response.responseText!)
                completionHandler(HttpError.unauthorized, httpStatus, headers, responseData)
                break
            case 404:
                self.logger.error(String(describing: HttpError.notFound))
                self.logger.debug(response.responseText!)
                completionHandler(HttpError.notFound, httpStatus, headers, responseData)
                break
            case 400 ... 599:
                self.logger.error(String(describing: HttpError.serverError))
                self.logger.debug(response.responseText!)
                if data != nil{
                    self.logger.debug(String(data:data!, encoding:String.Encoding.utf8)!)
                }else{
                    let noData = Data()
                    self.logger.debug(String(data:noData, encoding:String.Encoding.utf8)!)
                }
                completionHandler(HttpError.serverError, httpStatus, headers, responseData)
                break
            default:
                completionHandler(nil, httpStatus, headers, responseData)
                break
            }
            
        }
        
        if let data = data {
            request.send(requestBody: data, completionHandler: networkRequestCompletionHandler)
        } else {
            request.send(completionHandler: networkRequestCompletionHandler)
        }
    }
}

/*
 // For NSURLSession
 private extension HttpClient {
	/**
	Send a request
	
	- Parameter url: The URL to send request to
	- Parameter method: The HTTP method to use
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	private class func sendRequest(to resource: HttpResource, method:String, headers:[String:String]? = nil, data: NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
 
 let url = NSURL(string: resource.uri)
 let request = NSMutableURLRequest(URL: url!)
 request.HTTPMethod = method
 request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
 
 if let headers = headers{
 for (headerName, headerValue) in headers{
 request.setValue(headerValue, forHTTPHeaderField: headerName)
 }
 }
 let networkTaskCompletionHandler = {
 (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
 
 guard error == nil else {
 self.logger.error(String(HttpError.ConnectionFailure))
 completionHandler(error:HttpError.ConnectionFailure, status: nil, headers: nil, data: nil)
 return
 }
 
 let httpResponse = response as! NSHTTPURLResponse
 let httpStatus = httpResponse.statusCode
 
 var headers:[String:String] = [:]
 for (name, value) in httpResponse.allHeaderFields{
 let headerName = name as! String
 let headerValue = value as! String
 headers.updateValue(headerValue, forKey: headerName)
 }
 
 switch httpStatus {
 case 401:
 self.logger.error(String(HttpError.Unauthorized))
 self.logger.debug(httpResponse.description)
 completionHandler(error: HttpError.Unauthorized, status: httpStatus, headers: headers, data: data)
 break
 case 404:
 self.logger.error(String(HttpError.NotFound))
 self.logger.debug(httpResponse.description)
 completionHandler(error: HttpError.NotFound, status: httpStatus, headers: headers, data: data)
 break
 case 400 ... 599:
 self.logger.error(String(HttpError.ServerError))
 self.logger.debug(httpResponse.description)
 self.logger.debug(String(data:data!, encoding:NSUTF8StringEncoding)!)
 completionHandler(error: HttpError.ServerError, status: httpStatus, headers: headers, data: data)
 break
 default:
 completionHandler(error: nil, status: httpStatus, headers: headers, data: data)
 break
 }
 }
 
 if (data == nil){
 defaultSession.dataTaskWithRequest(request, completionHandler: networkTaskCompletionHandler).resume()
 } else {
 defaultSession.uploadTaskWithRequest(request, fromData: data, completionHandler: networkTaskCompletionHandler).resume();
 }
	}
 }
 */
