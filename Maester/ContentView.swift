//
//  ContentView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/3.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    @EnvironmentObject var state: MaesterState
 
    var body: some View {
        Group {
            if self.state.new_page {
                NewPageView().environmentObject(self.state)
            } else {
                TabView(selection: $selection){
                    Text("First View")
                        .font(.title)
                        .tabItem {
                            VStack {
                                Image("first")
                                Text("Recent")
                            }
                        }
                        .tag(0)
                    Text("Second View")
                        .font(.title)
                        .tabItem {
                            VStack {
                                Image("second")
                                Text("Search")
                            }
                        }
                        .tag(1)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
