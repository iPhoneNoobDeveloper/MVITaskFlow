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
    func testAddingTaskDisplaysItInTheList() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let field = app.textFields["task-title-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))

        field.tap()
        field.typeText("Ship architecture reference")
        app.buttons["add-task-button"].tap()

        XCTAssertTrue(app.staticTexts["Ship architecture reference"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testEmptyState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing-empty"]
        app.launch()

        XCTAssertTrue(app.otherElements["empty-state"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testErrorStateOffersRetry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing-error"]
        app.launch()

        XCTAssertTrue(app.buttons["retry-button"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
