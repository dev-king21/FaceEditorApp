//
//  DispatchQueue+Extension.swift
//  FaceEditor
//
//  Created by Loyal Lauzier on 11/15/20.
//  Copyright © 2020 Loyal Lauzier. All rights reserved.
//

import Foundation

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    

}
