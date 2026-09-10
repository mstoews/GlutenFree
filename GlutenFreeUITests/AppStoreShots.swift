//
//  AppStoreShots.swift
//  GlutenFreeUITests
//
//  Marketing capture for App Store Connect. Unlike AppStoreScreens.swift (which
//  hardcodes one store name), this drives the UI generically so it survives
//  catalog changes and runs unmodified on both iPhone and iPad.
//
//  Driven by scripts/appstore_screenshots.sh — see that script for the device ×
//  locale matrix. Requires the Go backend on :8090 and the subscribed demo
//  account, so the menu screen renders unlocked rather than as the paywall.
//
//  Element queries avoid localized labels: cards are found by text height,
//  tabs by position, and the layout switcher by its SF Symbol identifier. That
//  keeps one test body working for every locale in the matrix.
//

import XCTest

final class AppStoreShots: XCTestCase {

    override func setUpWithError() throws {
        // Never bail early: a missing screen should cost one shot, not the set.
        continueAfterFailure = true
    }

    // MARK: - Launch

    /// The locale is baked into the test name rather than read from the
    /// environment. Environment set on the `xcodebuild` process does not reach
    /// the runner — it is a separate process inside the simulator — so an
    /// env-driven locale silently falls back to its default on every run.
    private func makeApp(lang: String, locale: String) -> XCUIApplication {
        let env = ProcessInfo.processInfo.environment
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(\(lang))",
            "-AppleLocale", locale,
            "-gf.languageOverride", lang,   // in-app override, kept in step with the OS locale
            "-gf.paywallSeen", "1",         // suppress the onboarding paywall sheet
        ]
        // Deliberately no "-gf.selectedTab": launch arguments land in
        // NSArgumentDomain, which outranks anything @AppStorage writes back, so
        // pinning it would freeze the TabView on Explore for the whole run.
        // The script uninstalls the app instead, which resets the tab to 0.
        app.launchEnvironment["GF_API_BASE_URL"] = env["GF_API_BASE_URL"] ?? "http://localhost:8090"
        app.launchEnvironment["GF_AUTOLOGIN_EMAIL"] = env["GF_AUTOLOGIN_EMAIL"] ?? "demo@example.com"
        app.launchEnvironment["GF_AUTOLOGIN_PASSWORD"] = env["GF_AUTOLOGIN_PASSWORD"] ?? "demopass123"
        if let appearance = env["GF_FORCE_APPEARANCE"] {
            app.launchEnvironment["GF_FORCE_APPEARANCE"] = appearance
        }
        return app
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    private func settle(_ seconds: TimeInterval = 1.2) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - Element lookup

    /// Explore has two scroll views — the ward-chip strip and the store list.
    /// The store list is always the taller one.
    private func storeList(_ app: XCUIApplication) -> XCUIElement? {
        let scrolls = app.scrollViews
        guard scrolls.element(boundBy: 0).waitForExistence(timeout: 45) else { return nil }

        // The list populates a beat after the chips; poll until a tall one shows up.
        for _ in 0..<40 {
            var best: XCUIElement?
            var bestHeight: CGFloat = 0
            for i in 0..<scrolls.count {
                let candidate = scrolls.element(boundBy: i)
                guard candidate.exists else { continue }
                let height = candidate.frame.height
                if height > bestHeight { bestHeight = height; best = candidate }
            }
            if let best, bestHeight > 200 { return best }
            settle(0.5)
        }
        return nil
    }

    /// The card title is the tallest static text in a card (16.5pt bold vs the
    /// 11–13pt badges and meta line around it), so height separates it cleanly
    /// from 'GF対応店', '要相談', the price marks and the '·' separators.
    private func firstStoreTitle(_ app: XCUIApplication) -> XCUIElement? {
        guard let list = storeList(app) else { return nil }
        let texts = list.staticTexts
        guard texts.element(boundBy: 0).waitForExistence(timeout: 30) else { return nil }

        var fallback: XCUIElement?
        for i in 0..<min(texts.count, 40) {
            let el = texts.element(boundBy: i)
            guard el.exists, el.isHittable, !el.label.isEmpty else { continue }
            if el.frame.height >= 18 { return el }
            if fallback == nil && el.label.count >= 6 { fallback = el }
        }
        return fallback
    }

    /// Tab order matches MainTabView: 0 Explore, 1 Saved, 2 Account.
    private static let tabSymbols = ["magnifyingglass", "heart", "person"]

