//
//  PhaseCScreens.swift
//  GlutenFreeUITests
//
//  Captures the Account redesign and verifies JA/EN localization by forcing
//  the app language via launch arguments. Run against the live backend.
//

import XCTest

final class PhaseCScreens: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp(language: String, locale: String, appearance: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchEnvironment["GF_API_BASE_URL"] = "http://localhost:8090"
        app.launchEnvironment["GF_AUTOLOGIN_EMAIL"] = "demo@example.com"
        app.launchEnvironment["GF_AUTOLOGIN_PASSWORD"] = "demopass123"
        if let appearance { app.launchEnvironment["GF_FORCE_APPEARANCE"] = appearance }
        return app
    }

    private func snapshot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    private func tab(_ app: XCUIApplication, _ index: Int) {
        app.tabBars.buttons.element(boundBy: index).tap()
        Thread.sleep(forTimeInterval: 1.0)
    }

    private func run(language: String, locale: String, suffix: String,
                     appearance: String? = nil, openMenu: Bool = false) {
        let app = makeApp(language: language, locale: locale, appearance: appearance)
        app.launch()

        // Explore (store names are data, not localized — wait on the first card).
        let firstStore = app.staticTexts["米粉キッチン こめこ"]
        XCTAssertTrue(firstStore.waitForExistence(timeout: 20), "Explore did not load (\(suffix))")
        Thread.sleep(forTimeInterval: 0.6)
        snapshot(app, "explore-\(suffix)")

        // Store detail.
        firstStore.tap()
        Thread.sleep(forTimeInterval: 1.4)
        snapshot(app, "detail-\(suffix)")

        // Optionally open the menu (subscribed demo → "メニューを見る").
        if openMenu {
            let viewMenu = app.staticTexts["メニューを見る"]
            if viewMenu.waitForExistence(timeout: 5) {
                viewMenu.tap()
                Thread.sleep(forTimeInterval: 1.6)
                snapshot(app, "menu-\(suffix)")
            }
        }

        // The tab bar stays visible on the pushed screen — jump to Account (3rd tab).
        tab(app, 2)
        snapshot(app, "account-\(suffix)")
    }

    @MainActor func test1English() throws { run(language: "en", locale: "en_US", suffix: "en") }
    @MainActor func test2Japanese() throws { run(language: "ja", locale: "ja_JP", suffix: "ja") }
    @MainActor func test3Dark() throws {
        run(language: "ja", locale: "ja_JP", suffix: "dark", appearance: "dark", openMenu: true)
    }
}
