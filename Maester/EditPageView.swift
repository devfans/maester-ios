//
//  EditPageView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/9.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct EditPageView: View {
    @EnvironmentObject var state: MaesterState
    
    var page_id: String
    var page: Page
    
    var body: some View {
        return NewPageView(page_id: page_id, page: page).navigationBarTitle("edit_page")
    }
}

struct CreatePageView: View {
    var page_id: String
    var page: Page
    var body: some View {
        NewPageView(page_id: page_id, page: page).navigationBarTitle("new_page")
    }
}

