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
    @State var info = "Please input your AccountName(length >= 4) and Password(length >= 8)."
    
    func valid_input() -> Bool {
        self.user.count >= 4 && self.pass.count >= 4
    }
 
    
    func login() {
        self.state.login(self.user, self.pass) { res in
            if let status = res {
                switch status {
                case .In:
                    self.info = "Login is successful!"
                case .Out:
                    self.info = "Please check your network connection, and try again later!"
                case .Login:
                    self.info = "Invalid credential, please check your input!"
                default:
                    print("login res: \(status)")
                }
            } else {
                self.info = "Server is unavailable for now."
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text("Maester").font(.system(size: 40)).italic()
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
            VStack(alignment: .leading) {
                Text("Account Name")
                    .font(.headline).foregroundColor(.gray)
                TextField("Username/Email Address", text: $user)
                    .padding(.all)
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading) {
                Text("Password")
                    .font(.headline).foregroundColor(.gray)
                SecureField("Password", text: $pass)
                    .padding(.all)
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    .lineLimit(1)
            }
            
            Button(action: {
                self.info = "Login in progress now, please wait..."
                self.login()
            }) {
               HStack {
                    Spacer()
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10.0)
                    Spacer()
                }
               .background(Color.blue)
                .cornerRadius(2)
                .padding(.vertical, 10.0)
                .padding(.horizontal, 0)
            }
                .padding(.vertical, 10.0)
                .disabled(!valid_input())
       
            HStack(alignment: .center) { Text(self.info).foregroundColor(.gray).italic().font(.caption).lineLimit(10)
            }
            Spacer()
        }.padding(.horizontal, 25)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        return LoginView().environmentObject(state)
    }
}
