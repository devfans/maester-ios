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
    var body: some View {
        NewPageView(page_id: self.state.read_page_id)
    }
}

struct EditPageView_Previews: PreviewProvider {
    static var previews: some View {
        EditPageView().environmentObject(MaesterState())
    }
}
