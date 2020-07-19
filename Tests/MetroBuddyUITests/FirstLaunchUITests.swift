import XCTest
import MetroTesting

final class FirstLaunchUITests: ScenarioBasedTestCase<MetroCardPage> {
    func testThatItDoesNotAllowSwipeWithoutAddingBalance() {
        let page = rootPageWithScenario(NewInstallTestScenario.self)

        // The correct initial values are displayed
        XCTAssertEqual(page.balanceValue, "$0.00")
        XCTAssertEqual(page.fareValue, "$2.75")

        // When swiping, we show the toast
        page.performSwipe()
        XCTAssertEqual(page.balanceValue, "$0.00")
        XCTAssertEqual(page.subtitle, "No swipes left")
        XCTAssertEqual(page.toastText, "INSUFFICIENT FARE")
    }

    func testThatItHidesTipAfterAddingBalance() {
        let page = rootPageWithScenario(NewInstallTestScenario.self)

        // The tip is displayed at first
        XCTAssertTrue(page.tipTitle.exists)
        XCTAssertTrue(page.tipMessage.exists)
        XCTAssertFalse(page.swipeButton.exists)

        // After adding balance, the tip is hidden
        let alert = page.tapBalanceButton()
        alert.enterText("25")
        alert.tapSave()
        XCTAssertFalse(page.tipTitle.exists)
        XCTAssertFalse(page.tipMessage.exists)
        XCTAssertTrue(page.swipeButton.exists)
    }
}
