//
//  PhaseBScreens.swift
//  GlutenFreeUITests
//
//  Drives navigation into the Phase B screens (store detail, paywall, menu)
//  and attaches a screenshot of each. Run against the live backend with the
//  autologin env set (see the run command in the project notes).
//

import XCTest

final class PhaseBScreens: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["GF_API_BASE_URL"] = "http://localhost:8090"
        app.launchEnvironment["GF_AUTOLOGIN_EMAIL"] = "demo@example.com"
        app.launchEnvironment["GF_AUTOLOGIN_PASSWORD"] = "demopass123"
        return app
    }

    private func snapshot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    private func openFirstStore(_ app: XCUIApplication) {
        let firstStore = app.staticTexts["米粉キッチン こめこ"]
        XCTAssertTrue(firstStore.waitForExistence(timeout: 20), "Explore list did not load")
        firstStore.tap()
        // Detail CTA is present immediately (renders from the passed card).
        _ = app.buttons.firstMatch.waitForExistence(timeout: 5)
        Thread.sleep(forTimeInterval: 1.2)
    }

    /// Run with demo UNSUBSCRIBED: captures store detail + the paywall sheet.
    @MainActor
    func test1DetailAndPaywall() throws {
        let app = makeApp()
        app.launch()

        openFirstStore(app)
        snapshot(app, "07-store-detail")

        let unlock = app.staticTexts["メニューを解放（メンバー限定）"]
        XCTAssertTrue(unlock.waitForExistence(timeout: 5), "Unlock CTA missing — is the demo user subscribed?")
        unlock.tap()
        Thread.sleep(forTimeInterval: 1.5)
        snapshot(app, "09-paywall")
    }

    /// Run with demo SUBSCRIBED: captures the unlocked menu screen.
    @MainActor
    func test2Menu() throws {
        let app = makeApp()
        app.launch()

        openFirstStore(app)
        snapshot(app, "08-detail-unlocked")

        let viewMenu = app.staticTexts["メニューを見る"]
        XCTAssertTrue(viewMenu.waitForExistence(timeout: 5), "「メニューを見る」 missing — demo user not subscribed?")
        viewMenu.tap()
        Thread.sleep(forTimeInterval: 1.8)
        snapshot(app, "10-menu")
    }
}
