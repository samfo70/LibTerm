//
//  AppDelegate.swift
//  LibTerm
//
//  Created by Adrian Labbe on 9/29/18.
//  Copyright © 2018 Adrian Labbe. All rights reserved.
//

import UIKit
import TabView
import ios_system
import ObjectUserDefaults
import StoreKit

@available(iOS 13.0, *)
private class DefaultTheme: TabViewTheme {
    
    var backgroundColor: UIColor {
        return .systemFill
    }
    
    var barTitleColor: UIColor {
        return .label
    }
    
    var barTintColor: UIColor {
        return .systemFill
    }
    
    var barBlurStyle: UIBlurEffect.Style {
        return .systemChromeMaterial
    }
    
    var separatorColor: UIColor {
        return .clear
    }
    
    var tabCloseButtonColor: UIColor {
        return TabViewThemeLight().tabCloseButtonColor
    }
    
    var tabCloseButtonBackgroundColor: UIColor {
        return TabViewThemeLight().tabCloseButtonBackgroundColor
    }
    
    var tabBackgroundDeselectedColor: UIColor {
        return TabViewThemeLight().tabBackgroundDeselectedColor
    }
    
    var tabTextColor: UIColor {
        return .label
    }
    
    var tabSelectedTextColor: UIColor {
        return .label
    }
    
    var statusBarStyle: UIStatusBarStyle {
        return .default
    }
}

/// The app's delegate.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window?.rootViewController = TerminalTabViewController(theme: DefaultTheme())
        } else {
            window?.rootViewController = TerminalTabViewController(theme: TabViewThemeLight())
        }
        window?.makeKeyAndVisible()
        
        initializeEnvironment()
                
        replaceCommand("pbcopy", "pbcopy_main", true)
        replaceCommand("pbpaste", "pbpaste_main", true)
        replaceCommand("python", "python3_main", true)
        replaceCommand("python3", "python3_main", true)
        replaceCommand("id", "id_main", true)
        
        // Python
        putenv("PYTHONOPTIMIZE=".cValue)
        putenv("PYTHONDONTWRITEBYTECODE=1".cValue)
        
        // cacert.pem
        let cacertNewURL = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("cacert.pem")
        if let cacertURL = Bundle.main.url(forResource: "cacert", withExtension: "pem"), !FileManager.default.fileExists(atPath: cacertNewURL.path) {
            try? FileManager.default.copyItem(at: cacertURL, to: cacertNewURL)
        }
        
        // The directory where scripts goes
        if let scriptsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).first?.appendingPathComponent("scripts"), !FileManager.default.fileExists(atPath: scriptsDirectory.path) {
            try? FileManager.default.createDirectory(at: scriptsDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        // Colors
        putenv("TERM=ansi".cValue)
        
        window?.accessibilityIgnoresInvertColors = true
        
        if SettingsTableViewController.fontSize.integerValue == 0 {
            SettingsTableViewController.fontSize.integerValue = 14
        }
        
        // Request app review
        ReviewHelper.shared.launches += 1
        ReviewHelper.shared.requestReview()
        
        return true
    }

}

