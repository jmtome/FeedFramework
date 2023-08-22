## FeedFramework

### The goal of this project is to make a highly composable framework for fetching and creating an infinite scrollable feed of items that when tapped show a detail screen comprised of comments using clean architectures/ clean coding.

- The FeedFramework contains a series of modules that are composed in the Composition Root of the **FeedApp**.
- The **FeedApp** composes the necessary modules in the SceneDelegate making use of Combine's native abstractions. This way we loosen the coupling between the modules and allow for a higher degree of independance to make changes on the modules.
- The overall procedure of this framework and subsequent modules has been the use of TDD when possible.

### Working

- Read a Key-set Paging feed and display it.
- Show details screen with comments
- Modularization
- Testing

### To-Do
- Add like capability
- Generizise the Framework more to be able to easily implement any kind of networking
- Make a version of this project using SwiftUI
