

## Comments Feature

## Goals 

1. Display a list of comments when the user taps on an image in the feed.
2. Loading the comments can fail, so you must handle the UI states accordingly.
   - Show a loading spinner while loading the comments.
   - If it fails to load: Show an error message.
   - If it loads successfully: Show all loaded comments in the order they were returned by the remote API

3. The loading should start automatically when the user navigates to the screen.
   - The user should also be able to reload the comments manually (Pull-to-refresh)

4. At all times, the user should have a back button to return to the feed screen.
   - Cancel any running comments API requests when the user navigates back.
5. The comments screen layout should match the UI specs.
   - Present the comment date using relative date formatting, e.g., "1 day ago."
6. The comments screen title should be localized in all languages supported in the project
7. The comments screen should support Light and Dark Mode
8. Write tests to validate your implementaton, including unit, integration, and snapshot tests (aim to write the test first!).



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



Removing the `<FeedLoader>` :

![image-20230708163440470](/Users/macbook/Library/Application Support/typora-user-images/image-20230708163440470.png)



We get a much simpler design.



So, **Functional Style**: you dont ***inject*** dependencies, you ***compose*** them with the functional sandwich.





# How to create Reusable presentation logic layer

The presentation we have for the main feed is the same that we will have for the comments, we have the spinner, then either the sad case or the happy case. This presentation is even the same for the image loading, although with a different visual representation (spinner vs shimmering).

 So we have to see how to reuse this code, by making some sort of abstraction, and not duplicate. This way everytime we need to load a resource we can use the esame presentation



## Current Design 

 <img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230708172055346.png" alt="image-20230708172055346" style="zoom:50%;" />



We can see that the features are decoupled from eachother, and we want to keep it that way, even though they are going share presentation logic and may share infrastructure for loading details.



### Feed Presentation Logic 

![image-20230708172309142](/Users/macbook/Library/Application Support/typora-user-images/image-20230708172309142.png)

We have the **FeedPresenter** that we implemented in the presentation module, that creates`ViewModels` and passes them to the `<View>` protocols. So the **FeedPresenter** controls the loading of the resource, and the resource is the *feed* which is an array of images. 



We can follow the same design for the ***ImageComments*** but we would end up with duplication

![image-20230710125514633](/Users/macbook/Library/Application Support/typora-user-images/image-20230710125514633.png)

But, all the logic of the `LoadingViewModel`, `ErrorViewModel`, `*ViewModel` being passed to the `<View>` protocols is the same for both modules. So we dont't really need duplication. 



We can refactor the architecture as follows: 

![image-20230710125824709](/Users/macbook/Library/Application Support/typora-user-images/image-20230710125824709.png)

We create a shared module with all that is similar, ***SharedPresentation*** module, and we inject what is different into the generic presenter. So this way we can abstract all the loading of the resources into a reusable share logic and inject what is different (the mappings).



We can see that our modules are decoupled from eachother, how is this possible? By using a Composition Root, this allows us to compose all the modules with whatever abstract dependencies they may have, in a single place, without needing them to be directly coupled by themselves.

Usually its very common to see projects where all the code is _coupled_ with a **SharedModule**, with lots of arrows coming into the shared module. But we do not want this because any changes to the SharedModule would mean at minimum needing to recompile and redeploy, and at worse needing to modify the coupled modules. So the best thing is to have them all decoupled, and then use a **Composition Root**.



### Generalization of the previously existing Presenter logic

Our **FeedPresenter** is comprised at the moment with the following protocol view dependencies: 

``````swift
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
``````

and the following methods: 

```swift
 public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
}
public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
}
public func didFinishLoadingFeed(with error: Error) {
     		errorView.display(.error(message: feedLoadError))
  		  loadingView.display(FeedLoadingViewModel(isLoading: false))
}
```

Doing an analysis we can see that what they do is:`data in → creates view models → data out to the UI` :



` Void` →`creates view models` → `sends to the UI`

