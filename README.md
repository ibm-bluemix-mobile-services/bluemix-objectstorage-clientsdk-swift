<img src="https://bluemixassets.eu-gb.mybluemix.net/api/Products/image/logos/object-storage.svg?key=[bluemix-objectstorage-clientsdk-swift]&event=readme-image-view" alt="[BluemixObjectStorageSDK]" width="200px"/>

## Object Storage
Bluemix Client SDK for Object Storage in Swift

[![](https://img.shields.io/badge/bluemix-powered-blue.svg)](https://bluemix.net)
[![Build Status](https://travis-ci.org/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift.svg?branch=master)](https://travis-ci.org/ibm-bluemix-mobile-services/bluemix-objectstorage-clientsdk-swift)
 [![Platform](https://img.shields.io/cocoapods/p/BluemixObjectStorage.svg?style=flat)](http://cocoadocs.org/docsets/BluemixObjectStorage)

### Table of Contents
* [Summary](#summary)
* [Requirements](#requirements)
* [Installation](#installation)
* [Example Usage](#example-usage)
* [License](#license)

### Summary
Object Storage provides an unstructured cloud data store to build and deliver cloud applications and services with lowered cost, reliability, and speed to market. Bluemix developers and users can access and store unstructured data content and can interactively compose and connect to applications and services. The Object Storage service also provides programmatic access via API, SDKs and a consumable UI for object management.

You can use this client SDK to store and retrieve binary data on your Object Storage service instance on Bluemix from your iOS application.

Read the [official documentation](https://new-console.ng.bluemix.net/docs/services/ObjectStorage/index.html) for information about getting started with Object Storage.

[//]: # (Link to the Getting Started docs)
[//]: # (Replace [Service] with your Service name)

### Requirements
* iOS 8.0+
* Xcode 7+

### Installation

The Bluemix Mobile Services Swift SDKs are available via [Cocoapods](http://cocoapods.org/) and [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods
To install BluemixObjectStorage using Cocoapods, add it to your Podfile:

```ruby
use_frameworks!

target 'MyApp' do
    pod 'BluemixObjectStorage'
end
```

Make sure you have Cocoapods version [1.1.0.rc.2](https://github.com/CocoaPods/CocoaPods/releases) (or later) installed. Then run the `pod install` command. To update to a newer release of BluemixObjectStorage, use `pod update BluemixObjectStorage`.

#### Carthage

To install BMSAnalytics with Carthage, follow the instructions [here](https://github.com/Carthage/Carthage#getting-started).

Add this line to your Cartfile: 

```ogdl
github "ibm-bluemix-mobile-services/bluemix-objectstorage-clientdsk-swift"
```

Then run the `carthage update` command. Once the build is finished, add `BluemixObjectStorage.framework`, `BMSCore.framework` and `BMSAnalyticsAPI.framework` to your project. 

### Example Usage
[//]: # (You are going to want to put common scenarios for the examples here to avoid looking through the docs for non-complex usage)

* [Account metadata](#account-metadata)
* [Connecting to Object Storage](#connecting-to-object-storage)
* [Managing containers](#managing-containers)
* [Managing objects](#managing-objects)
* [Types of errors](#types-of-errors)

> View the complete API reference [here]().
[//]: # (link to JavaDoc, Jazzy for Swift, etc.)

--

#### Account metadata

##### Update account metadata

```swift
let metadata:[String: String] = ["X-Account-Meta-SomeName":"SomeValue"]
objstorage.update(metadata: metadata) { (error) in
	if let error = error {
		print("update metadata error :: \(error)")
	} else {
		print("update metadata success")
	}
}
```

##### Retrieve account metadata

```swift
objstorage.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieve metadata error :: \(error)")
	} else {
		print("retrieve metadata success :: \(metadata)")
	}
}
```
> [View examples](#example-usage)

--

#### Connecting to Object Storage
Use `ObjectStorage` instance to connect to IBM Object Storage service.

##### Connect to the IBM Object Storage service using userId and password

```swift
let objstorage = ObjectStorage(projectId:"your-project-id")
objstorage.connect(userId: "your-service-userId",
 				   password: "your-service-password",
				   region: ObjectStorage.Region.Dallas) { (error) in
	if let error = error {
		print("connect error :: \(error)")
	} else {
		print("connect success")
	}							
}
```

##### Connect to the IBM Object Storage service using explicit authToken

```swift
let objstorage = ObjectStorage(projectId:"your-project-id")
objstorage.connect(authToken: "your-auth-token",
		   		   region: ObjectStorage.Region.Dallas) { (error) in
	if let error = error {
		print("connect error :: \(error)")
	} else {
		print("connect success")
	}							
}
```
> [View examples](#example-usage)

--

#### Managing containers
Use ObjectStorage instance to manage containers.

##### Create a new container

```swift
objstorage.create(container: "container-name") { (error, container) in
	if let error = error {
		print("create container error :: \(error)")
	} else {
		print("create container success :: \(container?.name)")
	}
}
```

##### Retrieve an existing container

```swift
objstorage.retrieve(container: "container-name") { (error, container) in
	if let error = error {
		print("retrieve container error :: \(error)")
	} else {
		print("retrieve container success :: \(container?.name)")
	}
}
```

##### Retrieve a list of existing containers

```swift
objstorage.retrieveContainersList { (error, containers) in
	if let error = error {
		print("retrieve containers list error :: \(error)")
	} else {
		print("retrieve containers list success :: \(containers?.description)")
	}
}
```

##### Delete an existing container

```swift
objstorage.delete(container: "container-name") { (error) in
	if let error = error {
		print("delete container error :: \(error)")
	} else {
		print("delete container success")
	}
}
```
You can also use `ObjectStorageContainer` instance to manage containers


##### Delete the container

```swift
container.delete { (error) in
	if let error = error {
		print("delete container error :: \(error)")
	} else {
		print("delete container success")
	}
}
```

##### Update container metadata

```swift
let metadata:[String: String] = ["X-Container-Meta-SomeName":"SomeValue"]
container.update(metadata: metadata) { (error) in
	if let error = error {
		print("update metadata error :: \(error)")
	} else {
		print("update metadata success")
	}
}
```

##### Retrieve container metadata

```swift
container.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieveMetadata error :: \(error)")
	} else {
		print("retrieveMetadata success :: \(metadata)")
	}
}
```

> [View examples](#example-usage)

--

#### Managing Objects

Use `ObjectStorageContainer` instance to manage objects inside of particular container

##### Create a new object or update an existing one

```swift
let data = "testdata".data(using: NSUTF8StringEncoding)!
container.store(object: "object-name", data: data) { (error, object) in
	if let error = error {
		print("store object error :: \(error)")
	} else {
		print("store object success :: \(object?.name)")
	}
}
```

##### Retrieve an existing object

```swift
container.retrieve(object: "object-name") { (error, object) in
	if let error = error {
		print("retrieve object error :: \(error)")
	} else {
		print("retrieve object success :: \(object?.name)")
	}
}
```

##### Retrieve a list of existing objects

```swift
container.retrieveObjectsList { (error, objects) in
	if let error = error {
		print("retrieveObjectsList error :: \(error)")
	} else {
		print("retrieveObjectsList success :: \(objects?.description)")
	}
}
```

##### Delete an existing object

```swift
container.delete(object: "object-name") { (error) in
	if let error = error {
		print("delete object error :: \(error)")
	} else {
		print("delete object success")
	}
}
```

Use `ObjectStorageObject` instance to load object content on demand

##### Load the object content

```swift
object.load(shouldCache: false) { (error, data) in
	if let error = error {
		print("load error :: \(error)")
	} else {
		print("load success :: \(data)")
	}
}
```

##### Update object metadata

```swift
let metadata:[String: String] = ["X-Object-Meta-SomeName":"SomeValue"]
object.update(metadata: metadata) { (error) in
	if let error = error {
		print("update metadata error :: \(error)")
	} else {
		print("update metadata success")
	}
}
```

##### Retrieve object metadata

```swift
object.retrieveMetadata { (error, metadata) in
	if let error = error {
		print("retrieve metadata error :: \(error)")
	} else {
		print("retrieve metadata success :: \(metadata)")
	}
}
```
> [View examples](#example-usage)

--

#### Types of errors

#### ObjectStorageError

The `ObjectStorageError` is an enum with possible failure reasons

```swift
enum ObjectStorageError: ErrorType {
	case connectionFailure
	case notFound
	case unauthorized
	case serverError
	case invalidUri
	case failedToRetrieveAuthToken
	case notConnected
	case cannotRefreshAuthToken
}
```


### License
This package contains code licensed under the Apache License, Version 2.0 (the "License"). You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and may also view the License in the LICENSE file within this package.
