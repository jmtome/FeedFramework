//
//  FeedPresenterTests.swift
//  FeedFrameworkTests
//
//  Created by macbook on 03/07/2023.
//

import XCTest


final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMEssagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
    
}