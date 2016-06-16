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
    import SimpleHttpClient
    import SimpleLogger
#endif

/// ObjectStorageObject instance represents a single object in the IBM Object Store service. Use ObjectStorageObject instance to load object content.
public class ObjectStorageObject{
    
    /// Object name
    public let name:String
    
    /// Object resource
    internal let resource:HttpResource
    
    internal let container:ObjectStorageContainer
    
    private let logger:Logger
    
    //HTTP Manager
    internal var manager:Manager
    
    /**
     Retrieved object NSData
     */
    public var data:NSData? = nil
    
    internal init(name:String, resource: HttpResource, container:ObjectStorageContainer, data:NSData? = nil){
        self.logger = Logger(forName:"ObjectStoreObject [\(container.name)]\\[\(name)]")
        self.name = name
        self.resource = resource
        self.container = container
        self.data = data
        self.manager = ClientManager()
    }
    
    /**
     Load the object content
     
     - Parameter shouldCache: Defines whether object content loaded from IBM Object Store service will be cached by this ObjectStoreObject instance
     */
    public func load(shouldCache shouldCache:Bool = false, completionHandler:(error:ObjectStorageError?, data:NSData?)->Void){
        logger.info("Loading object")
        
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, data: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.manager.get(resource: self.resource, headers: headers) { error, status, headers, data in
                if let error = error{
                    completionHandler(error: ObjectStorageError.from(httpError: error), data: nil)
                } else {
                    self.logger.info("Loaded object")
                    self.data = shouldCache ? data : nil;
                    completionHandler(error: nil, data: data)
                }
            }
        })
    }
    
    /**
     Delete the object
     */
    public func delete(completionHandler completionHandler:(error: ObjectStorageError?)->Void){
        self.container.deleteObject(name: self.name, completionHandler: completionHandler)
    }
    
    /**
     Update object metadata
     
     - Parameter metadata: a dictionary of metadata items, e.g. ["X-Object-Meta-Subject":"AmericanHistory"]. It is possible to supply multiple metadata items within same invocation. To delete a particular metadata item set it's value to an empty string, e.g. ["X-Object-Meta-Subject":""]. See Object Storage API v1 for more information about possible metadata items - http://developer.openstack.org/api-ref-objectstorage-v1.html
     */
    public func updateMetadata(metadata metadata:Dictionary<String, String>, completionHandler: (error: ObjectStorageError?)->Void){
        logger.info("Updating metadata :: \(metadata)")
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken, additionalHeaders: metadata)
            
            self.manager.post(resource: self.resource, headers: headers, data: nil) { error, status, headers, data in
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
     Retrieve object metadata. The metadata will be returned to a completionHandler as a Dictionary<String, String> instance with set of keys and values
     
     */
    public func retrieveMetadata(completionHandler completionHandler: (error: ObjectStorageError?, metadata: [String:String]?) -> Void){
        logger.info("Retrieving metadata")
        
        container.objectStore.authTokenManager?.refreshAuthToken({ (error, authToken) in
            guard error == nil else {
                return completionHandler(error: error, metadata: nil)
            }
            
            let headers = Utils.createHeaderDictionary(authToken: authToken)
            self.manager.head(resource: self.resource, headers: headers) { error, status, headers, data in
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
