//
//  ObjectStoreHttpMock.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
@testable import BluemixObjectStorage

internal class ObjectStoreMock: ClientManager{
    
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
    
    //mock object store
    /*
     {
     <projectID>:{
     <container>:[
     <object>,
     <object>,
     <object>
     ],
     <container>:[
     <object>,
     <object>,
     <object>
     ]
     },
     <projectID>:{
     <container>:[
     <object>,
     <object>,
     <object>
     ],
     <container>:[
     <object>,
     <object>,
     <object>
     ]
     }
     }
     */
    //object store mock: strings (ids) map to an array of strings (containers) that each map to OSContainerHttpMock's list of containers with "objects" in an array
    internal var objectStore = [String:[String]]()
    internal var accoutMetaDataValue:String?
    
    internal func getStarted(){
        
    }
    
    /*
     Call to get a container, or a list of containers
     Example call to get a container:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
     
     Example call to get a list of containers:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
     
     */
    internal override func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nGET called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        
        if self.isGetContainerListCall(resource.path){
            completionHandler(error: nil, status: 200, headers: headers, data: self.makeContainerList(self.getInstanceFromPath(resource.path)))
        }else{
            completionHandler(error: nil, status: 200, headers: headers, data: nil)
        }
        
    }
    
    /*
     Call to create container
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
        Data: nil
    */
    internal override func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPUT called in ObjecStoreMock. Headers: \(headers). Resource: \(resource). Data: \(data)\n")
        
        if let token = headers![ObjectStoreMock.authHeader] where token==ObjectStoreMock.authToken{
            let instanceId = self.getInstanceFromPath(resource.path)
            let container = self.getContainerFromPath(resource.path)
            
            if self.objectStore[instanceId] == nil{
                self.objectStore[instanceId] = [container]
            }else{
                //there are already containers in the list, append rather than overwrite
                var temp = self.objectStore[instanceId]
                temp?.append(container)
                self.objectStore[instanceId] = temp //TODO needs to be unwrapped?
            }
            
            completionHandler(error: nil, status: 200, headers: headers, data: nil)
        }
    }
    
    /*
     Call to delete a container
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
    */
    internal override func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nDELETE called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        let instanceId = self.getInstanceFromPath(resource.path)
        let container = self.getContainerFromPath(resource.path)
        
        if let containerList = self.objectStore[instanceId]{
            if containerList.contains(container){
                let updatedContainerList = containerList.filter{$0 != container}
                self.objectStore[instanceId] = updatedContainerList
                completionHandler(error: nil, status: 200, headers: headers, data: nil)
            }else{
                completionHandler(error: nil, status: 200, headers: headers, data: nil)//TODO make error that container does not exist
            }
        }else{
            completionHandler(error: nil, status: 200, headers: headers, data: nil)//TODO make errir that there are no containers associated with this instance ID
        }
    }
    
    /*
     Call to update metadata
     Example call:
        Headers: ["X-Account-Meta-Test": "testvalue", "X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
        Data: nil
    */
    internal override func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPOST called in ObjecStoreMock. Headers: \(headers). Resource: \(resource). Data: \(data)\n")
        
        self.accoutMetaDataValue = headers![ObjectStoreMock.accountMetadataTestName]
        
        completionHandler(error: nil, status: 200, headers: headers, data: nil)
    }
    
    /*
     Call to retrieve metadata
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
    */
    internal override func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nHEAD called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        
        var newHeaders = headers!
        newHeaders[ObjectStoreMock.accountMetadataTestName] = self.accoutMetaDataValue
        
        completionHandler(error: nil, status: 200, headers: newHeaders, data: nil)
    }
    
    internal override func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenMock(projectId: projectId, userId: userId, password: password)
    }
    
    internal override func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenMock(projectId: projectId, authToken: authToken)
    }
    
    internal func getInstanceFromPath(path:String)->String{
        let pathWithPrefixandAuthRemoved = path.substringWithRange(Range<String.Index>(path.startIndex.advancedBy(9)..<path.startIndex.advancedBy(path.characters.count)))
        
        var index = indexOf(pathWithPrefixandAuthRemoved, substring: "/")
        index = index ?? pathWithPrefixandAuthRemoved.characters.count
        
        return pathWithPrefixandAuthRemoved.substringWithRange(Range<String.Index>(pathWithPrefixandAuthRemoved.startIndex.advancedBy(0)..<pathWithPrefixandAuthRemoved.startIndex.advancedBy(index!)))

    }
    
    internal func getContainerFromPath(path:String)->String{
        let pathWithPrefixandAuthRemoved = path.substringWithRange(Range<String.Index>(path.startIndex.advancedBy(9)..<path.startIndex.advancedBy(path.characters.count)))
        let index = indexOf(pathWithPrefixandAuthRemoved, substring: "/")
        
        return pathWithPrefixandAuthRemoved.substringWithRange(Range<String.Index>(pathWithPrefixandAuthRemoved.startIndex.advancedBy(index!+1)..<pathWithPrefixandAuthRemoved.startIndex.advancedBy(pathWithPrefixandAuthRemoved.characters.count)))
    }
    
    internal func makeContainerList(instance:String)->NSData{
        var data: String = ""
        
        for object in self.objectStore[instance]!{
            data.appendContentsOf(object)
            data.appendContentsOf("\n")
        }
        return data.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    internal func isGetContainerListCall(path:String)->Bool{
        let instanceID = getInstanceFromPath(path)
        return !path.containsString("\(instanceID)/")
    }
    
    func indexOf(source: String, substring: String) -> Int? {
        let maxIndex = source.characters.count - substring.characters.count
        for index in 0...maxIndex {
            let rangeSubstring = source.startIndex.advancedBy(index)..<source.startIndex.advancedBy(index + substring.characters.count)
            if source.substringWithRange(rangeSubstring) == substring {
                return index
            }
        }
        return nil
    }
}