    /// iPhone puts the tabs in a real `TabBar` element, so position is enough —
    /// and position is all that is reliable there, because SwiftUI only
    /// intermittently lifts a `Label`'s SF Symbol identifier onto the tab button.
    ///
    /// iPadOS 26 renders the same TabView as a floating strip of loose buttons
    /// at the top of the window with no `TabBar` container at all, so there the
    /// symbol identifier is the only handle. Card hearts share the `heart`
    /// identifier, hence picking the topmost match.
    private func tabButton(_ app: XCUIApplication, _ index: Int) -> XCUIElement? {
        let barButtons = app.tabBars.buttons
        if barButtons.count >= 3 {
            let element = barButtons.element(boundBy: index)
            if element.exists { return element }
        }

        let matches = app.buttons.matching(identifier: Self.tabSymbols[index])
        var topmost: XCUIElement?
        var topmostY = CGFloat.greatestFiniteMagnitude
        for i in 0..<matches.count {
            let element = matches.element(boundBy: i)
            guard element.exists, element.isHittable else { continue }
            if element.frame.minY < topmostY {
                topmostY = element.frame.minY
                topmost = element
            }
        }
        return topmost
    }

    /// Both layouts settle within a few seconds of launch; poll rather than
    /// waiting on one specific element that only exists on one of them.
    @discardableResult
    private func waitForTabs(_ app: XCUIApplication, timeout: TimeInterval = 90) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let explore = tabButton(app, 0), explore.exists { return true }
            settle(0.5)
        }
        return false
    }

    // MARK: - Probe

    /// Dumps the accessibility tree so queries can be written against real
    /// labels. Not part of a capture run — invoke explicitly when the UI moves.
    @MainActor func testProbeAccessibilityTree() throws {
        let app = makeApp(lang: "ja", locale: "ja_JP")
        app.launch()
        XCTAssertTrue(waitForTabs(app), "never reached the tabs")
        settle(2.5)

        var dump = "===== EXPLORE =====\n" + app.debugDescription
        if let card = firstStoreTitle(app) {
            card.tap()
            settle(2.5)
            dump += "\n\n===== DETAIL =====\n" + app.debugDescription
        } else {
            dump += "\n\n(no store card resolved)"
        }

        let attachment = XCTAttachment(string: dump)
        attachment.name = "accessibility-tree"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Capture

    @MainActor func testCaptureJapanese() throws { try capture(lang: "ja", locale: "ja_JP") }
    @MainActor func testCaptureEnglish() throws { try capture(lang: "en", locale: "en_US") }

    @MainActor private func capture(lang: String, locale: String) throws {
        let app = makeApp(lang: lang, locale: locale)
        app.launch()
        XCTAssertTrue(waitForTabs(app), "never reached the tabs")

        guard let list = storeList(app) else {
            XCTFail("Explore never produced a store list — backend down or catalog empty?")
            return
        }
        settle(3.5)   // let the store photos finish decoding

        // 1) Explore, default rich/hero layout.
        snap(app, "01-explore")

        // 2) Explore, grid layout.
        let gridButton = app.buttons["square.grid.2x2"].firstMatch
        if gridButton.exists && gridButton.isHittable {
            gridButton.tap()
            settle(2.5)
            snap(app, "02-explore-grid")
            let richButton = app.buttons["rectangle.grid.1x2"].firstMatch
            if richButton.exists && richButton.isHittable { richButton.tap(); settle(2.0) }
        }

        // Heart the first few cards so the Saved tab has content later. These are
        // scoped to the list, which keeps them clear of the tab bar's 'heart'.
        let hearts = list.buttons.matching(identifier: "heart")
        for i in 0..<min(hearts.count, 3) {
            let heart = hearts.element(boundBy: i)
            if heart.exists && heart.isHittable { heart.tap(); settle(0.4) }
        }

        // 3) Store detail.
        guard let card = firstStoreTitle(app) else {
            XCTFail("no store card title resolved on Explore")
            return
        }
        let storeName = card.label
        card.tap()
        settle(3.0)
        snap(app, "03-detail")

        // 4) Menu — the subscribed demo gets a "view menu" CTA instead of the paywall.
        let menuCTA = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "メニューを見る", "View menu")
        ).firstMatch
        if menuCTA.waitForExistence(timeout: 10) && menuCTA.isHittable {
            menuCTA.tap()
            settle(3.0)
            snap(app, "04-menu")
        } else {
            XCTFail("menu CTA missing on \(storeName) — is the demo account still subscribed?")
        }

        // 5) Saved. The tabs stay visible on pushed screens, so jump directly.
        if let savedTab = tabButton(app, 1), savedTab.isHittable {
            savedTab.tap()
            settle(2.0)
            snap(app, "05-saved")
        } else {
            XCTFail("Saved tab not reachable")
        }

        // 6) Account.
        if let accountTab = tabButton(app, 2), accountTab.isHittable {
            accountTab.tap()
            settle(2.0)
            snap(app, "06-account")
        } else {
            XCTFail("Account tab not reachable")
        }
    }
}
