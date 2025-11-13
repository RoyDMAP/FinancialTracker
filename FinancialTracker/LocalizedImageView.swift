//
//  LocalizedImageView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI

struct LocalizedImageView: View {
    let imageName: String
    
    var localizedImageName: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch locale {
        case "es":
            return "flag-es"
        case "ja":
            return "flag-ja"
        default:
            return "flag-en"
        }
    }
    
    var flagEmoji: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch locale {
        case "es":
            return "🇲🇽" // Mexico flag for Latin American Spanish
        case "ja":
            return "🇯🇵" // Japan flag
        default:
            return "🇺🇸" // US flag
        }
    }
    
    var body: some View {
        Text(flagEmoji)
            .font(.system(size: 28))
    }
}
