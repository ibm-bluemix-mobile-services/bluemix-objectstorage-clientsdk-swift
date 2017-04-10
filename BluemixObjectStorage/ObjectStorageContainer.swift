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



/// ObjectStorageContainer instance represents a single container on IBM Object Store service
open class ObjectStorageContainer{
    
    /// Container name
    open let name:String
    
    /// Container resource
    internal let resource:HttpResource
    
    internal let objectStore:ObjectStorage
    fileprivate let logger:Logger
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
    open func store(object name:String, data:Data, completionHandler: @escaping (ObjectStorageError?, ObjectStorageObject?)->Void){
        logger.info("Storing object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.put(resource: resource, headers: headers, data: data) { error, status, headers, responseData in
                if let error = error{
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                } else {
                    self.logger.info("Stored object [\(name)]")
                    let object = ObjectStorageObject(name: name, resource: resource, container: self, data: data)
                    completionHandler(nil, object)
                }
            }
        })
    }
    
    
    /**
     Retrieve an existing object
     
     - Parameter name: The name of the object to be retrieved
     */
    open func retrieve(object name:String, completionHandler: @escaping (ObjectStorageError?, ObjectStorageObject?)->Void){
        logger.info("Retrieving object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.get(resource: resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                } else {
                    self.logger.info("Retrieved object [\(name)]")
                    let object = ObjectStorageObject(name: name, resource: resource, container: self, data: data)
                    completionHandler(nil, object)
                }
            }
        })
    }
    
    
    /**
     Retrieve a list of existing objects
     
     */
    open func retrieveObjectsList(completionHandler: @escaping (ObjectStorageError?, [ObjectStorageObject]?)->Void){
        logger.info("Retrieving objects list")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.get(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                }else {
                    self.logger.info("Retrieved objects list")
                    var objectsList = [ObjectStorageObject]()
                    let responseBodyString = String(data: data!, encoding: String.Encoding.utf8)!
                    
                    let objectNames = responseBodyString.components(separatedBy: "\n")
                    
                    for objectName:String in objectNames{
                        if objectName.characters.count == 0 {
                            continue
                        }
                        let objectResource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + objectName))
                        let object = ObjectStorageObject(name: objectName, resource: objectResource, container: self)
                        objectsList.append(object)
                    }
                    completionHandler(nil, objectsList)
                }
                
            }
        })
    }
    
    /**
     Delete an existing object
     
     - Parameter name: The name of the object to be deleted
     */
    open func delete(object name: String, completionHandler: @escaping (ObjectStorageError?) -> Void){
        logger.info("Deleting object [\(name)]")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            let resource = self.resource.resourceByAddingPathComponent(pathComponent: Utils.urlPathEncode(text: "/" + name))
            
            self.httpManager.delete(resource: resource, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Deleted object [\(name)]")
                    completionHandler(nil)
                }
            }
        })
    }
    
    /**
     Delete the container
     
     */
    open func delete(completionHandler:@escaping (ObjectStorageError?)->Void){
        self.objectStore.delete(container: self.name, completionHandler: completionHandler)
    }
    
    /**
     Update container metadata
     
     - Parameter metadata: a dictionary of metadata items, e.g. ["X-Container-Meta-Subject":"AmericanHistory"]. It is possible to supply multiple metadata items within same invocation. To delete a particular metadata item set it's value to an empty string, e.g. ["X-Container-Meta-Subject":""]. See Object Storage API v1 for more information about possible metadata items - http://developer.openstack.org/api-ref-objectstorage-v1.html
     */
    open func update(metadata:[String: String], completionHandler: @escaping (ObjectStorageError?)->Void){
        logger.info("Updating metadata :: \(metadata)")
        
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error)
            }
            let headers = Utils.createHeaderDictionary(authToken: authToken, additionalHeaders: metadata)
            
            self.httpManager.post(resource: self.resource, headers: headers, data: nil) { error, status, headers, data in
                if let error = error {
                    completionHandler(ObjectStorageError.from(httpError: error))
                } else {
                    self.logger.info("Metadata updated :: \(metadata)")
                    completionHandler(nil)
                }
            }
        })
    }
    
    /**
     Retrieve container metadata. The metadata will be returned to a completionHandler as a [String: String] instance with set of keys and values
     
     */
    open func retrieveMetadata(completionHandler: @escaping (ObjectStorageError?, [String:String]?) -> Void) {
        logger.info("Retrieving metadata")
        objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error, nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.httpManager.head(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error {
                    completionHandler(ObjectStorageError.from(httpError: error), nil)
                } else {
                    self.logger.info("Metadata retrieved :: \(String(describing: headers))")
                    completionHandler(nil, headers);
                }
            }
        })
    }
}

