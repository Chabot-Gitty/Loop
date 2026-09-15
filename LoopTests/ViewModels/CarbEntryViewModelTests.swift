//
//  CarbEntryViewModelTests.swift
//  LoopTests
//
//  Copyright © 2026 LoopKit Authors. All rights reserved.
//

import XCTest
import LoopKit
@testable import Loop

// CarbEntryViewModel's full initializers require a CarbEntryViewModelDelegate,
// which extends BolusEntryViewModelDelegate (a large protocol covering pump,
// glucose, and dosing operations unrelated to favorite-food selection). No
// mock for it exists elsewhere in this suite, and building one solely to
// cover the Nocturne GI-to-absorption-time mapping would be disproportionate
// to what that mapping actually needs to be correct. That mapping is
// implemented as a static, dependency-free function specifically so it can
// be tested in isolation here, independent of the view model's instance
// state and its delegate.
final class CarbEntryViewModelTests: XCTestCase {
    private let defaultAbsorptionTimes: CarbStore.DefaultAbsorptionTimes = (fast: .hours(2), medium: .hours(3), slow: .hours(4))

    func testNocturneAbsorptionTimeLowGiMapsToSlow() {
        let result = CarbEntryViewModel.nocturneAbsorptionTime(forGiLevel: 1, defaultAbsorptionTimes: defaultAbsorptionTimes)
        XCTAssertEqual(result, defaultAbsorptionTimes.slow)
    }

    func testNocturneAbsorptionTimeMediumGiMapsToMedium() {
        let result = CarbEntryViewModel.nocturneAbsorptionTime(forGiLevel: 2, defaultAbsorptionTimes: defaultAbsorptionTimes)
        XCTAssertEqual(result, defaultAbsorptionTimes.medium)
    }

    func testNocturneAbsorptionTimeHighGiMapsToFast() {
        let result = CarbEntryViewModel.nocturneAbsorptionTime(forGiLevel: 3, defaultAbsorptionTimes: defaultAbsorptionTimes)
        XCTAssertEqual(result, defaultAbsorptionTimes.fast)
    }

    func testNocturneAbsorptionTimeOutOfRangeLowMapsToSlow() {
        // Defensive: Nocturne's documented range is 1-3, but decode below
        // clamps nothing, so an unexpected 0 should still resolve sensibly
        // rather than falling through to a default that misrepresents it.
        let result = CarbEntryViewModel.nocturneAbsorptionTime(forGiLevel: 0, defaultAbsorptionTimes: defaultAbsorptionTimes)
        XCTAssertEqual(result, defaultAbsorptionTimes.slow)
    }

    func testNocturneAbsorptionTimeOutOfRangeHighMapsToFast() {
        let result = CarbEntryViewModel.nocturneAbsorptionTime(forGiLevel: 99, defaultAbsorptionTimes: defaultAbsorptionTimes)
        XCTAssertEqual(result, defaultAbsorptionTimes.fast)
    }
}
