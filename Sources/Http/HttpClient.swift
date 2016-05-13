/*
* Copyright 2016 IBM Corp.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/// An alias for a network request completion handler, receives back error, status, headers and data
public typealias NetworkRequestCompletionHandler = (error:HttpError?, status:Int?, headers: [String:String]?, data:NSData?) -> Void

internal let NOOPNetworkRequestCompletionHandler:NetworkRequestCompletionHandler = {(a,b,c,d)->Void in}

/// Use HttpClient to make Http requests
public class HttpClient{
	
	static let logger = Logger(forName: "HttpClient")
	static private let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
	
	/**
	Send a GET request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "GET" , headers: headers, completionHandler: completionHandler)
	}
	
	/**
	Send a PUT request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func put(resource resource: HttpResource, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "PUT" , headers: headers, data: data, completionHandler: completionHandler)
	}
	
	/**
	Send a DELETE request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func delete(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "DELETE" , headers: headers, completionHandler: completionHandler)
	}
	
	/**
	Send a POST request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter data: The data to send in request body
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func post(resource resource: HttpResource, headers:[String:String]? = nil, data:NSData? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "POST" , headers: headers, data: data, completionHandler: completionHandler)
	}
	
	/**
	Send a HEAD request
	- Parameter resource: HttpResource instance describing URI schema, host, port and path
	- Parameter headers: Dictionary of Http headers to add to request
	- Parameter completionHandler: NetworkRequestCompletionHandler instance
	*/
	public class func head(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
		HttpClient.sendRequest(to: resource, method: "HEAD" , headers: headers, completionHandler: completionHandler)
	}
}

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
		
		print(request.allHTTPHeaderFields)
		if (data == nil){
			defaultSession.dataTaskWithRequest(request, completionHandler: networkTaskCompletionHandler).resume()
		} else {
			defaultSession.uploadTaskWithRequest(request, fromData: data, completionHandler: networkTaskCompletionHandler).resume();
		}
	}
}
