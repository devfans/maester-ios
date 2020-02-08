//
//  NewPageView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/8.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct NewPageView: View {
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        NavigationView {
            HStack {
                Text("Hello World")
                Button(action: {
                    self.state.new_page = false
                    self.state.new_page_data = [:]
                })
                {
                    Text("Cancel")
                }
                Button(action: {
                    let page = Page(withLink: self.state.new_page_data["url"]!)
                    let action = PageAction.Put("", page)
                    self.state.state.apply_action(action: action)
                    self.state.state.update()
                    NSLog("Added new page")
                    self.state.new_page = false
                    self.state.new_page_data = [:]
                })
                {
                    Text("Add")
                }
            }
        }
        .navigationBarTitle("New Page", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            }) {
                Text("Cancel")
        })
        .navigationBarItems(trailing: Button(action: {
        }) {
                Text("Add")
        })
        .navigationBarHidden(false)
    }
}

struct NewPageView_Previews: PreviewProvider {
    static var previews: some View {
        NewPageView()
    }
}