```swift
 public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
}
```

` [FeedImage]` →`creates view models` → `sends to the UI`

```swift
public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
}
```

` Error` →`creates view models` → `sends to the UI`

```swift
public func didFinishLoadingFeed(with error: Error) {
     		errorView.display(.error(message: feedLoadError))
  		  loadingView.display(FeedLoadingViewModel(isLoading: false))
}
```







And, we would need our ImageComments to function in a similar fashion: 

` [ImageComment]` →`creates view models` → `sends to the UI`

For images we would need: 

` Data` →`creates UIImage` → `sends to the UI`



We come to the conclusion that basically what we need is :

` Resource` →`creates ResourceViewModel` → `sends to the UI`

Thereforethe goal is to create a  generic **Presenter** with the above logic.



### Procedure

We start by adding a new test file, copying the already existing tests for the already existing **FeedPresenter**, but for our new generic presenter **LoadResourcePresenter**. We analyze which tests make sense for a generic presenter and which dont. We also realize that both the ***resource*** as well as the ***view model*** to be used are to be also generic, for which we will need to inject custom ***mappers*** that map the `resource`→`resourceViewModel` .

 (For the tests we need to use a type, since we cant test generics in a generic way, so we choose to use the **String** type, but any type will do, we use **String** because due to its verbosity its easier to read than another type like **Int**.)



##### Advice: Before you make it generic, make it concrete, otherwise if you try to change behaviour while trying to make it generic at the same time you will have a lot of compiler errors and problems that will confuse you



Once we've made the **ResourcePresenter**, we have to replace the original **FeedPresenter** with the generic one, and we need to inject the mapping.

After that we need to do the same and unify the **FeedImagePresenter** , which will have the same three states, *loading*, *error*, and *success(uiImage)*





We could even make the **FeedLoaderPresentationAdapter** generic since its very similar to the **FeedImageDataLoaderPresentationAdapter**:

1) they tell the presenter they start loading
2) if there is a failure it passes a failure to the presenter
3) if there is a success it passes data to the presenter



The idea is that we end up using the **FeedImagePresenter** in the same fashion as the **FeedPresenter**, only to inject mapping.



To be able to use the generic `LoadResourcePresenter`, we need to have the same cases: *loading, success(data), error(error)* that we did for the **FeedPresenter**,

To do this we will have to refactor the `FeedImageViewModel<Image>` into what is image specific and what is image-data-loading specific.



To do this we start with a test:

```swift
 func test_map_createsViewModel() {
        let image = uniqueImage()

        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
}
```

We state that we want a `map(_ image: Image)-> FeedImageViewModel `, that takes in an image and maps it into a **FeedImageViewModel**.



From the original `FeedImageViewModel<Image>`: 

```swift
public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    public var hasLocation: Bool {
        return location != nil
    }
}
```

The only properties that will remain in the **FeedImageViewModel** will be `description` and `location` which are the true properties related to the FeedImage, the rest are either related to loading or to error, and will be moved to other ViewModels.





First of all we need to replace the **FeedImageDataLoaderPresentationAdapter** from the **FeedViewAdapter** with the generic **LoadResourcePresentationAdapter**.



We have to go from:

```swift
let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)

```

to:

```swift
let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: () -> AnyPublisher<Resource, Error>)
```



But as we can see, we have unmatching types, since the **FeedImageDataLoaderPresentationAdapter** takes in a model (which it uses to get the URL for the closure) and an `imageLoader: (URL) -> AnyPublisher<(Data, HTTPURLResponse), Error>`, but the **LoaderResourcePresentationAdapter** only takes in a `loader: () -> AnyPublisher<Resource, Error>` closure. 



So what we can do in this situation is pass a custom closure that calls the `imageLoader(model.url)`, and thus we are adapting the `imageLoader`method that takes in a parameter into a closure that takes in no parameters. This is called ***partial application of functions*** and it allows us to adapt closures: 

