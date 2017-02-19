//
//  TabPopupViewController.swift
//  Saving Pennies
//
//  Created by Rajee Jones on 2/18/17.
//  Copyright © 2017 Rajee Jones. All rights reserved.
//

import UIKit

class TabPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var learnMoreBtn: UIButton!
    @IBOutlet weak var mainHeader: UIView!
    @IBOutlet weak var mainHeaderLabel: UILabel!
    @IBOutlet weak var mainHeaderSubLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    var tempData = ["Mortgate/Rent", "School Loan", "Car Payment", "Credit Card"]
    
    
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
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TabPopupTableViewCell
        
        cell.itemLabel.text = tempData[indexPath.row]
        
        
        return cell
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
