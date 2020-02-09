//
//  PageDetailView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/9.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct LabelText: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                .font(.headline)
                Spacer()
            }.padding(.vertical, 10)
            HStack {
                Text(value)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                Spacer()
            }
            .padding(.vertical, 1)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                
        }.padding(.horizontal, 10)
    }
}

struct PageDetailView: View {
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                Button(action: {}) {
                    Text(self.state.read_page.category)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 8.0)
                        .padding(.vertical, 2.0)
                        .background(Color.blue)
                }
                .cornerRadius(6.0)
                .padding(.vertical, 1)
                .padding(.horizontal, 1)
                
            }.padding(.horizontal, 10)
            LabelText(label: "Name", value: self.state.read_page.name)
            
            VStack(alignment: .leading) {
                Text("Tags")
                    .font(.headline)
                
                HStack{
                    ForEach(state.read_page.tags, id: \.self) { tag in
                        Button(action: {}) {
                            Text(tag)
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 8.0)
                                .padding(.vertical, 4.0)
                                .background(Color.blue)
                        }.cornerRadius(6.0)
                        // .padding(.horizontal, 8)
                        // .padding(.vertical, 5)
                        // .foregroundColor(.blue)
                        // .background(Color.clear)
                        // .cornerRadius(10)
                        // .lineLimit(1)
                    }
                }.padding(.top, 10)
            }.padding(.horizontal, 10)
                .padding(.vertical, 5)
             
            VStack(alignment: .leading) {
                HStack {
                    Text("Type")
                    .font(.headline)
                    Spacer()
                }.padding(.vertical, 10)
                HStack {
                    Text(self.state.read_page.page_type.rawValue)
                        .foregroundColor(Color.blue)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    Spacer()
                    Button(action: {
                        if let url = URL(string: self.state.read_page.content) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Open")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                        .foregroundColor(Color.white)
                        .background(Color.red)

                    }.cornerRadius(6)
                }
                .padding(.vertical, 1)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    
            }.padding(.horizontal, 10)
            LabelText(label: "Content", value: self.state.read_page.content)
            LabelText(label: "Date Created", value: String(self.state.read_page.time))
            
            
            Spacer()
        }.padding(.horizontal, 8)
            .padding(.top, 40)
    }
}

struct PageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        var page = Page(withLink: "http://bing.com")
        page.category = "Search"
        page.tags = ["bing", "search"]
        page.name = "Bing"
        state.read_page = page
        return  PageDetailView().environmentObject(state)
    }
}
