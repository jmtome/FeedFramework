## Comments Feature

### API Specs

### Payload Contract 


```
GET /image/{image-id}/comments 

2xx Response

{
  "items": [
 	 	{	
 	 		"id": "a UUID",
 	 		"message": "a message",
 	 		"created_at": "2020-05-20T11:24:59+0000",
 	 		"author": {
 	 			"username": "a username"
 	 		}
  		},
  		{	
 	 		"id": "another UUID",
 	 		"message": "another message",
 	 		"created_at": "2020-05-19T14:23:53+0000",
 	 		"author": {
 	 			"username": "another username"
 	 		}
  		},
  		...
  ]
}
```


### Feed Image Comment

| Property     | Type                    |
| ------------ | ----------------------- |
| `id`         | `UUID`                  |
| `message`    | `String`                |
| `created_at` | `Date` (ISO8601 String) |
| `author`     | `CommentAuthorObject`   |

### Feed Image Comment Author

| Property   | Type     |
| ---------- | -------- |
| `username` | `String` |



## Architecture for Base App

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125043480.png" alt="image-20230707125043480" style="zoom: 33%;" />



### First Approach to the architecture

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125206239.png" alt="image-20230707125206239" style="zoom:33%;" />

In Reality we dont need to have the **Comments Loader Protocol** since we wont be caching, usually protocols/interfaces are good for when we have more than one use of it. Its always good to simplify things when possible.

### Final Diagram

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125315715.png" alt="image-20230707125315715" style="zoom:33%;" />



## How can we create new features without duplicating code/ duplicating HTTPClients?

Starting with the architecture for the already existing FeedModule Feature: 

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125552910.png" alt="image-20230707125552910" style="zoom:50%;" />



We can follow the same design to approach the Comments section: 

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125651095.png" alt="image-20230707125651095" style="zoom:50%;" />

**Upsides**: These both modules are decoupled. Since we dont need multiple strategies, we dont need the **protocol**.

**Downsides**: There is **two** of everything. 



How can we do to avoid duplication?. --> Simplest thing we can do is to keep them in the same module, so the can therefore share the same types:

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707125914187.png" alt="image-20230707125914187" style="zoom:50%;" />



But then we lose the modularity that we want. Nonetheless its a good starting point.

- First we implement the `RemoteImageCommentsLoader`



Implementing `ImageCommentsMapper` and `RemoteImageCommentsLoader` is great, but we are still depending on the same `<HttpClient>`, what if we wanted to reuse the `Image Comments API` in some other place? 

Well, we could move it into another module: 



<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707191136440.png" alt="image-20230707191136440" style="zoom:50%;" />



But it would still depend on the `<HTTPClient>`. 



### First idea: 

We create **two** HTTP client protocols:



<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707191252597.png" alt="image-20230707191252597" style="zoom:50%;" />



This is actually a great idea, since the `ImageComments API` could want to post comments in the future, whereas the `Feed API` module doesn't, therefore it would make sense to have two different `HTTPClients` that work for every use case. Otherwise, if we used the same `HTTPClient` for both use cases, we would be breaking the **interface segregation principle** (clients should not depend on methods they do not need), since we would have to add methods to post data (comments) but the `Feed API` would not implement them. 

But, we still share the same Infrastructure implementation, although neither of the API modules knows about this. This is what's called **dependency inversion principle**,  where our Shared API Infra module doesnt depend on any implementation, but on abstractions, in this case `<HTTPClient>`.



### Second idea: 

We might not want to duplicate the client, we may want to share it: 

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707192117573.png" alt="image-20230707192117573" style="zoom:50%;" />

  

So what we would do is move the `<HTTPClient>` to the infrastructure module. This way they would share the client, but not depend on eachother, only on the shared infra module. The problem is that now those API modules depend on infrastructure details like the frameworks `(URLSession/HTTPCLient)`, which means we could not freely move the `Feed API` or the Image `Comments API` modules to another project without dragging the Shared API infra module, which would be a problem.



### Third idea:

Create a new module:

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707192545892.png" alt="image-20230707192545892" style="zoom:50%;" />

We could create a module comprised of pure interfaces. This way, while both the API modules would depend on the shared API module, they would not depend on any infrastructure implementation details. But the downside of this is that we end up having too many components in our architecture which we have to mantain. We have great modularity, but really annoying maintenance (constant redeploy-recompile)





