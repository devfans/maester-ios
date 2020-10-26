//
//  HistoryView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/10/24.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI



struct HistoryView: View {
    @EnvironmentObject var state: MaesterState
    @State private var show_delete_alert = false
    @State private var delete_page_id: String? = nil
    @State private var nav_detail: Int? = 0
    @State private var page_id = ""
    @State private var page = Page(withLink: "")
    // @State private var show_page_detail = false
    
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
        VStack {
            HStack {
                Text("Browse History")
                    .font(.title).foregroundColor(self.state.style.captionColor)
                Spacer()
            }.padding(.leading, 30)
            
            NavigationLink(destination: PageDetailView(page_id: $page_id, page: $page), tag: 1, selection: self.$nav_detail) { Text("") }
            
            List {
                ForEach(self.state.book.history.indices, id: \.self) { index in
                    Group {
                        HStack {
                            Button (action: {
                                let page = self.state.book.history[index]
                                // self.state.read_page = page.1
                                // self.state.read_page_id = page.0
                                // self.state.entry = .PageDetail
                                // self.state.show_recent_page_detail = true
                                self.page = page.1
                                self.page_id = page.0
                                self.nav_detail = 1
                                self.state.check_sync()
                                
                            }) {
                                PageRow(page_id: self.state.book.history[index].0, page: self.state.book.history[index].1)
                            }.buttonStyle(BorderlessButtonStyle())
                            .padding(.vertical, 0).padding(.trailing, -4)
                            // .background(Color.green)
                            /*.sheet(isPresented: self.$state.show_recent_page_detail) {
                             PageDetailView(tab_selection: self.$selection).environmentObject(self.state)
                             }*/
                            Button (action: {
                                let page = self.state.book.history[index].1
                                switch page.page_type {
                                case .Link:
                                    if let url = URL(string: page.content) {
                                        UIApplication.shared.open(url)
                                        // _ = NSWorkspace.shared.open(url)
                                    }
                                case .Note:
                                    print("A note")
                                }
                            }) {
                                PageLauncher(width: 32, height: 50, page_type: self.state.book.history[index].1.page_type)
                            }.buttonStyle(BorderlessButtonStyle())
                            .padding(.vertical, -4)
                        }.padding(.vertical, 0)
                    }.padding(.vertical, 0)
                }
                .onDelete(perform: {index in
                    if let index_value = index.first {
                        let page = self.state.book.history[index_value]
                        self.delete_page_id = page.0
                        self.show_delete_alert = true
                        print("Will remove \(page.1.name)")
                    }
                    
                }).alert(isPresented: $show_delete_alert) {
                    Alert(title: Text("Delete Page"), message: Text("Are you sure to remove this page?"), primaryButton: .destructive(Text("Delete")) {
                        self.delete_page()
                        self.show_delete_alert = false
                    }, secondaryButton: .cancel()
                    )
                }.padding(.vertical, 0).listRowBackground(self.state.style.listBackground)
            }
        }.padding(.top, -20)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        state.style = MaesterState.get_style(.dark)
        state.book.gen_sample()
        // state.sync(force: true)
        for (id, page) in state.book.entity.data {
            state.book.insert_into_history(id: id, page: page)
        }
        return HistoryView()
            .environmentObject(state)
            .environment(\.colorScheme, .dark)
    }
}