By doing this, we are able to adapt from a closure that takes in a parameter, like `imageLoader(url)`, by pre-passing the required parameter, and thus we wont need to pass the model, therefore having a signature that looks alike the previous adapter one. 

This way the client/caller doesnt need to know about the model parameter, it stays in the composition. In essence what we have here is another Adapter, adapting inputs and outputs to our convenience.



The other thing that we see when analyzing the existing code, is that the existing **FeedImageDataLoaderPresentationAdapter** passes the model around through the presenter, so the presenter can send it to the UI, but we don't need to do that, we can pass the ViewModel directly to the **FeedImageCellController**, because the ViewModel is immutable, this is because we already have access to the **model**, which is immutable, thus the **FeedImageViewModel** will be immutable (because both the *description* and *location* don't change, they are `let`).

Therefore we can pass in the **ViewModel** to the **FeedImageCellController** at construction time. **(Things that dont change, can be passed in initialization time, and things that change over time you pass either through property injection or method injection)**

To do this we only need to use the `map`function from the `FeedImagePresenter` that we created earlier and do: 

```swift
let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter)

```

This change allows us to modify the **FeedImageCellController**. Now we will keep a copy **FeedImageViewModel<UIImage>** that will be immutable, except for its UIImage which will came asynchronously from the network. This means we can move some code from the `func display(_ viewModel: FeedImageViewModel)` into the `func view(in tableView:)`, method because we will have that information at that time.

Next step is to modify the **FeedImageCellController** so that it conforms to the <ResourceView>, <ResourceLoadingView> and <ResourceErrorView> protocol, which means that we get the new `display(_ viewmodel: Resource)` , `display(_ viewModel: ResourceLoadingViewModel)` and `display(_ viewModel: ResourceErrorViewModel)` (where Resource is passed in as UIImage for this case).

This way, we get rid of our original `func display(_ viewModel: FeedImageViewModel)` and its code gets distributed into the three different viewModel states of loading, success and error.



Finally, we remove all the logic related to the **FeedImagePresenter** , in lieu of the new generic presenter.



Next step is to finally implement the **ImageCommentsPresenter**, which in the same fashion as before, will have a `map(_ model: [ImageComment]) -> ImageCommentsViewModel` method. **ImageCommentsViewModel** is just a wrapper for an array of **ImageCommentViewModel**. 

```swift
public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel {
    public let message: String
    public let date: String
    public let username: String
}
```

our map function is: 



```swift
  public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        ImageCommentsViewModel(comments: comments.map { comment in
            let formatter = RelativeDateTimeFormatter()
            let localizedDate = formatter.localizedString(for: comment.createdAt, relativeTo: Date())
            
            return ImageCommentViewModel(message: comment.message, date: localizedDate, username: comment.username)
        })
    }
```



But there is a problem with this map function, which is that it is not taking into account any of the locale data for the date, which makes our tests brittle.

So we modify our map function to take into account the current date, locale, and calendar parameters to properly create the viewModel.

```swift
public static func map(_ comments: [ImageComment],
                           currentDate: Date = Date(),
                           calendar: Calendar = .current,
                           locale: Locale = .current) -> ImageCommentsViewModel {
        
        ImageCommentsViewModel(comments: comments.map { comment in
            let formatter = RelativeDateTimeFormatter()
            formatter.calendar = calendar
            formatter.locale = locale
            
            let localizedDate = formatter.localizedString(for: comment.createdAt, relativeTo: currentDate)
            
            return ImageCommentViewModel(message: comment.message, date: localizedDate, username: comment.username)
        })
}
```

This way we can properly test different locales and what date string results they return.

This is all that that was required for the **ImageCommentsPresenter** layer. (literally a map and a title, the rest is reused.)



We now have a **very clear way** to add new resource presenters, and adding new API mappers without duplicating code nor coupling modules: 

- Everytime there is a new feature, we just create a new API mapper that maps from **domain model** to **view model**, and then we compose with the composable logic in the UICompositionRoot.



