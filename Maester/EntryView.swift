//
//  EntryView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/3/7.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct EntryView: View {
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        Group {
            if self.state.sync_status == .Login {
                LoginView()
            } else {
                ContentView()
            }
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        return EntryView().environmentObject(state)
    }
}
