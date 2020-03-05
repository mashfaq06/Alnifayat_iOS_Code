//
//  ItemDetailVC.swift
//  KAUST Waste Guide
//
//  Created by Mohammed Ashfaq on 06/04/19.
//  Copyright © 2019 Mohammed Ashfaq. All rights reserved.
//

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController {

    @IBOutlet weak var ivItem: UIImageView!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var ivCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewSpecialInstruction: UIView!
    @IBOutlet weak var lblSpecialInstruction: UILabel!
    
    @IBOutlet weak var conBottomViewDescription: NSLayoutConstraint!
    @IBOutlet weak var conBottomViewSpecialInstruction: NSLayoutConstraint!
    @IBOutlet weak var conHeightBtnMap: NSLayoutConstraint!
    
    var dictItem = JSON.null
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fillData()
    }
    
    //MARK: - FillData
    func fillData() {
        lblItem.text = dictItem["name"].stringValue
        
        lblDescription.text = dictItem["description"].stringValue
        
        switch dictItem["category"].intValue {
        case 1:
            lblCategory.text = "Recycling Bin"
            ivCategory.image = UIImage.init(named: "icon_recyclingbin")
        case 2:
            lblCategory.text = "Waste Bin"
            ivCategory.image = UIImage.init(named: "icon_wastebin")
        case 3:
            lblCategory.text = "Special Waste"
            ivCategory.image = UIImage.init(named: "icon_specialwaste")
        case 4:
            lblCategory.text = "Organic Bin"
            ivCategory.image = UIImage.init(named: "icon_organicbin")
        default:
            lblCategory.text = "Not Found"
        }
        
        if dictItem["special_instructions"].stringValue.count == 0{
            viewSpecialInstruction.isHidden = true
            conBottomViewSpecialInstruction.priority = .defaultLow
            conBottomViewDescription.priority = .defaultHigh
        }
        else {
            viewSpecialInstruction.isHidden = false
            conBottomViewSpecialInstruction.priority = .defaultHigh
            conBottomViewDescription.priority = .defaultLow
            
            lblSpecialInstruction.text = dictItem["special_instructions"].stringValue
        }
        
        if let url = dictItem["link_url"].url, UIApplication.shared.canOpenURL(url) {
                conHeightBtnMap.constant = 36
            }
        else {
            conHeightBtnMap.constant = 0
        }
    }
    
    //MARK: - Button
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShowInMap(_ sender: Any) {
        if let url = dictItem["link_url"].url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}
