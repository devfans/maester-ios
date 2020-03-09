//
//  AccountView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/3/7.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        VStack(alignment: .leading) {
             VStack(alignment: .center) {
                VStack(alignment: .center) {
                    Image("logo").resizable()
                        .aspectRatio(1, contentMode: .fit).frame(width: 200, height: 200).padding(.top, 20).padding(.trailing, 2)
                    Spacer()
                }
                 HStack {
                     Spacer()
                    Text("Maester").font(.system(size: 40)).italic().foregroundColor(MaesterConstants.faceBlue)
                     Spacer()
                 }
                 Text("Manage Your Pages Easily").font(.caption).foregroundColor(.gray).italic()
             }.padding(.top, 100)
                 .padding(.bottom, 10)
             
                 /*
                 VStack(alignment: .center) {
                     Image("logo").resizable()
                         .aspectRatio(1, contentMode: .fit).frame(width: 100, height: 100).padding(.top, 20).padding(.trailing, 2)
                     Spacer()
                 }
                 Divider().padding(.bottom, 50)
                 */
             
             Button(action: {
                self.state.sync(force: true)
             }) {
                HStack {
                     Spacer()
                     Text("Synchronize")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding(.vertical, 10.0)
                     Spacer()
                 }
                .background(Color.black)
                 .cornerRadius(2)
                 .padding(.vertical, 10.0)
                 .padding(.horizontal, 0)
             }
                 .padding(.vertical, 6.0)
            
            Button(action: {
               self.state.logout()
            }) {
               HStack {
                    Spacer()
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10.0)
                    Spacer()
                }
               .background(Color.red)
                .cornerRadius(2)
                .padding(.vertical, 10.0)
                .padding(.horizontal, 0)
            }
                .padding(.vertical, 10.0)
            
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "person.circle")
                Text(self.state.user).foregroundColor(.black).font(.subheadline).italic()
                Spacer()
            }
        
         }.padding(.horizontal, 25)
            .padding(.bottom, 25)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject(MaesterState())
    }
}
