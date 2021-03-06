//
//  PreferencesViewController.swift
//  iTeamTalk
//
//  Created by Bjoern Rasmussen on 3-11-15.
//  Copyright © 2015 BearWare.dk. All rights reserved.
//

import UIKit

let PREF_NICKNAME = "nickname_preference"
let PREF_JOINROOTCHANNEL = "joinroot_preference"

let PREF_SUB_USERMSG = "sub_usertextmsg_preference"
let PREF_SUB_CHANMSG = "sub_chantextmsg_preference"
let PREF_SUB_BROADCAST = "sub_broadcastmsg_preference"
let PREF_SUB_VOICE = "sub_voice_preference"
let PREF_SUB_VIDEOCAP = "sub_videocapture_preference"
let PREF_SUB_MEDIAFILE = "sub_mediafile_preference"
let PREF_SUB_DESKTOP = "sub_desktop_preference"
let PREF_SUB_DESKTOPINPUT = "sub_desktopinput_preference"

let PREF_MASTER_VOLUME = "mastervolume_preference"
let PREF_MICROPHONE_GAIN = "microphonegain_preference"

class PreferencesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
   
    var nicknamefield : UITextField?
    
    var ttInst = UnsafeMutablePointer<Void>()
    
    var mastervolcell : UITableViewCell?
    var microphonecell : UITableViewCell?
    
    var general_items = [UITableViewCell]()
    var sound_items  = [UITableViewCell]()
    var subscription_items = [UITableViewCell]()
    
    let SECTION_GENERAL = 0, SECTION_SOUND = 1, SECTION_SUBSCRIPTIONS = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let settings = NSUserDefaults.standardUserDefaults()
        
        
        var nickname = settings.stringForKey(PREF_NICKNAME)
        if nickname == nil {
            nickname = "Noname"
        }
        
        let nicknamecell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        nicknamefield = newTableCellTextField(nicknamecell, label: "Nickname", initial: nickname!)
        nicknamefield?.addTarget(self, action: "nicknameChanged:", forControlEvents: .EditingDidEnd)
        general_items.append(nicknamecell)
        
        // sound preferences
        
        mastervolcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let vol = Int(TT_GetSoundOutputVolume(ttInst))
        let percent = refVolumeToPercent(vol)
        let mastervolstepper = newTableCellStepper(mastervolcell!, label: "Master Volume", min: 0, max: 100, step: 1, initial: Double(percent))
        mastervolstepper.addTarget(self, action: "masterVolumeChanged:", forControlEvents: .ValueChanged)
        masterVolumeChanged(mastervolstepper)
        sound_items.append(mastervolcell!)
        
        microphonecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let inputvol = Int(TT_GetSoundInputGainLevel(ttInst))
        let input_pct = refVolumeToPercent(inputvol)
        let microphoneslider = newTableCellSlider(microphonecell!, label: "Microphone Gain", min: 0, max: 100, initial: Float(input_pct))
        microphoneslider.addTarget(self, action: "microphoneGainChanged:", forControlEvents: .ValueChanged)
        microphoneGainChanged(microphoneslider)
        sound_items.append(microphonecell!)
        
        // subscription items
        
        let subs = getDefaultSubscriptions()

        let subusermsgcell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subusermsgswitch = newTableCellSwitch(subusermsgcell, label: "User Messages", initial: (subs & SUBSCRIBE_USER_MSG.rawValue) != 0)
        subusermsgswitch.tag = Int(SUBSCRIBE_USER_MSG.rawValue)
        subusermsgswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subusermsgcell)
        
        let subchanmsgcell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subchanmsgswitch = newTableCellSwitch(subchanmsgcell, label: "Channel Messages", initial: (subs & SUBSCRIBE_CHANNEL_MSG.rawValue) != 0)
        subchanmsgswitch.tag = Int(SUBSCRIBE_CHANNEL_MSG.rawValue)
        subchanmsgswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subchanmsgcell)
        
        let subbcastmsgcell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subbcastmsgswitch = newTableCellSwitch(subbcastmsgcell, label: "Broadcast Messages", initial: (subs & SUBSCRIBE_BROADCAST_MSG.rawValue) != 0)
        subbcastmsgswitch.tag = Int(SUBSCRIBE_BROADCAST_MSG.rawValue)
        subbcastmsgswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subbcastmsgcell)

        let subvoicecell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subvoiceswitch = newTableCellSwitch(subvoicecell, label: "Voice", initial: (subs & SUBSCRIBE_VOICE.rawValue) != 0)
        subvoiceswitch.tag = Int(SUBSCRIBE_VOICE.rawValue)
        subvoiceswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subvoicecell)
        
        let subwebcamcell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subwebcamswitch = newTableCellSwitch(subwebcamcell, label: "WebCam", initial: (subs & SUBSCRIBE_VIDEOCAPTURE.rawValue) != 0)
        subwebcamswitch.tag = Int(SUBSCRIBE_VIDEOCAPTURE.rawValue)
        subwebcamswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subwebcamcell)
        
        let submediafilecell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let submediafileswitch = newTableCellSwitch(submediafilecell, label: "Media File", initial: (subs & SUBSCRIBE_MEDIAFILE.rawValue) != 0)
        submediafileswitch.tag = Int(SUBSCRIBE_MEDIAFILE.rawValue)
        submediafileswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(submediafilecell)
        
        let subdesktopcell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let subdesktopswitch = newTableCellSwitch(subdesktopcell, label: "Desktop", initial: (subs & SUBSCRIBE_DESKTOP.rawValue) != 0)
        subdesktopswitch.tag = Int(SUBSCRIBE_DESKTOP.rawValue)
        subdesktopswitch.addTarget(self, action: "subscriptionChanged:", forControlEvents: .ValueChanged)
        subscription_items.append(subdesktopcell)
        
    }
    
    func subscriptionChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        switch UInt32(sender.tag) {
        case SUBSCRIBE_USER_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_USERMSG)
        case SUBSCRIBE_CHANNEL_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_CHANMSG)
        case SUBSCRIBE_BROADCAST_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_BROADCAST)
        case SUBSCRIBE_VOICE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_VOICE)
        case SUBSCRIBE_VIDEOCAPTURE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_VIDEOCAP)
        case SUBSCRIBE_MEDIAFILE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_MEDIAFILE)
        case SUBSCRIBE_DESKTOP.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_DESKTOP)
        default :
            break
        }
    }
    
    func nicknameChanged(sender: UITextField) {
        TT_DoChangeNickname(ttInst, sender.text!)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(sender.text!, forKey: PREF_NICKNAME)
    }
    
    func masterVolumeChanged(sender: UIStepper) {
        let vol = refVolume(sender.value)
        TT_SetSoundOutputVolume(ttInst, INT32(vol))
        
        if UInt32(vol) == SOUND_VOLUME_DEFAULT.rawValue {
            mastervolcell!.detailTextLabel!.text = "\(sender.value) % - Default"
        }
        else {
            mastervolcell!.detailTextLabel!.text = "\(sender.value) %"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(Int(sender.value), forKey: PREF_MASTER_VOLUME)
    }
    
    func microphoneGainChanged(sender: UISlider) {
        let vol_pct = round(sender.value)
        let vol = refVolume(Double(vol_pct))
        TT_SetSoundInputGainLevel(ttInst, INT32(vol))
        
        if UInt32(vol) == SOUND_VOLUME_DEFAULT.rawValue {
            microphonecell!.detailTextLabel!.text = "\(vol_pct) % - Default"
        }
        else {
            microphonecell!.detailTextLabel!.text = "\(vol_pct) %"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(Int(vol_pct), forKey: PREF_MICROPHONE_GAIN)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_GENERAL :
            return "General"
        case SECTION_SOUND :
            return "Sound"
        case SECTION_SUBSCRIPTIONS :
            return "Default Subscriptions"
        default :
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_GENERAL :
            return general_items.count
        case SECTION_SOUND :
            return sound_items.count
        case SECTION_SUBSCRIPTIONS :
            return subscription_items.count
        default :
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SECTION_GENERAL :
            return general_items[indexPath.row]
        case SECTION_SOUND :
            return sound_items[indexPath.row]
        case SECTION_SUBSCRIPTIONS :
            return subscription_items[indexPath.row]
        default :
            return UITableViewCell()
        }
    }
}
