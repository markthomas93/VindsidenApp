//
//  RHCNavigationViewController.swift
//  VindsidenApp
//
//  Created by Ragnar Henriksen on 18/09/14.
//  Copyright (c) 2014 RHC. All rights reserved.
//

import UIKit


@objc(RHCNavigationViewController)
class RHCNavigationViewController : UINavigationController
{
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
