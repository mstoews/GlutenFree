//
//  AppStoreScreens.swift
//  GlutenFreeUITests
//
//  Captures App Store marketing screenshots at native device resolution.
//  Run on each required device size (iPhone 6.9", iPad 13") against the live
//  backend on :8090, signed in as the subscribed demo account so menus unlock.
//
//  Example:
//    xcodebuild test -project GlutenFree.xcodeproj -scheme GlutenFree \
//      -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=18.3.1' \
//      -only-testing:GlutenFreeUITests/AppStoreScreens/testJapaneseSet \
//      -resultBundlePath /tmp/gf-appstore.xcresult CODE_SIGNING_ALLOWED=NO
//

import XCTest

final class AppStoreScreens: XCTestCase {

    override func setUpWithError() throws {
        // Keep going after a soft failure so we still capture later screens.
        continueAfterFailure = true
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    private func firstButton(_ app: XCUIApplication, labelContains text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    @MainActor func testJapaneseSet() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launchEnvironment["GF_API_BASE_URL"] = "http://localhost:8090"
        app.launchEnvironment["GF_AUTOLOGIN_EMAIL"] = "demo@example.com"
        app.launchEnvironment["GF_AUTOLOGIN_PASSWORD"] = "demopass123"
        app.launch()

        // 1) Explore — wait on the first store card (store names are data, not localized).
        let storeName = "米粉キッチン こめこ"
        let store = app.staticTexts[storeName].firstMatch
        XCTAssertTrue(store.waitForExistence(timeout: 30), "Explore did not load")
        Thread.sleep(forTimeInterval: 1.0)
        snap(app, "01-explore")

        // 2) Store detail — tap the card (a NavigationLink → button whose label
        //    contains the store name). Fall back to tapping the name text.
        let card = firstButton(app, labelContains: storeName)
        if card.waitForExistence(timeout: 5) { card.tap() } else { store.tap() }
        _ = app.staticTexts["場所・アクセス"].firstMatch.waitForExistence(timeout: 12)
        Thread.sleep(forTimeInterval: 1.2)
        snap(app, "02-detail")

        // 3) Menu — the subscribed demo sees "メニューを見る"; tap to open the menu.
        let menuCTA = firstButton(app, labelContains: "メニューを見る")
        if menuCTA.waitForExistence(timeout: 6) {
            menuCTA.tap()
            Thread.sleep(forTimeInterval: 2.0)
            snap(app, "03-menu")
            // Pop back so the tab bar is available for the next shot.
            let back = app.navigationBars.buttons.firstMatch
            if back.exists { back.tap(); Thread.sleep(forTimeInterval: 0.8) }
        }

        // 4) Account — switch to the アカウント tab.
        let accountTab = app.tabBars.buttons["アカウント"].firstMatch
        if accountTab.waitForExistence(timeout: 6) {
            accountTab.tap()
            Thread.sleep(forTimeInterval: 1.2)
            snap(app, "04-account")
        }
    }
}
