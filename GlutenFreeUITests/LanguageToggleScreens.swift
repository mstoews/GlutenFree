//
//  LanguageToggleScreens.swift
//  GlutenFreeUITests
//
//  Verifies the in-app language toggle: open Account (JA), flip to English,
//  confirm the UI re-localizes live, then flip back.
//

import XCTest

final class LanguageToggleScreens: XCTestCase {

    override func setUpWithError() throws { continueAfterFailure = true }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let s = XCTAttachment(screenshot: app.screenshot())
        s.name = name; s.lifetime = .keepAlways; add(s)
    }

    @MainActor func testToggle() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP",
                                "-gf.languageOverride", "ja"]   // deterministic start
        app.launchEnvironment["GF_API_BASE_URL"] = "http://localhost:8090"
        app.launchEnvironment["GF_AUTOLOGIN_EMAIL"] = "demo@example.com"
        app.launchEnvironment["GF_AUTOLOGIN_PASSWORD"] = "demopass123"
        app.launch()

        // Account tab (3rd).
        let account = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(account.waitForExistence(timeout: 25), "tab bar did not load")
        account.tap(); Thread.sleep(forTimeInterval: 1.0)
        snap(app, "01-account-ja")

        // Flip to English.
        let en = app.buttons["English"].firstMatch
        XCTAssertTrue(en.waitForExistence(timeout: 5), "English segment not found")
        en.tap(); Thread.sleep(forTimeInterval: 1.5)
        snap(app, "02-account-en")

        // Explore in English (ward chips + store status should be English).
        app.tabBars.buttons.element(boundBy: 0).tap(); Thread.sleep(forTimeInterval: 1.5)
        snap(app, "03-explore-en")

        // Back to Account, flip to 日本語.
        app.tabBars.buttons.element(boundBy: 2).tap(); Thread.sleep(forTimeInterval: 1.0)
        let ja = app.buttons["日本語"].firstMatch
        if ja.waitForExistence(timeout: 5) { ja.tap(); Thread.sleep(forTimeInterval: 1.5) }
        snap(app, "04-account-ja-again")
    }
}
