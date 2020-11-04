//
//  PageDetailView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/9.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct LabelText: View {
    @EnvironmentObject var state: MaesterState
    
    var label: LocalizedStringKey
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
            .background(self.state.style.fieldBackgroundColor)
            
        }.padding(.horizontal, 10)
    }
}

struct PageDetailView: View {
    @EnvironmentObject var state: MaesterState
    // @Environment(\.presentationMode) var presentationMode
    @State private var nav_edit: Int? = 0
    @State private var show_delete_alert = false
    @State var nav_result = false
    @Binding var page_id: String
    @Binding var page: Page
    static private let page_types = [PageType.Link, PageType.Note]
    static let link: LocalizedStringKey = "link"
    static let note: LocalizedStringKey = "note"
    static private let page_types_text = [link, note]
    
    private func get_page_type(_ t: PageType) -> LocalizedStringKey {
        if let i = Self.page_types.firstIndex(of: t) {
            return Self.page_types_text[i]
        }
        return ""
    }
    
    private func delete_page () {
        let action = PageAction.Delete(page_id)
        _ = self.state.book.apply_action(action: action)
        self.state.sync()
        print("Deleted page")
        // self.presentationMode.wrappedValue.dismiss()
        //  self.state.show_search_page_detail = false
        // self.state.show_recent_page_detail = false
        // self.state.read_page = Page(withLink: "")
        // self.state.read_page_id = ""
        self.state.search()
    }
    
    func nav_to_edit() -> some View {
        // print("creating page edit view \(page_id)")
        return EditPageView(page_id: page_id, page: page)
    }
    
    var body: some View {
        ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: false) {
            VStack(alignment: .leading) {
                NavigationLink(destination: EditPageView(page_id: page_id, page: page), tag: 1, selection: self.$nav_edit) { Text("") }
                NavigationLink("", destination: SearchResultView(), isActive: $nav_result)
                VStack(alignment: .leading) {
                    Text("category")
                        .font(.headline)
                    HStack {
                        Button(action: {
                            self.state.search_type = SearchType.Category.rawValue
                            // self.state.search_keyword = page.category
                            // self.state.search_selection = 1
                            self.state.search_for(page.category)
                            self.nav_result = true
                        }) {
                            Text(page.category)
                                .foregroundColor(self.state.style.tagForegroundColor)
                                .padding(.horizontal, 8.0)
                                .padding(.vertical, 4.0)
                                .background(self.state.style.tagBackgroundColor)
                        }
                        .cornerRadius(6.0)
                    }
                }.padding(.horizontal, 10)
                .padding(.vertical, 5)
                
                LabelText(label: "name", value: page.name)
                
                VStack(alignment: .leading) {
                    Text("tags")
                        .font(.headline)
                    
                    HStack{
                        ForEach(page.tags, id: \.self) { tag in
                            Button(action: {
                                self.state.search_type = SearchType.Tag.rawValue
                                // self.state.search_keyword = tag
                                // self.state.show_recent_page_detail = false
                                // self.state.show_search_page_detail = false
                                self.state.search_for(tag)
                                self.nav_result = true
                                // self.state.search_selection = 1
                                // self.main_selection = 0
                                // self.state.entry = MainPage.Main
                            }) {
                                Text(tag)
                                    .foregroundColor(self.state.style.tagForegroundColor)
                                    .padding(.horizontal, 8.0)
                                    .padding(.vertical, 4.0)
                                    .background(self.state.style.tagBackgroundColor)
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
                        Text("type")
                            .font(.headline)
                        
                        Spacer()
                    }.padding(.vertical, 10)
                    HStack {
                        Text(self.get_page_type(page.page_type))
                            .foregroundColor(self.state.style.subtitleColor)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                        
                        Spacer()
                        Button(action: {
                            if let url = URL(string: page.content) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("open")
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color.white)
                                .background(MaesterConstants.faceBlue)
                            
                        }.cornerRadius(6)
                    }
                    .padding(.vertical, 1)
                    .background(self.state.style.fieldBackgroundColor)
                    
                }.padding(.horizontal, 10)
                // LabelText(label: "Content", value: self.state.read_page.content)
                VStack(alignment: .leading) {
                    HStack {
                        Text("content")
                            .font(.headline)
                        Spacer()
                    }.padding(.vertical, 10)
                    /*
                     GeometryReader { geo in
                     ScrollView {
                     Text(self.state.read_page.content)
                     .padding(.vertical, 10).frame(width: geo.size.width, alignment: .leading)
                     Spacer()
                     }
                     }*/
                    GeometryReader { geo in
                        ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, content: {
                            Text(page.content)
                        })
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .frame(width: geo.size.width, height: 200, alignment: .leading)
                        .background(self.state.style.fieldBackgroundColor)
                    }
                    
                }.padding(.horizontal, 10).frame(height: 250)
                LabelText(label: "date_created", value: String(page.time))
                
                Spacer()
                VStack {
                    Button(action: {
                        // self.state.write_page = self.state.read_page
                        // self.state.entry = .EditPage
                        // self.presentationMode.wrappedValue.dismiss()
                        /*
                        if let index = [PageType.Link, PageType.Note].firstIndex(of: self.state.write_page.page_type) {
                            self.state.write_page_type = index
                        }
                        */
                        // self.state.show_new_page = true
                        self.nav_edit = 1
                        self.state.check_sync()
                    }) {
                        HStack {
                            Spacer()
                            Text("edit")
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
                    
                    Button(action: {
                        self.show_delete_alert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("delete")
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
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 0).navigationBarTitle("page_detail")
        .alert(isPresented: $show_delete_alert) {
            Alert(title: Text("delete_page"), message: Text("hint_delete"), primaryButton: .destructive(Text("delete")) {
                self.delete_page()
                self.show_delete_alert = false
            }, secondaryButton: .cancel()
            )
        }
    }
}

struct PageDetailView_Previews: PreviewProvider {
    @State static var page_id = ""
    @State static var page = Page(withLink: "")
    
    
    static var previews: some View {
        let state = MaesterState()
        var page = Page(withLink: "http://bing.com")
        page.category = "Search"
        page.tags = ["bing", "search"]
        page.name = "Bing"
        state.read_page = page
        return  PageDetailView(page_id: $page_id, page: $page).environmentObject(state)
    }
}
