//
//  MyCustomerProvider.swift
//  Reven
//
//  Created by reveantivirus on 18/12/25.
//

import Foundation
import ReveChatSDK_CPrime


class MyCustomerProvider: NSObject, CustomerInterfaceProvider {
    
    


    func getCustomerName() -> String! {
        return "AlphaOne"
    }


    func getCustomerID() -> String! {
        return "12345"
    }
    

    func getCustomerType() -> String! {
        return "Admin"
    }
    

    func getCustomerEmail() -> String! {
        return "abc@gmail.com"
    }
    

    func getCustomerPhone() -> String! {
        return "123456789"
    }
    

    func getCustomerAccountID() -> String! {
        return "767676"
    }
    
    func getCustomerAccountNumber() -> String! {
        return "987654321"
    }
    
   
}
