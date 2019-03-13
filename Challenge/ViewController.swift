//
//  ViewController.swift
//  Challenge
//
//  Created by Teck Hian Wee on 13/3/19.
//  Copyright © 2019 Teck Hian Wee. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController,UITabBarDelegate,UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var navigationbar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var getCareButton: UITabBarItem!
    @IBOutlet weak var visitsButton: UITabBarItem!
    @IBOutlet weak var recipientButton: UITabBarItem!
    @IBOutlet weak var settingsButton: UITabBarItem!
    
    //Trigger the loading of assigned care giver
    var load = false
    let notificationCenter = UNUserNotificationCenter.current()

    //MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTabbar()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
        }
    }

    //MARK: Setup
    func setupNavigationBar(){
        let title = UINavigationItem(title: "Visits")
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(back))
        backButton.tintColor = UIColor.black
        editButton.tintColor = UIColor.blue
        title.rightBarButtonItem = editButton
        title.leftBarButtonItem = backButton
        self.navigationbar.setItems([title], animated: true)
    }
    
    func setupTabbar(){
        self.tabBar.tintColor =  UIColor.blue
        self.getCareButton.image = UIImage(named: "GetCare")
        self.visitsButton.image = UIImage(named: "Visits")
        self.recipientButton.image = UIImage(named: "Recipient")
        self.settingsButton.image = UIImage(named: "Settings")
    }
    
    //MARK: IBActions
    @objc func edit(){
    }
    
    @objc func back(){
    }
    
    //MARK: Tab Bar Delegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch(item){
        case self.getCareButton:
            break
        case self.visitsButton:
            self.load = true
            self.tableView.reloadData()
            sendNotification()
            break
        case self.recipientButton:
            break
        case self.settingsButton:
            break
        default:
            break
        }
    }
    
    //MARK: Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return (load) ? 2:1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1:5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) { return 100}
        else{
            if(indexPath.row == 0){ return 50 }
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CareGiver", for: indexPath) as! CareGiverTableViewCell
            cell.icon.image = UIImage(named: "Recipient")
            cell.favourite.image = UIImage(named: "GetCare")
            let careGiver = (load) ? getAssignedHelper():getTemplateHelper()
            cell.name.text = careGiver.name!
            cell.position.text = careGiver.position
            cell.photo.image = UIImage(named: careGiver.photo!)
            cell.photo.clipsToBounds = true;
            cell.photo.layer.cornerRadius = 25;
            return cell
        } else{
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "Title", for: indexPath) as! TitleCell
                cell.titleLabel.text = "Visit details"
                return cell
            } else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Details", for: indexPath) as! DetailsCell
                let details = getDetailsByIndex(index: indexPath.row)
                cell.icon.image = UIImage(named: details.image!)
                cell.firstLine.text = details.first!
                cell.secondLine.text = details.second!
                cell.thirdLine.text = (details.third != nil) ? details.third! : ""
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
                return cell
            }
        }
    }
    
    //MARK: User Notification Center Manager
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    //MARK: Privates
    func sendNotification(){
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "Notification"
                content.subtitle = "from Homage"
                content.body = "Care Giver has been assigned"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "com.dexter.Challenge", content: content, trigger: trigger)
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    //MARK: Model Simulator
    func getAssignedHelper() ->CareGiverModel{
        var careGiver = CareGiverModel()
        careGiver.photo = "CareGiver"
        careGiver.name = "Viviana Munoz"
        careGiver.position = "Care Pro"
        return careGiver
    }
    
    func getTemplateHelper() ->CareGiverModel {
        var careGiver = CareGiverModel()
        careGiver.photo = "Avatar"
        careGiver.name = "Not Assigned"
        careGiver.position = ""
        return careGiver
    }
    
    func getDetailsByIndex(index: Int) -> DetailsModel{
        switch(index){
        case 1:
            var date = DetailsModel()
            date.image = "Calendar"
            date.first = "Sunday, March 12"
            date.second = "1:00 PM PDT - 2:00 PM PDT"
            date.third = "1 hour"
            return date
        case 2:
            var location = DetailsModel()
            location.image = "Location"
            location.first = "383 King Street"
            location.second = "1411"
            location.third = "San Francisco CA, 94158"
            return location
        case 3:
            var instructions = DetailsModel()
            instructions.image = "Instructions"
            instructions.first = "Instructions"
            instructions.second = "My aunt has early onset dementia and wondering what her daily assitance needs are"
            return instructions
        case 4:
            var billing = DetailsModel()
            billing.image = "Billing"
            billing.first = "Billing estimate"
            billing.second = "Currency : USD"
            billing.third = "Cost : 250"
            return billing
        default:
            return DetailsModel()
        }
    }
    
}

