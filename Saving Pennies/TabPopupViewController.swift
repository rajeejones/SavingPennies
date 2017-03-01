//
//  TabPopupViewController.swift
//  Saving Pennies
//
//  Created by Rajee Jones on 2/18/17.
//  Copyright © 2017 Rajee Jones. All rights reserved.
//

import UIKit

protocol TabPopupCloseDelegate: class {
    func closeButtonPressed(completionHandler: CompletionHandler)
}

protocol BillPaymentDelegate: class {
    func payBill(forAmount: Int)
    func advanceLevel()
}

class TabPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PayButtonDelegate {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var learnMoreBtn: UIButton!
    @IBOutlet weak var mainHeader: UIView!
    @IBOutlet weak var mainHeaderLabel: UILabel!
    @IBOutlet weak var mainHeaderSubLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!

    
    weak var tabPopupCloseDelegate:TabPopupCloseDelegate?
    weak var billPaymentDelegate:BillPaymentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTableView.register(UINib(nibName: "TabPopupTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return level.expenses.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TabPopupTableViewCell
        
        cell.itemLabel.text = "\(level.expenses[indexPath.row].description) - \(formatter.string(from: NSNumber(value: level.expenses[indexPath.row].amount))!)"
        cell.payButtonDelegate = self
        cell.paymentAmount = level.expenses[indexPath.row].amount
        
        return cell
    }

    
    @IBAction func closeButtonPressed(_ sender: Any) {
        tabPopupCloseDelegate?.closeButtonPressed(completionHandler: nil)
    }
    
    func payButtonPressed(amount: Int) {
        billPaymentDelegate?.payBill(forAmount: amount)
    }
    
    func itemPaid() {
        var advanceLevel = false
        let sections = mainTableView.numberOfSections
        for section in 0..<sections {
            let rowCount = mainTableView.numberOfRows(inSection: section)
            
            for row in 0..<rowCount {
                let cell = mainTableView.cellForRow(at: IndexPath(row: row, section: section)) as! TabPopupTableViewCell
                if cell.paid {
                    advanceLevel = true
                } else {
                    advanceLevel = false
                    break
                }
                
            }
        }
        
        if advanceLevel {
            //todo: Reset expenses
            for section in 0..<sections {
                let rowCount = mainTableView.numberOfRows(inSection: section)
                
                for row in 0..<rowCount {
                    let cell = mainTableView.cellForRow(at: IndexPath(row: row, section: section)) as! TabPopupTableViewCell
                    cell.paidCheckmarkImage.isHidden = true
                    cell.payBtn.isHidden = false
                }
            }
            billPaymentDelegate?.advanceLevel()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
