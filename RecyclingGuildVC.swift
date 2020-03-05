//
//  RecyclingGuildVC.swift
//  KAUST Waste Guide
//
//  Created by Mohammed Ashfaq on 06/04/19.
//  Copyright © 2019 Mohammed Ashfaq. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD
import SVPullToRefresh
import SDWebImage

class RecyclingGuildVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cvPopularItems: UICollectionView!
    @IBOutlet weak var viewAutoComplete: UIView!
    @IBOutlet weak var tblAutoComplete: UITableView!
    @IBOutlet weak var conViewAutoCompeletHeight: NSLayoutConstraint!
    
    var arrPopularItems = JSON.null
    var arrAutoComplete = JSON.null
    var dictSelectedItem = JSON.null
    
    var request : DataRequest? = nil
    
    var isGuestUser = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.addGradientNavigationBar(colors: [GredientLightColor, ThemeColor], angle: 135)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        var arrItems = self.navigationItem.leftBarButtonItems
        if !isGuestUser{
            arrItems?.remove(at: 0)
            self.navigationItem.leftBarButtonItems = arrItems
        }
        
        self.getPopularItems()
    }
    
    //MARK: - Get Data
    func getPopularItems() {
//        SVProgressHUD.show()
        
        let dictRequest = ["user_id" : appDelegate.dictUserInfo["user_id"].stringValue,
                           "user_token" : appDelegate.dictUserInfo["user_token"].stringValue]
        
        Alamofire.request(APIPopularItemsList, method: .post, parameters: dictRequest).responseJSON { response in
            switch response.result{
            case .success(let value):
                //print("Success: \(response)")
                let jsonResponse = JSON(value)
                
                if(jsonResponse["status_code"].intValue == 1){
                    SVProgressHUD.dismiss()
                    self.arrPopularItems = jsonResponse["info"]
                    self.cvPopularItems.reloadData()
                }
                else{
                    SVProgressHUD.showError(withStatus: jsonResponse["msg"].stringValue)
                }
                
            case .failure(let error):
                print("Failed: \(error)")
                SVProgressHUD.showError(withStatus: "Internet connection problem.")
            }
        }
    }
    
    func getData() {
        let dictRequest = ["user_id" : appDelegate.dictUserInfo["user_id"].stringValue,
                           "user_token" : appDelegate.dictUserInfo["user_token"].stringValue,
                           "search_string" : txtSearch.text!]
        
        request?.cancel()
        request = Alamofire.request(APISearchItemsList, method: .post, parameters: dictRequest).responseJSON { response in
            switch response.result{
            case .success(let value):
                //print("Success: \(response)")
                let jsonResponse = JSON(value)
                
                if(jsonResponse["status_code"].intValue == 1){
                    SVProgressHUD.dismiss()
                    self.arrAutoComplete = jsonResponse["info"]
                    
                    self.tblAutoComplete.reloadData()
                }
                else{
                    SVProgressHUD.showError(withStatus: jsonResponse["msg"].stringValue)
                }
                
            case .failure(let error):
                print("Failed: \(error)")
            }
        }
    }
    
    //MARK: - Buttons
    @IBAction func btnClose(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TextField
    @IBAction func txtSearchEditingChanged(_ sender: Any) {
        if txtSearch.text != "" {
            self.getData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        self.getData()
        
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            conViewAutoCompeletHeight.constant = self.view.frame.size.height - keyboardHeight - 56 - 12 + 49    //(56 Textfield, 12 Space on Bottom, 49 Tababar)
        }
        
        viewAutoComplete.isHidden = false
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        viewAutoComplete.isHidden = true
    }
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.size.width - 32) / 3
        let h = w + 28
        return CGSize.init(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPopularItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCollectionViewCell", for: indexPath) as! PopularCollectionViewCell
        
        var dictProduct = arrPopularItems[indexPath.item]
        
        cell.lblItem.text = dictProduct["name"].stringValue
        cell.ivItem.sd_setImage(with: URL.init(string: dictProduct["image"].stringValue), placeholderImage: UIImage.init(named: "small_placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dictSelectedItem = arrPopularItems[indexPath.item]
        self.performSegue(withIdentifier: "Item Detail", sender: self)
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAutoComplete.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteTableViewCell", for: indexPath)
        
        var dictProduct = arrAutoComplete[indexPath.item]
        
        let lbl = cell.viewWithTag(31) as! UILabel
        lbl.text = dictProduct["name"].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dictSelectedItem = arrAutoComplete[indexPath.row]
        txtSearch.resignFirstResponder()
        
        self.performSegue(withIdentifier: "Item Detail", sender: self)
        
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Item Detail" {
            let detailVC = segue.destination as! ItemDetailVC
            detailVC.dictItem = dictSelectedItem
        }
    }
}

//MARK: - PopularCollectionViewCell
class PopularCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var ivItem: UIImageView!
    @IBOutlet weak var lblItem: UILabel!
}
