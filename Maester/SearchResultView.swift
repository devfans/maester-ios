//
//  SearchResultView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/10.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

class SearchResult {
    var results_count = 0
}

struct SearchResultView: View {
    @EnvironmentObject var state: MaesterState
    @State var tab_selection = 0
    @State private var nav_detail: Int? = 0
    
    private let search_types = ["keyword", "category", "tag", "name", "content"]
    @State private var show_delete_alert = false
    @State private var delete_page_id: String? = nil
    @State private var page_id = ""
    @State private var page = Page(withLink: "")
    
    private func delete_page () {
        if let page_id = self.delete_page_id {
            print("Deleting page \(page_id)")
            let action = PageAction.Delete(page_id)
            _ = self.state.book.apply_action(action: action)
            self.state.sync()
            print("Deleted page")
            // self.presentationMode.wrappedValue.dismiss()
            // self.state.show_recent_page_detail = false
            // self.state.show_search_page_detail = false
            // self.state.read_page = Page(withLink: "")
            // self.state.read_page_id = ""
            self.state.search()
        }
    }
    
    var body: some View {
        let pi = Binding<Int>(get: { () -> Int in
            return self.state.search_type
        }) { (new_index) in
            self.state.search_type = new_index
            self.state.search()
        }
        return VStack {
            HStack {
                Text("Searching:")
                    .font(.subheadline).foregroundColor(self.state.style.captionForegroundColor)
                Text(self.state.search_keyword).font(.subheadline).foregroundColor(self.state.style.textColor)
                Spacer()
                Text("Found: \(self.state.search_results.count)").foregroundColor(self.state.style.captionForegroundColor).font(.footnote)
            }.padding(.leading, 10).padding(.trailing, 10)
            
            Picker(selection: pi, label: Text("")) {
                ForEach(self.search_types.indices) {
                    Text(self.search_types[$0]).padding(.vertical, 5.0)
                }
            }.pickerStyle(SegmentedPickerStyle()).foregroundColor(Color.blue)
            
            NavigationLink(destination: PageDetailView(page_id: self.$page_id, page: self.$page), tag: 1, selection: self.$nav_detail) { Text("") }
            
            List {
                ForEach(self.state.search_results, id: \.self) { pid in
                    Group {
                        if self.state.book.has_page(id: pid) {
                            HStack {
                                Button (action: {
                                    if let p = self.state.book.entity.data[pid] {
                                        self.state.book.insert_into_history(id: p.gen_id(), page: p)
                                        // self.state.read_page = page
                                        // self.state.read_page_id = page_id
                                        page_id = pid
                                        page = p
                                        // self.state.entry = .PageDetail
                                        // self.state.show_search_page_detail = true
                                        self.nav_detail = 1
                                    }
                                }) {
                                    PageRow(page_id: pid, page: self.state.book.get_page(id: pid))
                                }.buttonStyle(BorderlessButtonStyle())
                                .padding(.vertical, 0).padding(.trailing, -4)
                                /*
                                 .sheet(isPresented: self.$state.show_search_page_detail) {
                                 PageDetailView(tab_selection: self.$tab_selection).environmentObject(self.state)
                                 
                                 }*/
                                Button (action: {
                                    if let page = self.state.book.entity.data[page_id] {
                                        switch page.page_type {
                                        case .Link:
                                            if let url = URL(string: page.content) {
                                                UIApplication.shared.open(url)
                                                // _ = NSWorkspace.shared.open(url)
                                            }
                                        case .Note:
                                            print("A note")
                                        }
                                    }
                                }) {
                                    PageLauncher(width: 32, height: 50, page_type: self.state.book.get_page(id: page_id).page_type)
                                }.buttonStyle(BorderlessButtonStyle())
                                .padding(.vertical, 0)
                            }.padding(.vertical, -4)
                        }
                    }
                }.onDelete(perform: {index in
                    if let index_value = index.first {
                        self.delete_page_id = self.state.search_results[index_value]
                        self.show_delete_alert = true
                        print("Will remove \(self.delete_page_id ?? "")")
                    }
                    
                }).alert(isPresented: $show_delete_alert) {
                    Alert(title: Text("Delete Page"), message: Text("Are you sure to remove this page?"), primaryButton: .destructive(Text("Delete")) {
                        self.delete_page()
                        self.show_delete_alert = false
                    }, secondaryButton: .cancel()
                    )
                }
            }
            Spacer()
        }.padding(.vertical, 5).navigationBarTitle("Search Results")
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView().environmentObject(MaesterState())
    }
}
