//
//  ExpenseTableViewCell.swift
//  Saving Pennies
//
//  Created by Rajee Jones on 2/18/17.
//  Copyright © 2017 Rajee Jones. All rights reserved.
//

import UIKit

protocol PayButtonDelegate: class {
    func payButtonPressed(amount:Int, cell:UITableViewCell)
}

@IBDesignable
class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var payBtn: PayButton!
    @IBOutlet weak var paidCheckmarkImage: UIImageView!
    
    weak var payButtonDelegate:PayButtonDelegate?
    var paymentAmount:Int!
    var paid = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        paidCheckmarkImage.alpha = 0
        // Initialization code
    }

    @IBAction func payButtonPressed(_ sender: Any) {
        
        payButtonDelegate?.payButtonPressed(amount: self.paymentAmount, cell: self)
        
    }
    
    
    func reset() {
        paid = false
        self.paidCheckmarkImage.alpha = 0
        self.payBtn.alpha = 1
    }
    
    func animateItemPaid() {
        if paid {
            UIView.animate(withDuration: 0.6,
                           delay: 0, usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                            self.paidCheckmarkImage.alpha = 1
                            self.payBtn.alpha = 0
            }, completion: nil)
        }
    }
    
    func canBePaid() -> Bool {
        if gameScore >= self.paymentAmount {
            return true
        }
        return false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //payButtonDelegate?.payButtonPressed(amount: self.paymentAmount)
        // Configure the view for the selected state
    }
    
    
    
}

@IBDesignable class PayButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
    }
}