In our case, since we will only have one module comprising everything we will go ahead with this last implementation, using folders to separate the modules. But we will have to have discipline to do this. For this we will create a Shared API folder in the root directory of our **FeedFramework** project folder, where we will place our `<HTTPClient>`protocol, representing the aforementioned diagram. We also create the Shared API Infra folder that will contain the implementation, to which we move the `URLSessionHTTPClient` class.

We do the same for the other components, creating a **Image Comments API** folder, and moving the corresponding files there. We apply the same logic for all the tests.





#### Duplication in the Loaders

We fixed our duplication in the `<HTTPClient>` but we still have a lot of duplication in our `RemoteFeedLoader` and our `RemoteIImageCommentsLoader` which look exactly the same with minor variations in the mapping. 

Duplicating the code is not all bad though, because without duplicating the code and analyzing what are the commonalities and similarities, we probably will end up arriving to the wrong abstractions because without comparison it's hard to see what is the same and what is not.



The way to solve this is creating a generic **RemoteLoader** and then inject the mapping for every case (which is what is different).



Once we've made the Generic **RemoteLoader<Resource>** , a very cunning thing we can do is to typealias our **RemoteImageCommentsLoader** with the specific type ([**ImageComment**]). We can do this because typealiasing doesnt break any clients. We can then make an extension to this typealias and add a convenience init:



```swift
public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
```



This way we dont break any existing uses of the ``` RemoteImageCommentsLoader``` and even the tests still work.



In the same fashion we repeat this procedure for the **RemoteFeedLoader**, which takes in a [**FeedImage**] as specific type:



```swift
public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
```



The new diagram is: 



<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230707211011118.png" alt="image-20230707211011118" style="zoom:50%;" />



The **RemoteLoader** lives in the Shared API module along with the **HTTPClient** interface and both the Feed API and the Image Comments API modules depend on the Shared API module.

They only depend on this module because of the **RemoteLoader** extensions , and these extensions **compose** the generic loader with the mapper, which means that **Composition details** can be moved to the composition root and then we eliminate the dependency on the shared module.



Finally, we can see that the Feed API Module and the Image Comments Module don't depend on any shared infrastructure:



<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230708140840336.png" alt="image-20230708140840336" style="zoom:50%;" />



they are all standalone modules.

We eliminated dependency of the API Infrastructure, we are "rejecting" the dependency. (Dependency Injection means that we are injecting the dependencies, the Dependency rejection means that we are changing our system so that we depend on higher abstractions)





Now, we can go one step further, using Combine we can make use of its universal abstractions to further diminish the need for our own. As such we can get rid of the **RemoteLoader** and we can compose the loader with Combine.

``` swift
public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}
```



And then we change our ``` makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher```  to: 

```swift
  private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        let remoteURL = URL(string: "http://api-url.com")!
        
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
```

This way, we Compose our use-cases with the infrastructure in a **functional** way, we dont ***inject*** dependencies, we ***compose*** them. We create ***composable functions*** and we compose it with the infrastructure, this is the *infamous* functional composition sandwich:

``` swift
[ side-effect ] - httpClient.getPublisher(url: remoteURL) 
-pure function  - .tryMap(FeedItemsMapper.map)
[ side-effect]  - .caching(to: localFeedLoader)
```





This way, our final design ends up looking like: 



<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230708160239981.png" alt="image-20230708160239981" style="zoom:50%;" />

We dont need a loader, everything is composed with abstractions.





## Old vs New Design 

### Old Design 

![image-20230708160330931](/Users/macbook/Library/Application Support/typora-user-images/image-20230708160330931.png)



### New Design 

![image-20230708160344181](/Users/macbook/Library/Application Support/typora-user-images/image-20230708160344181.png)



We dont have a **Loader** anymore, we just have the **FeedItemsMapper**, for the feed-use-case, everything composed in the Composition Root.

Since we dont have a component from the **FeedAPI** module conforming to the **FeedLoader** protocol (like the **RemoteFeedLoader**), we have only the **LocalFeedLoader** conforming to the **FeedLoader** (only one implementation), we don't even need the **<FeedLoader>** because we dont need a strategy anymore, so we can remove it.