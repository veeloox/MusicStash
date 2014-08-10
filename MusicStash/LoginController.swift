//
//  LoginController.swift
//  MusicStash
//
//  Created by Anton Gorskiy on 06.08.14.
//  Copyright (c) 2014 VeelooX. All rights reserved.
//

import UIKit

class LoginController: UITabBarController, VKSdkDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        
        self.title = "Search"

        _ = app.nowPlaying.view

        self.viewControllers.append(app.nowPlaying)
        VKSdk.initializeWithDelegate(self, andAppId: "4494051")
        
        if (VKSdk.wakeUpSession())
        {
            println("Woken up")
        } else {
            println("authing")
            VKSdk.authorize(["audio"])
        }
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        println("new token", newToken)
    }
    
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        println("user denied", authorizationError)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        println("need captcha", captchaError)
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        println("expired token", expiredToken)
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        println("spvc", controller)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent!) {
        
        if (event.type == UIEventType.RemoteControl){
            let app = UIApplication.sharedApplication().delegate as AppDelegate
            
            switch event.subtype {
                
            case UIEventSubtype.RemoteControlPlay:
                println("toggle play/pause")
                app.nowPlaying.playPauseButtonPressed(nil)

            case UIEventSubtype.RemoteControlPause:
                println("toggle play/pause")
                app.nowPlaying.playPauseButtonPressed(nil)
                
            case UIEventSubtype.RemoteControlNextTrack:
                app.nowPlaying.nextButtonPressed(nil)
                
            case UIEventSubtype.RemoteControlPreviousTrack:
                app.nowPlaying.prevButtonPressed(nil)
            
            case UIEventSubtype.RemoteControlBeginSeekingForward:
                app.nowPlaying.startRemoteSeekingForward()
                
            case UIEventSubtype.RemoteControlBeginSeekingBackward:
                app.nowPlaying.startRemoteSeekingBackward()
                
            case UIEventSubtype.RemoteControlEndSeekingForward:
                app.nowPlaying.endRemoteSeeking()
                
            case UIEventSubtype.RemoteControlEndSeekingBackward:
                app.nowPlaying.endRemoteSeeking()
                
            case UIEventSubtype.RemoteControlTogglePlayPause:
                app.nowPlaying.playPauseButtonPressed(nil)
                
            case UIEventSubtype.RemoteControlStop:
                println("stop emitted")
            
            default:
                _ = 1
            }
            
        } else {
            println((event.type.toRaw(), event.subtype.toRaw()))
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
