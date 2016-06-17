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
    //headers
    static let accountMetadataTestName = "X-Account-Meta-Test"
    static let containerMetadataTestName = "X-Container-Meta-Test"
    static let objectMetadataTestName = "X-Object-Meta-Test"
    static let authHeader = "X-Auth-Token"
    
    static let userId = "8d261e25c5bb4a6783c7cde133f8f1dd"
    static let password = "V7]W!i!065jjThaw"
    static let region = ObjectStorage.REGION_DALLAS
    static let authToken = "mockToken"
    static let resourceBase = ObjectStorage.DALLAS_RESOURCE
    
    static let schema = "https"
    static let host = "dal.objectstorage.open.softlayer.com"
    static let port = "443"
    static let pathPrefix = "/v1"
    
    //maps container to a list of objects
    internal var container = [String:[String]]()
    internal var accoutMetaDataValue:String?
    
    //Retrieve Object or Object List
    internal func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("GET called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
//        Headers: Optional(["X-Auth-Token": "mockToken"]). Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
        
        //Headers: Optional(["X-Auth-Token": "mockToken"]). Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
    }
    
    //Store an object
    internal func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("PUT called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
        
//        Headers: Optional(["X-Auth-Token": "mockToken"]). Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt"). Data: Optional(<74657374 64617461>)
//        
    }
    
    //Delete Object
    internal func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("DELETE called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
//        Headers: Optional(["X-Auth-Token": "mockToken"]). Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
        
    }
    
    //Update Metadata
    internal func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("POST called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
        
        self.accoutMetaDataValue = headers![ObjectStoreMock.accountMetadataTestName]
        
        completionHandler(error: nil, status: 200, headers: headers, data: nil)
    }
    
    //Retrieve Metadata
    internal func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("HEAD called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
        var newHeaders = headers!
        newHeaders[OSContainerHttpMock.accountMetadataTestName] = self.accoutMetaDataValue
        
        completionHandler(error: nil, status: 200, headers: newHeaders, data: nil)
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
}