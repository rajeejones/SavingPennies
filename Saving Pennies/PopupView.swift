//
//  PopupView.swift
//  Saving Pennies
//
//  Created by Rajee Jones on 2/28/17.
//  Copyright © 2017 Rajee Jones. All rights reserved.
//

import UIKit


protocol BillPaymentDelegate: class {
    func payBill(forAmount: Int)
    func advanceLevel()
}

enum PopupViewType {
    case expenses, assets, goals, unknown
}

class PopupView: UIView  {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var mainHeader: UIView!
    @IBOutlet weak var mainHeaderLabel: UILabel!
    @IBOutlet weak var mainHeaderSubLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    var popupType = PopupViewType.unknown {
        didSet {
            configurePopupView()
        }
    }

    weak var billPaymentDelegate:BillPaymentDelegate?
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup() {
        mainTableView.register(UINib(nibName: "ExpenseTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    @IBAction func closePopupButtonPressed(_ sender: AnyObject) {
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }
    
    func configurePopupView() {
        switch popupType {
        case .assets:
            break
        case .expenses:
            mainHeader.backgroundColor = UIColor().brandRed()
            mainHeaderLabel.text = "Expenses"
            mainHeaderSubLabel.text = "select item to purchase"
            
            break
        case .goals:
            break
        case .unknown:
            break
        }
    }
    

}

extension PopupView: UITableViewDataSource, UITableViewDelegate, PayButtonDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(self.popupType) {
        case .expenses:
            return level.expenses.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch(self.popupType) {
        case .expenses:
            cell = setupExpensesTableViewCell(tableView, indexPath: indexPath)
            break
        default:
            break
        }
        
        return cell
        
        
    }
    
    func setupExpensesTableViewCell(_ tableView:UITableView,indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ExpenseTableViewCell
        
        cell.itemLabel.text = level.expenses[indexPath.row].description
        cell.itemLabel.textColor = UIColor().brandRed()
        cell.paid = level.expenses[indexPath.row].paid
        cell.payButtonDelegate = self
        cell.paymentAmount = level.expenses[indexPath.row].amount
        
        if cell.paid {
            cell.payBtn.alpha = 0
            cell.paidCheckmarkImage.alpha = 1
        }
        else if !cell.canBePaid() {
            cell.payBtn.borderColor = UIColor.clear
            cell.payBtn.setTitle(formatter.string(from: NSNumber(value: level.expenses[indexPath.row].amount)), for: UIControlState.normal)
            cell.payBtn.tintColor = UIColor().brandRed()
            cell.payBtn.setTitleColor(UIColor().brandRed(), for: UIControlState.normal)
            
        } else {
            cell.payBtn.borderColor = UIColor().brandGreen()
            cell.payBtn.setTitle("Pay!", for: UIControlState.normal)
            cell.payBtn.tintColor = UIColor().brandGreen()
            cell.payBtn.setTitleColor(UIColor().brandGreen(), for: UIControlState.normal)
        }
        
        return cell
    }
    
    //PayButtonDelegate
    func payButtonPressed(amount: Int, cell: UITableViewCell) {
        // check if paid, then set the variable to paid, and change the image
        
        guard let expenseCell = cell as? ExpenseTableViewCell else {
            return
        }
        
        guard let cellIndex = mainTableView.indexPath(for: expenseCell)?.row else {
            return
        }
        
        if expenseCell.canBePaid() {
            expenseCell.paid = true
            level.expenses[cellIndex].paid = true
            expenseCell.animateItemPaid()
            mainTableView.reloadData()
        }
        
        billPaymentDelegate?.payBill(forAmount: amount)
        
        var advance = false
        for expense in level.expenses {
            if expense.paid {
               advance = true
            } else {
                advance = false
                break
            }
        }
        
        if advance {
            if let superView = self.superview as? PopupContainer {
                (superView ).close()
            }
            billPaymentDelegate?.advanceLevel()
        }
        
    }
    
    
}
