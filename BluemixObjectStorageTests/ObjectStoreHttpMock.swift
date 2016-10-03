//
//  ObjectStoreHttpMock.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
@testable import BluemixObjectStorage

internal class ObjectStoreHttpMock: HttpManager{
    
    //headers
    static let accountMetadataTestName = "X-Account-Meta-Test"
    static let containerMetadataTestName = "X-Container-Meta-Test"
    static let objectMetadataTestName = "X-Object-Meta-Test"
    static let authHeader = "X-Auth-Token"
    
    static let userId = "8d261e25c5bb4a6783c7cde133f8f1dd"
    static let password = "V7]W!i!065jjThaw"
    static let region = ObjectStorage.Region.Dallas
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
    
    /*
     Call to get a container, or a list of containers
     Example call to get a container:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
     
     Example call to get a list of containers:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
     
     */
    internal func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nGET called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        
        if self.isGetContainerListCall(path: resource.path){
            completionHandler(nil, 200, headers, self.makeContainerList(instance: self.getInstanceFromPath(path: resource.path)))
        }else{
            completionHandler(nil, 200, headers, nil)
        }
        
    }
    
    /*
     Call to create container
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
        Data: nil
    */
    internal func put(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPUT called in ObjecStoreMock. Headers: \(headers). Resource: \(resource). Data: \(data)\n")
        
        if let token = headers![ObjectStoreHttpMock.authHeader], token==ObjectStoreHttpMock.authToken{
            let instanceId = self.getInstanceFromPath(path: resource.path)
            let container = self.getContainerFromPath(path: resource.path)
            
            if self.objectStore[instanceId] == nil{
                self.objectStore[instanceId] = [container]
            }else{
                //there are already containers in the list, append rather than overwrite
                var temp = self.objectStore[instanceId]
                temp?.append(container)
                self.objectStore[instanceId] = temp //TODO needs to be unwrapped?
            }
            
            completionHandler(nil, 200, headers, nil)
        }
    }
    
    /*
     Call to delete a container
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
    */
    internal func delete(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nDELETE called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        let instanceId = self.getInstanceFromPath(path: resource.path)
        let container = self.getContainerFromPath(path: resource.path)
        
        if let containerList = self.objectStore[instanceId]{
            if containerList.contains(container){
                let updatedContainerList = containerList.filter{$0 != container}
                self.objectStore[instanceId] = updatedContainerList
                completionHandler(nil, 200, headers, nil)
            }else{
                completionHandler(nil, 200, headers, nil)//TODO make error that container does not exist
            }
        }else{
            completionHandler(nil, 200, headers, nil)//TODO make errir that there are no containers associated with this instance ID
        }
    }
    
    /*
     Call to update metadata
     Example call:
        Headers: ["X-Account-Meta-Test": "testvalue", "X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
        Data: nil
    */
    internal func post(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPOST called in ObjecStoreMock. Headers: \(headers). Resource: \(resource). Data: \(data)\n")
        
        self.accoutMetaDataValue = headers![ObjectStoreHttpMock.accountMetadataTestName]
        
        completionHandler(nil, 200, headers, nil)
    }
    
    /*
     Call to retrieve metadata
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9")
    */
    internal func head(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nHEAD called in ObjecStoreMock. Headers: \(headers). Resource: \(resource)\n")
        
        var newHeaders = headers!
        newHeaders[ObjectStoreHttpMock.accountMetadataTestName] = self.accoutMetaDataValue
        
        completionHandler(nil, 200, newHeaders, nil)
    }
    
    //return a mock AuthTokenManager so that when ObjectStorage calls 'refreshToken' we return a mock token without making an external call
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenMock(projectId: projectId, userId: userId, password: password)
    }
    
    //return a mock AuthTokenManager so that when ObjectStorage calls 'refreshToken' we return a mock token without making an external call
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenMock(projectId: projectId, authToken: authToken)
    }
    
    //helper function to extract the instance id from the path string
    internal func getInstanceFromPath(path:String)->String{
        let pathWithPrefixandAuthRemoved = path.substring(with: Range<String.Index>(path.index(path.startIndex, offsetBy: 9)..<path.index(path.startIndex, offsetBy: path.characters.count)))
        
        var index = indexOf(source: pathWithPrefixandAuthRemoved, substring: "/")
        index = index ?? pathWithPrefixandAuthRemoved.characters.count
        
        return pathWithPrefixandAuthRemoved.substring(with: Range<String.Index>(pathWithPrefixandAuthRemoved.startIndex..<pathWithPrefixandAuthRemoved.index(pathWithPrefixandAuthRemoved.startIndex, offsetBy: index!)))

    }
    
    //helper function to extract the container name from the path string
    internal func getContainerFromPath(path:String)->String{
        let pathWithPrefixandAuthRemoved = path.substring(with: Range<String.Index>(path.index(path.startIndex, offsetBy: 9)..<path.index(path.startIndex, offsetBy: path.characters.count)))
        let index = indexOf(source: pathWithPrefixandAuthRemoved, substring: "/")
        
        return pathWithPrefixandAuthRemoved.substring(with: Range<String.Index>(pathWithPrefixandAuthRemoved.index(pathWithPrefixandAuthRemoved.startIndex, offsetBy: index!+1)..<pathWithPrefixandAuthRemoved.index(pathWithPrefixandAuthRemoved.startIndex, offsetBy:pathWithPrefixandAuthRemoved.characters.count)))
    }
    
    //helper function to create a list of containers in the format that the callee expects
    internal func makeContainerList(instance:String)->Data{
        var data: String = ""
        
        for object in self.objectStore[instance]!{
            data.append(object)
            data.append("\n")
        }
        return data.data(using: .utf8)!
    }
    
    //determines if the GET request is asking for a container or a list of available containers
    internal func isGetContainerListCall(path:String)->Bool{
        let instanceID = getInstanceFromPath(path: path)
        return !path.contains("\(instanceID)/")
    }
    
    //helper function to return the first index of a substring within a string
    func indexOf(source: String, substring: String) -> Int? {
        let maxIndex = source.characters.count - substring.characters.count
        for index in 0...maxIndex {
            let rangeSubstring = source.index(source.startIndex, offsetBy: index)..<source.index(source.startIndex, offsetBy: index + substring.characters.count)
            if source.substring(with: rangeSubstring) == substring {
                return index
            }
        }
        return nil
    }
}
