//
//  RTLHelper.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI
import UIKit

struct RTLHelper {
    static var isRTL: Bool {
        return UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft
    }
    
    static var currentLanguageCode: String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    static var isArabic: Bool {
        return currentLanguageCode == "ar"
    }
    
    // Force RTL layout for specific views if needed
    static func configureRTL(for view: UIView) {
        if isRTL {
            view.semanticContentAttribute = .forceRightToLeft
        } else {
            view.semanticContentAttribute = .forceLeftToRight
        }
    }
}

// SwiftUI Environment Key for RTL
struct IsRTLKey: EnvironmentKey {
    static let defaultValue: Bool = RTLHelper.isRTL
}

extension EnvironmentValues {
    var isRTL: Bool {
        get { self[IsRTLKey.self] }
        set { self[IsRTLKey.self] = newValue }
    }
}
