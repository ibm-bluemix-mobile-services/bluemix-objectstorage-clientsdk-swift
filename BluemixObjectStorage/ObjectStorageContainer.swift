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
#if swift(>=3)
    import SimpleLogger
    import SimpleHttpClient
#endif

/// ObjectStorageContainer instance represents a single container on IBM Object Store service
public class ObjectStorageContainer{
    
    /// Container name
    public let name:String
    
    /// Container resource
    internal let resource:HttpResource
    
    internal let objectStore:ObjectStorage
    private let logger:Logger
    internal var httpManager:HttpManager
    
    internal init(name:String, resource: HttpResource, objectStore:ObjectStorage){
        self.logger = Logger(forName:"ObjectStoreContainer [\(name)]")
        self.name = name
        self.resource = resource
        self.objectStore = objectStore
        self.httpManager = HttpClientManager()
    }
    
    /**
     Create a new object or update an existing one. In case object with a same name already exists it will be replaced with the new content.
     
     - Parameter name: The name of the object to be stored
     - Parameter data: The object content
     */
    public func storeObject(name name:String, data:NSData, completionHandler: (error: ObjectStorageError?, object: ObjectStorageObject?)->Void){
        logger.info("Storing object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, object: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.put(resource: resource, headers: headers, data: data) { error, status, headers, responseData in
                if let error = error{
                    completionHandler(error: ObjectStorageError.from(httpError: error), object: nil)
                } else {
                    self.logger.info("Stored object [\(name)]")
                    let object = ObjectStorageObject(name: name, resource: resource, container: self, data: data)
                    completionHandler(error: nil, object: object)
                }
            }
        })
    }
    
    
    /**
     Retrieve an existing object
     
     - Parameter name: The name of the object to be retrieved
     */
    public func retrieveObject(name name:String, completionHandler: (error: ObjectStorageError?, object: ObjectStorageObject?)->Void){
        logger.info("Retrieving object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, object: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.get(resource: resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(error: ObjectStorageError.from(httpError: error), object: nil)
                } else {
                    self.logger.info("Retrieved object [\(name)]")
                    let object = ObjectStorageObject(name: name, resource: resource, container: self, data: data)
                    completionHandler(error: nil, object: object)
                }
            }
        })
    }
    
    
    /**
     Retrieve a list of existing objects
     
     */
    public func retrieveObjectsList(completionHandler completionHandler: (error: ObjectStorageError?, objects: [ObjectStorageObject]?)->Void){
        logger.info("Retrieving objects list")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            
            guard error == nil else {
                return completionHandler(error: error, objects: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.get(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(error: ObjectStorageError.from(httpError: error), objects: nil)
                }else {
                    self.logger.info("Retrieved objects list")
                    var objectsList = [ObjectStorageObject]()
                    let responseBodyString = String(data: data!, encoding: NSUTF8StringEncoding)!
                    
                    let objectNames = responseBodyString.componentsSeparatedByString("\n")
                    
                    for objectName:String in objectNames{
                        if objectName.characters.count == 0 {
                            continue
                        }
                        let objectResource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + objectName))
                        let object = ObjectStorageObject(name: objectName, resource: objectResource, container: self)
                        objectsList.append(object)
                    }
                    completionHandler(error: nil, objects: objectsList)
                }
                
            }
        })
    }
    
    /**
     Delete an existing object
     
     - Parameter name: The name of the object to be deleted
     */
    public func deleteObject(name name: String, completionHandler: (error:ObjectStorageError?) -> Void){
        logger.info("Deleting object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.delete(resource: resource, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Deleted object [\(name)]")
                    completionHandler(error: nil)
                }
            }
        })
    }
    
    /**
     Delete the container
     
     */
    public func delete(completionHandler completionHandler:(error: ObjectStorageError?)->Void){
        self.objectStore.deleteContainer(name: self.name, completionHandler: completionHandler)
    }
    
    /**
     Update container metadata
     
     - Parameter metadata: a dictionary of metadata items, e.g. ["X-Container-Meta-Subject":"AmericanHistory"]. It is possible to supply multiple metadata items within same invocation. To delete a particular metadata item set it's value to an empty string, e.g. ["X-Container-Meta-Subject":""]. See Object Storage API v1 for more information about possible metadata items - http://developer.openstack.org/api-ref-objectstorage-v1.html
     */
    public func updateMetadata(metadata metadata:Dictionary<String, String>, completionHandler: (error: ObjectStorageError?)->Void){
        logger.info("Updating metadata :: \(metadata)")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error)
            }
            let headers = Utils.createHeaderDictionary(authToken: authToken, additionalHeaders: metadata)
            
            self.httpManager.post(resource: self.resource, headers: headers, data: nil) { error, status, headers, data in
                if let error = error {
                    completionHandler(error:ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Metadata updated :: \(metadata)")
                    completionHandler(error:nil)
                }
            }
        })
    }
    
    /**
     Retrieve container metadata. The metadata will be returned to a completionHandler as a Dictionary<String, String> instance with set of keys and values
     
     */
    public func retrieveMetadata(completionHandler completionHandler: (error: ObjectStorageError?, metadata: [String:String]?) -> Void) {
        logger.info("Retrieving metadata")
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, metadata: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.head(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(error: ObjectStorageError.from(httpError: error), metadata: nil)
                } else {
                    self.logger.info("Metadata retrieved :: \(headers)")
                    completionHandler(error: nil, metadata: headers);
                }
            }
        })
    }
}

