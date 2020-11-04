//
//  LoginView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/3/7.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct LabeledInput: View {
    var label: String
    var placeholder: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField(placeholder, text: $value)
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
        }.padding(.horizontal, 15)
    }
}

struct LoginView: View {
    @EnvironmentObject var state: MaesterState
    @State var user: String = ""
    @State var pass: String = ""
    static let hint_login_input: LocalizedStringKey = "hint_login_input"
    static let hint_login_success: LocalizedStringKey = "hint_login_success"
    static let hint_login_network_error: LocalizedStringKey = "hint_login_network_error"
    static let hint_login_server_error: LocalizedStringKey = "hint_login_server_error"
    static let hint_login_invalid: LocalizedStringKey = "hint_login_invalid"
    static let hint_login_processing: LocalizedStringKey = "hint_login_processing"
    @State var info = hint_login_input
    
    func valid_input() -> Bool {
        self.user.count >= 4 && self.pass.count >= 4
    }
 
    
    func login() {
        self.state.login(self.user, self.pass) { res in
            if let status = res {
                switch status {
                case .In:
                    self.info = LoginView.hint_login_success
                case .Out:
                    self.info = LoginView.hint_login_network_error
                case .Login:
                    self.info = LoginView.hint_login_invalid
                default:
                    print("login res: \(status)")
                }
            } else {
                self.info = LoginView.hint_login_server_error
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text("Maester").font(.system(size: 40)).italic().foregroundColor(self.state.style.tintColor)
                    Spacer()
                }
                Text("slogan").font(.caption).foregroundColor(self.state.style.captionColor).italic()
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
            VStack(alignment: .leading) {
                Text("account")
                    .font(.headline).foregroundColor(self.state.style.captionColor)
                TextField("ph_account", text: $user)
                    .padding(.all)
                    .background(self.state.style.fieldBackgroundColor)
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading) {
                Text("password")
                    .font(.headline).foregroundColor(self.state.style.captionColor)
                SecureField("ph_password", text: $pass)
                    .padding(.all)
                    .background(self.state.style.fieldBackgroundColor)
                    .lineLimit(1)
            }
            
            Button(action: {
                self.info = LoginView.hint_login_processing
                self.login()
            }) {
               HStack {
                    Spacer()
                    Text("login")
                        .font(.headline)
                        .foregroundColor(self.state.style.textForegroundColor)
                        .padding(.vertical, 10.0)
                    Spacer()
                }
               .background(self.state.style.tintColor)
                .cornerRadius(2)
                .padding(.vertical, 10.0)
                .padding(.horizontal, 0)
            }
                .padding(.vertical, 10.0)
                .disabled(!valid_input())
       
            HStack(alignment: .center) { Text(self.info).foregroundColor(self.state.style.captionColor).italic().font(.caption).lineLimit(10)
            }
            Spacer()
        }.padding(.horizontal, 25)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        return LoginView().environmentObject(state).environment(\.locale, .init(identifier: "zh"))
    }
}
