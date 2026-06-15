//
//  MVITaskFlowUITests.swift
//  MVITaskFlowUITests
//
//  Created by Nirav Jain on 1/3/26.
//

import XCTest

final class MVITaskFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    private func launchApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        XCTAssertTrue(app.navigationBars["Tasks"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    func testAddingTaskDisplaysItInTheList() throws {
        let app = launchApp(arguments: ["--ui-testing"])

        let field = app.textFields["New task"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))

        field.tap()
        field.typeText("Ship architecture reference")
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
        app.buttons["Add task"].tap()

        XCTAssertTrue(app.staticTexts["Ship architecture reference"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testEmptyState() throws {
        let app = launchApp(arguments: ["--ui-testing-empty"])

        XCTAssertTrue(app.staticTexts["No tasks yet"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testErrorStateOffersRetry() throws {
        let app = launchApp(arguments: ["--ui-testing-error"])

        XCTAssertTrue(app.staticTexts["Could not load tasks"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Retry"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
