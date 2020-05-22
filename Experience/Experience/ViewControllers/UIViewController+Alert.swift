//
//  UIViewController.swift
//  Experience
//
//  Created by Nicolas Rios on 5/21/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentInformationalAlertController(title: String?, message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: dismissActionCompletion)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: completion)
    }
}
