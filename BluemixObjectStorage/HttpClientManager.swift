//
//  HttpClientManager.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/16/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

internal class HttpClientManager: HttpManager{
    
    internal func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.get(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.put(resource: resource, headers: headers, data: data, completionHandler: completionHandler)
    }
    
    internal func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.delete(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.post(resource: resource, headers: headers, data: data, completionHandler: completionHandler)
    }
    
    internal func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        HttpClient.head(resource:resource, headers: headers, completionHandler: completionHandler)
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
}
