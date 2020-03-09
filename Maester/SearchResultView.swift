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
    
    private let search_types = ["keyword", "category", "tag", "name", "content"]
    
    var body: some View {
        let pi = Binding<Int>(get: { () -> Int in
            return self.state.search_type
        }) { (new_index) in
            self.state.search_type = new_index
            self.state.search()
        }
        return VStack {
            /*
            HStack {
                Spacer()
                HStack{
                    Text("Found \(self.state.search_ressults.count) items for ")
                    Text(self.state.search_keyword).foregroundColor(Color.blue)
                }
            }.padding(.horizontal, 20)
            */
            
            List {
                ForEach(self.state.search_ressults, id: \.self) { page_id in
                    Group {
                        if self.state.book.has_page(id: page_id) {
                            HStack {
                                Button (action: {
                                    if let page = self.state.book.entity.data[page_id] {
                                        self.state.book.insert_into_history(id: page.gen_id(), page: page)
                                        self.state.read_page = page
                                        self.state.read_page_id = page_id
                                        // self.state.entry = .PageDetail
                                        self.state.show_page_detail = true
                                    }
                                }) {
                                    PageRow(page_id: page_id, page: self.state.book.get_page(id: page_id), read_page_id: self.$state.read_page_id)
                                }.buttonStyle(BorderlessButtonStyle())
                                .padding(.vertical, 0).padding(.trailing, -4)
                                    .sheet(isPresented: self.$state.show_page_detail) {
                                        PageDetailView().environmentObject(self.state)
                                }
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
                }
            }
            Spacer()
            Picker(selection: pi, label: Text("")) {
                ForEach(self.search_types.indices) {
                    Text(self.search_types[$0]).padding(.vertical, 5.0)
                }
            }.pickerStyle(SegmentedPickerStyle()).foregroundColor(Color.blue)
        }//.padding(.top, -60)
            .navigationBarTitle("\(self.state.search_keyword) - Found \(self.state.search_ressults.count) items", displayMode: .inline)
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView().environmentObject(MaesterState())
    }
}
