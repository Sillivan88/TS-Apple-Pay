//
//  ViewController.swift
//  TS-Apple-Pay
//
//  Created by Thomas Sillmann on 07.01.19.
//  Copyright © 2019 Thomas Sillmann. All rights reserved.
//

import PassKit
import UIKit

class PurchaseViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let availablePaymentSummaryItems = ApplePayManager.shared.availablePaymentSummaryItems
    
    private let paymentSummaryItemCellIdentifier = "PaymentSummaryItemCell"
    
    private lazy var applePayButton: PKPaymentButton = {
        let applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        applePayButton.addTarget(self, action: #selector(showPaymentAuthorizationView), for: .touchUpInside)
        return applePayButton
    }()
    
    private var selectedPaymentSummaryItems = [PKPaymentSummaryItem]()
    
    private var grandTotalPaymentSummaryItem: PKPaymentSummaryItem {
        return PKPaymentSummaryItem(label: "Thomas Sillmann", amount: totalAmount)
    }
    
    private var requestedPaymentSummaryItems: [PKPaymentSummaryItem] {
        var requestedPaymentSummaryItems = selectedPaymentSummaryItems
        requestedPaymentSummaryItems.append(grandTotalPaymentSummaryItem)
        return requestedPaymentSummaryItems
    }
    
    private var totalAmount: NSDecimalNumber {
        var totalAmount: NSDecimalNumber = 0
        for paymentSummaryItem in selectedPaymentSummaryItems {
            totalAmount = totalAmount.adding(paymentSummaryItem.amount)
        }
        return totalAmount
    }
    
    private var paymentRequest: PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.countryCode = "DE"
        paymentRequest.currencyCode = "EUR"
        paymentRequest.paymentSummaryItems = requestedPaymentSummaryItems
        paymentRequest.supportedNetworks = PKPaymentRequest.availableNetworks()
        paymentRequest.merchantCapabilities = .capabilityCredit
        paymentRequest.merchantIdentifier = ApplePayManager.shared.merchantIdentifier
        return paymentRequest
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addApplePayButtonToToolbar()
    }
    
    private func addApplePayButtonToToolbar() {
        let applePayBarButtonItem = UIBarButtonItem(customView: applePayButton)
        toolbarItems = [applePayBarButtonItem]
    }
    
    @objc private func showPaymentAuthorizationView() {
        if let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            present(paymentAuthorizationViewController, animated: true, completion: nil)
        }
    }
    
    private func paymentSummaryItem(atIndexPath indexPath: IndexPath) -> PKPaymentSummaryItem? {
        if availablePaymentSummaryItems.count > indexPath.row {
            return availablePaymentSummaryItems[indexPath.row]
        }
        return nil
    }
    
    private func selectPaymentSummaryItem(atIndexPath indexPath: IndexPath) {
        if let paymentSummaryItem = self.paymentSummaryItem(atIndexPath: indexPath) {
            if selectedPaymentSummaryItems.contains(paymentSummaryItem) {
                var index = 0
                for selectedPaymentSummaryItem in selectedPaymentSummaryItems {
                    if selectedPaymentSummaryItem == paymentSummaryItem {
                        selectedPaymentSummaryItems.remove(at: index)
                        break
                    }
                    index += 1
                }
            } else {
                selectedPaymentSummaryItems.append(paymentSummaryItem)
            }
        }
        updateCheckmarkForPaymentSummaryCell(atIndexPath: indexPath)
    }
    
    private func updateCheckmarkForPaymentSummaryCell(atIndexPath indexPath: IndexPath) {
        if let selectedPaymentSummaryItemCell = tableView.cellForRow(at: indexPath) {
            selectedPaymentSummaryItemCell.accessoryType = accessoryType(forPaymentSummaryItemCell: selectedPaymentSummaryItemCell)
        }
    }
    
    private func accessoryType(forPaymentSummaryItemCell paymentSummaryItemCell: UITableViewCell) -> UITableViewCell.AccessoryType {
        if let paymentSummaryItemIndexPath = tableView.indexPath(for: paymentSummaryItemCell), let paymentSummaryItem = self.paymentSummaryItem(atIndexPath: paymentSummaryItemIndexPath) {
            if selectedPaymentSummaryItems.contains(paymentSummaryItem) {
                return .checkmark
            }
        }
        return .none
    }
    
    private func resetSelectedPaymentSummaryItems() {
        selectedPaymentSummaryItems.removeAll()
        tableView.reloadData()
    }
    
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension PurchaseViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        resetSelectedPaymentSummaryItems()
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource

extension PurchaseViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paymentSummaryItemCell = tableView.dequeueReusableCell(withIdentifier: paymentSummaryItemCellIdentifier, for: indexPath)
        if let paymentSummaryItem = self.paymentSummaryItem(atIndexPath: indexPath) {
            paymentSummaryItemCell.textLabel?.text = paymentSummaryItem.label
            paymentSummaryItemCell.detailTextLabel?.text = "\(paymentSummaryItem.formattedAmount)"
            paymentSummaryItemCell.accessoryType = accessoryType(forPaymentSummaryItemCell: paymentSummaryItemCell)
        }
        return paymentSummaryItemCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availablePaymentSummaryItems.count
    }
    
}

// MARK: - UITableViewDelegate

extension PurchaseViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectPaymentSummaryItem(atIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
