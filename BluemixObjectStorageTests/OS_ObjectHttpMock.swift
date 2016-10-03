//
//  OSObjectHttpMock.swift
//  BluemixObjectStorage
//
//  Created by Conan Gammel on 6/17/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

@testable import BluemixObjectStorage

internal class OSObjectHttpMock: HttpManager{
    
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
    
    
    internal var name:String?
    internal var data:Data?
    internal var metadataValue:String?
    
    
    /*
     Call to load object data
     Example call:
        Headers: ["X-Auth-Token": "mockToken"])
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
    */
    internal func get(resource: HttpResource, headers:[String:String]? = nil, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nGET called in OS_Object. Headers: \(headers). Resource: \(resource)\n")
        completionHandler(nil, 200, headers,self.data)
    }
    
    /*
     Does not get called
     */
    internal func put(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPUT called in OS_Object. Headers: \(headers). Resource: \(resource)\n")
        completionHandler(nil, 200, headers,nil)
    }
    
    /*
     Does not get called
     */
    internal func delete(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nDELETE called in OS_Object. Headers: \(headers). Resource: \(resource)\n")
        completionHandler(nil, 200, headers,nil)
    }
    
    /*
     Call to update metadata
     Example call:
        Headers: ["X-Object-Meta-Test": "testvalue", "X-Auth-Token": "mockToken"])
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
     */
    internal func post(resource: HttpResource, headers:[String:String]?, data:Data?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nPOST called in OS_Object. Headers: \(headers). Resource: \(resource)\n")
        
        self.metadataValue = headers![OSObjectHttpMock.objectMetadataTestName]
        
        completionHandler(nil, 200, headers, nil)
    }
    
    /*
     Call to retrieve metadata
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
     */
    internal func head(resource: HttpResource, headers:[String:String]?, completionHandler: @escaping NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("\nHEAD called in OS_Object. Headers: \(headers). Resource: \(resource)\n")
        
        var newHeaders = headers!
        newHeaders[OSObjectHttpMock.objectMetadataTestName] = self.metadataValue
        
        completionHandler(nil, 200, newHeaders, nil)
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
    
    internal func getInstanceFromPath(path:String)->String{
        let newPath = path.substring(with: Range<String.Index>(path.index(path.startIndex, offsetBy: 9)..<path.index(path.startIndex, offsetBy: path.characters.count)))
        
        var index = indexOf(source: newPath, substring: "/")
        index = index ?? newPath.characters.count
        
        return newPath.substring(with: Range<String.Index>(newPath.index(newPath.startIndex, offsetBy: 0)..<newPath.index(newPath.startIndex, offsetBy: index!)))
        
    }
    
    internal func getContainerNameFromPath(path:String)->String{
        let newPath = path.substring(with: Range<String.Index>(path.index(path.startIndex, offsetBy: 9)..<path.index(path.startIndex, offsetBy: path.characters.count)))
        let index = indexOf(source: newPath, substring: "/")
        
        let tempString = newPath.substring(with: Range<String.Index>(newPath.index(newPath.startIndex, offsetBy: index!+1)..<newPath.index(newPath.startIndex, offsetBy: newPath.characters.count)))
        var index2 = indexOf(source: tempString, substring: "/")
        
        index2 = index2 ?? tempString.characters.count
        
        return tempString.substring(with: Range<String.Index>(tempString.index(tempString.startIndex, offsetBy: 0)..<tempString.index(tempString.startIndex, offsetBy: index2!)))
    }
    
    internal func getObjectNameFromPath(path:String)->String{
        let newPath = path.substring(with: Range<String.Index>(path.index(path.startIndex, offsetBy: 9)..<path.index(path.startIndex, offsetBy: path.characters.count)))
        let index = indexOf(source: newPath, substring: "/")
        
        let tempString = newPath.substring(with: Range<String.Index>(newPath.index(newPath.startIndex, offsetBy: index!+1)..<newPath.index(newPath.startIndex, offsetBy: newPath.characters.count)))
        
        let index2 = indexOf(source: tempString, substring: "/")
        
        return tempString.substring(with: Range<String.Index>(tempString.index(tempString.startIndex, offsetBy: index2!+1)..<tempString.index(tempString.startIndex, offsetBy: tempString.characters.count)))
    }
    
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
