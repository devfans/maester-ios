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
            .background(MaesterConstants.fieldBackground)
                
        }.padding(.horizontal, 10)
    }
}

struct PageDetailView: View {
    @EnvironmentObject var state: MaesterState
    // @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(MaesterConstants.faceBlue)
                Button(action: {
                    self.state.search_type = SearchType.Category.rawValue
                    self.state.search_keyword = self.state.read_page.category
                    // self.state.search()
                    // self.main_selection = 0
                    self.state.entry = MainPage.Main
                }) {
                    Text(self.state.read_page.category)
                        .foregroundColor(MaesterConstants.tagForeground)
                        .padding(.horizontal, 8.0)
                        .padding(.vertical, 2.0)
                        .background(MaesterConstants.tagBackground)
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
                        Button(action: {
                            self.state.search_type = SearchType.Tag.rawValue
                            self.state.search_keyword = tag
                            // self.state.search()
                            // self.main_selection = 0
                            self.state.entry = MainPage.Main
                        }) {
                            Text(tag)
                                .foregroundColor(MaesterConstants.tagForeground)
                                .padding(.horizontal, 8.0)
                                .padding(.vertical, 4.0)
                                .background(MaesterConstants.tagBackground)
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
                        .foregroundColor(MaesterConstants.faceBlue)
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
                            .background(MaesterConstants.faceBlue)

                    }.cornerRadius(6)
                }
                .padding(.vertical, 1)
                .background(MaesterConstants.fieldBackground)
                    
            }.padding(.horizontal, 10)
            // LabelText(label: "Content", value: self.state.read_page.content)
            VStack(alignment: .leading) {
                HStack {
                    Text("Content")
                    .font(.headline)
                    Spacer()
                }.padding(.vertical, 10)
                GeometryReader { geo in
                    ScrollView {
                        Text(self.state.read_page.content)
                            .padding(.vertical, 10).frame(width: geo.size.width, alignment: .leading)
                        Spacer()
                    }
                }
                .padding(.vertical, 1)
                .padding(.horizontal, 3)
                .background(MaesterConstants.fieldBackground)
                    
            }.padding(.horizontal, 10)
            LabelText(label: "Date Created", value: String(self.state.read_page.time))
            
            Spacer()
            VStack {
                Button(action: {
                    self.state.write_page = self.state.read_page
                    // self.state.entry = .EditPage
                    // self.presentationMode.wrappedValue.dismiss()
                    if let index = [PageType.Link, PageType.Note].firstIndex(of: self.state.write_page.page_type) {
                        self.state.write_page_type = index
                    }
                    self.state.show_new_page = true
                    self.state.check_sync()
                 }) {
                    HStack {
                         Spacer()
                         Text("Edit")
                             .font(.headline)
                             .foregroundColor(.white)
                             .padding(.vertical, 10.0)
                         Spacer()
                     }
                    .background(MaesterConstants.faceBlue)
                     .cornerRadius(4)
                     .padding(.vertical, 10.0)
                     .padding(.horizontal, 0)
                 }
                     .padding(.vertical, 3)
                .sheet(isPresented: self.$state.show_new_page) {
                    EditPageView().environmentObject(self.state)
                }
                
                Button(action: {
                    let action = PageAction.Delete(self.state.read_page_id)
                     _ = self.state.book.apply_action(action: action)
                    self.state.sync()
                    print("Deleted page")
                    // self.presentationMode.wrappedValue.dismiss()
                    self.state.show_page_detail = false
                    self.state.read_page = Page(withLink: "")
                    self.state.read_page_id = ""
                    self.state.search()
                }) {
                   HStack {
                        Spacer()
                        Text("Delete")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10.0)
                        Spacer()
                    }
                   .background(Color.red)
                    .cornerRadius(4)
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 0)
                }
                    .padding(.vertical, 5)
                
                Button(action: {
                    // self.presentationMode.wrappedValue.dismiss()
                    self.state.show_page_detail = false
                }) {
                   HStack {
                        Spacer()
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10.0)
                        Spacer()
                    }
                   .background(MaesterConstants.faceBlue)
                    .cornerRadius(4)
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 0)
                }
                    .padding(.vertical, 5)
                
            }
               
        }.padding(.horizontal, 25)
            .padding(.top, 30)
    }
}

struct PageDetailView_Previews: PreviewProvider {
    @State static var main_selection = 0
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
