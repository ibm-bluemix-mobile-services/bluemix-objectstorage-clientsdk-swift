//
//  OSContainerHttpMock.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/16/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

@testable import BluemixObjectStorage

internal class OSContainerHttpMock: Manager{
    
    //keys=container names values are the objects "stored" in each container
    internal var objectStoreContainers = [String:[String]]()
    
    
    internal func getStarted(){
        
    }
    
    internal func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("GET called in CONTAINER. Headers: \(headers). Resource: \(resource)")
    }
    
    internal func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("PUT called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
    }
    
    internal func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("DELETE called in CONTAINER. Headers: \(headers). Resource: \(resource)")
    }
    
    internal func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("POST called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
    }
    
    internal func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("HEAD called in CONTAINER. Headers: \(headers). Resource: \(resource)")
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
}