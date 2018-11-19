//
//  AccountHistoryApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Encapsulates logic, associated with blockchain account history API
 
    - Note: [Graphene blockchain account history API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1history__api.html)
*/
protocol AccountHistoryApiService: BaseApiService {
    
/**
    Get operations relevant to the specified account
     
     - Parameter id: The account whose history should be queried
     - Parameter startId: ID of the most recent operation to retrieve
     - Parameter stopId: ID of the earliest operation to retrieve
     - Parameter limit: Maximum number of operations to retrieve (must not exceed 100)
     - Parameter completion: Callback which returns history for account or error
 */
    func getAccountHistory(id: String,
                           startId: String,
                           stopId: String,
                           limit: Int,
                           completion: @escaping Completion<[HistoryItem]>)
}
