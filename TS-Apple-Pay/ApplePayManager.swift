//
//  ApplePayManager.swift
//  TS-Apple-Pay
//
//  Created by Thomas Sillmann on 17.01.19.
//  Copyright © 2019 Thomas Sillmann. All rights reserved.
//

import Foundation
import PassKit

class ApplePayManager {
    
    // MARK: - Type alias
    
    private typealias PurchaseItem = [String: NSNumber]
    
    // MARK: - Properties
    
    static let shared = ApplePayManager()
    
    private let purchaseItemsPlistFileName = "PurchaseItems"
    
    private lazy var purchaseItemsPlistFileURL = Bundle.main.url(forResource: purchaseItemsPlistFileName, withExtension: "plist")!
    
    private lazy var purchaseItemsPlistData = try! Data(contentsOf: purchaseItemsPlistFileURL)
    
    lazy var availablePaymentSummaryItems: [PKPaymentSummaryItem] = {
        var availablePaymentSummaryItems = [PKPaymentSummaryItem]()
        let purchaseItemsPlistContent = try! PropertyListSerialization.propertyList(from: purchaseItemsPlistData, format: nil) as! PurchaseItem
        for (purchaseItemName, purchaseItemPrice) in purchaseItemsPlistContent {
            let paymentSummaryItem = PKPaymentSummaryItem(label: purchaseItemName, amount: NSDecimalNumber(decimal: purchaseItemPrice.decimalValue))
            availablePaymentSummaryItems.append(paymentSummaryItem)
        }
        return availablePaymentSummaryItems.sorted { $0.label > $1.label }
    }()
    
    let merchantIdentifier = "merchant.de.thomassillmann.TS-Apple-Pay"
    
}

extension PKPaymentSummaryItem {
    
    var formattedAmount: String {
        let currencyNumberFormatter = NumberFormatter()
        currencyNumberFormatter.numberStyle = .currency
        currencyNumberFormatter.locale = Locale(identifier: "DE")
        currencyNumberFormatter.currencyCode = "EUR"
        return currencyNumberFormatter.string(from: amount)!
    }
    
}
