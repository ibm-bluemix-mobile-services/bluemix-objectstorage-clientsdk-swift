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
    internal var containers = [String:[String]]()
    internal var objData = [String: NSData]()
    internal var containerMetadataValue:String?
    

    /*
     Call to retrieve object or object list
     Example call to retrieve object:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
     
     Example call to retrieve a list of objects in the container:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
     
    */
    internal func get(resource resource: HttpResource, headers:[String:String]? = nil, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("GET called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
        let containerName = getContainerNameFromPath(resource.path)
        
        if self.isGetObjectListCall(resource.path){
            completionHandler(error: nil, status: 200, headers: headers, data: makeListOfObjects(containerName))
        }else{
            let objectName = getObjectNameFromPath(resource.path)
            completionHandler(error: nil, status: 200, headers: headers, data: self.objData[objectName])
        }
    }
    
    /*
     Called to store an object
     Example PUT call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
        Data: Optional(<74657374 64617461>)
     */
    internal func put(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("PUT called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
        
        let containerName = getContainerNameFromPath(resource.path)
        let objectName = getObjectNameFromPath(resource.path)
        
        if containers[containerName]==nil {
            containers[containerName] = [objectName]
        }else{
            var objectList = containers[containerName]
            objectList?.append(objectName)
            containers[containerName] = objectList//TODO needs to be unwrapped?
        }
        objData[objectName] = data
        completionHandler(error: nil, status: 201, headers: headers, data: nil)
    }
    
    /*
     Call to delete Object
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer/testobject.txt")
     */
    internal func delete(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("DELETE called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
        let containerName = getContainerNameFromPath(resource.path)
        let objectName = getObjectNameFromPath(resource.path)
        
        if let objectList = self.containers[containerName]{
            if objectList.contains(objectName){
                let updatedObjList = objectList.filter{$0 != objectName}
                self.containers[containerName] = updatedObjList
                completionHandler(error: nil, status: 200, headers: headers, data: nil)
            }else{
                completionHandler(error: nil, status: 200, headers: headers, data: nil)//TODO make error that object does not exist
            }
        }else{
            completionHandler(error: nil, status: 200, headers: headers, data: nil)//TODO make errir that there are no objects in this container
        }
    }
    
    /*
     Call to update metadata
     Example call:
        Headers: ["X-Container-Meta-Test": "testvalue", "X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
        Data: nil
     */
    internal func post(resource resource: HttpResource, headers:[String:String]?, data:NSData?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("POST called in CONTAINER. Headers: \(headers). Resource: \(resource). Data: \(data)")
        
        self.containerMetadataValue = headers![OSContainerHttpMock.containerMetadataTestName]
        
        completionHandler(error: nil, status: 200, headers: headers, data: nil)
    }
    
    /*
     Call to retrieve metadata
     Example call:
        Headers: ["X-Auth-Token": "mockToken"]
        Resource: HttpResource(schema: "https", host: "dal.objectstorage.open.softlayer.com", port: "443", path: "/v1/AUTH_09a0eea3fdcd4095aff2600f7a73e2d9/testcontainer")
     */
    internal func head(resource resource: HttpResource, headers:[String:String]?, completionHandler: NetworkRequestCompletionHandler = NOOPNetworkRequestCompletionHandler){
        print("HEAD called in CONTAINER. Headers: \(headers). Resource: \(resource)")
        
        var newHeaders = headers!
        newHeaders[OSContainerHttpMock.containerMetadataTestName] = self.containerMetadataValue
        
        completionHandler(error: nil, status: 200, headers: newHeaders, data: nil)
    }
    
    internal func getAuthTokenManager(projectId: String, userId: String, password: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, userId: userId, password: password)
    }
    
    internal func getAuthTokenManager(projectId: String, authToken: String)->AuthTokenManager{
        return AuthTokenManager(projectId: projectId, authToken: authToken)
    }
    
    internal func getInstanceFromPath(path:String)->String{
        let newPath = path.substringWithRange(Range<String.Index>(path.startIndex.advancedBy(9)..<path.startIndex.advancedBy(path.characters.count)))
        
        var index = indexOf(newPath, substring: "/")
        index = index ?? newPath.characters.count
        
        return newPath.substringWithRange(Range<String.Index>(newPath.startIndex.advancedBy(0)..<newPath.startIndex.advancedBy(index!)))
        
    }
    
    internal func getContainerNameFromPath(path:String)->String{
        let newPath = path.substringWithRange(Range<String.Index>(path.startIndex.advancedBy(9)..<path.startIndex.advancedBy(path.characters.count)))
        let index = indexOf(newPath, substring: "/")
        
        let tempString = newPath.substringWithRange(Range<String.Index>(newPath.startIndex.advancedBy(index!+1)..<newPath.startIndex.advancedBy(newPath.characters.count)))
        var index2 = indexOf(tempString, substring: "/")
        
        index2 = index2 ?? tempString.characters.count
        
        return tempString.substringWithRange(Range<String.Index>(tempString.startIndex.advancedBy(0)..<tempString.startIndex.advancedBy(index2!)))
    }
    
    internal func getObjectNameFromPath(path:String)->String{
        let newPath = path.substringWithRange(Range<String.Index>(path.startIndex.advancedBy(9)..<path.startIndex.advancedBy(path.characters.count)))
        let index = indexOf(newPath, substring: "/")
        
        let tempString = newPath.substringWithRange(Range<String.Index>(newPath.startIndex.advancedBy(index!+1)..<newPath.startIndex.advancedBy(newPath.characters.count)))
        
        let index2 = indexOf(tempString, substring: "/")
        
        return tempString.substringWithRange(Range<String.Index>(tempString.startIndex.advancedBy(index2!+1)..<tempString.startIndex.advancedBy(tempString.characters.count)))
    }
    
    internal func isGetObjectListCall(path:String)->Bool{
        let containerName = getContainerNameFromPath(path)
        return !path.containsString("\(containerName)/")
    }
    
    internal func makeListOfObjects(container:String)->NSData{
        var data:String = ""
        
        
        for object in self.containers[container]! {
            data.appendContentsOf(object)
            data.appendContentsOf("\n")
        }
        
        return data.dataUsingEncoding(NSUTF8StringEncoding)!
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