We are now ready to implement the UILayer for the comments section. As an additional note, it would be possible to create an adapter between the presenter and the view layer so that both could be changed without incurring in trouble for the dependant layer , but for this case it's not neccesary.



Truth is, that we dont even need the Specific Presenter, because at this point it's just a namespace for the map function, and we can inject directly the init for the viewmodels instead of the map functions.



## Image Comments UI Layer

 In the previous sections we implemented: 

- [x] API (Live 001)
- [x] Presentation (Live 002)

Now we will implement: 

- [ ] UI (Live 003)
  - [ ] Reusing UI components (without breaking modularity)
  - [ ] Creating UI elements programatically
  - [ ] Diffable Data Sources
  - [ ] Dynamic Fonts (aka Dynamic Type)
  - [ ] Snapshot testing

In the following Live we will implement:

- [ ] Composition (Live 004)



### First Analysis

At first sight we can say that views are generally the same, the only thing that is going to change for our UI is the cell configuration, and the loading/error view is exactly the same for both the feed and the comments section. 

So we are going to reuse as much as we can the same UI from our existing feed, this way we avoid code duplication and we guarantee a smooth user experience. 

We are going to genericize our existing ui and just inject the different changes when needed, which in this case is the cell.  



As usual, we start by having a look at our diagram: 

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230711175044641.png" alt="image-20230711175044641" style="zoom:50%;" />



We have already implemented the **Feed UI** , now its time to implement the **Comments UI** 



Lets take a look at our **Feed User Interface Design**: 

![image-20230711175145002](/Users/macbook/Library/Application Support/typora-user-images/image-20230711175145002.png)

So, we have a **FeedViewController** that implements some shared Presentation Interfaces/ protocols and it renders a collection of **FeedImageCellControllers**, and each **FeedImageCellController** renders a Cell configured for a specific **FeedImageViewModel**, so every CellController is specific to one cell, and the **FeedViewController** coordinates the collection of **CellControllers** , we can see this here:

```swift
public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    .....
    .....
}
```

These **FeedImageCellController**s are a bunch of tiny MVC's controlling specific parts of the UI, in this case, the Cells:

```swift
public final class FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    
    private let viewModel: FeedImageViewModel
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
  ...
  ...
}
```

Where the ViewModel is the model, the Cell is the View and then the Controller.



So, we could follow the same design and create an **ImageCommentsViewController** that coordinates a collection of **ImageCommentCellControllers** that renders **ImageCommentsViewModel**. 

<img src="/Users/macbook/Library/Application Support/typora-user-images/image-20230711180432621.png" alt="image-20230711180432621" style="zoom:50%;" />



But what is the **problem** with this approach?  :arrow_right:  :arrow_right: **Duplication** . We would have complete duplication, which is not what we want. What we want to do is to make the **FeedImageCellController** that we already have generic so that it can display whatever we want by injecting different types of cell controllers.



What we can do is create a **Shared UI Module** with shared logic. We could create a **ListViewController** that can render any type of `<CellController>` abstraction, instead of having concrete-typed **FeedViewController** and **ImageCommentsViewController**: 

![image-20230711180656285](/Users/macbook/Library/Application Support/typora-user-images/image-20230711180656285.png)

And both the  **FeedImageCellController** and **ImageCommentCellController**  would implement  this abstraction:  `<CellControllers>` which doesn't know about concrete, feature specific **CellControllers**, which means we can add new features and reuse the **ListViewController**.   



First of all we create the  **<CellController>** protocol by extracting the method names that we need to abstract: 

```swift
public protocol CellController {
    func view(in tableview: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}
```

Then we replace all the instances of **FeedImageCellController** with **<CellController>** . Now, any concrete class that implements CellController can be used to render Cells in the FeedViewController.

So we start by making **FeedImageCellController** conform to our new abstraction **<CellController>**: 

```swift
public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView, ResourceErrorView {}
```





