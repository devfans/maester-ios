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
        if let pid = self.delete_page_id {
            print("Deleting page \(pid)")
            let action = PageAction.Delete(pid)
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
                Text("browse_history")
                    .font(.title).foregroundColor(self.state.style.captionColor)
                Spacer()
            }.padding(.leading, 30)
            
            NavigationLink(destination: PageDetailView(page_id: $page_id, page: $page), tag: 1, selection: self.$nav_detail) { Text("") }
            
            List {
                ForEach(self.state.book.history, id: \.self) { i in
                    Group {
                        HStack {
                            Button (action: {
                                // self.state.read_page = page.1
                                // self.state.read_page_id = page.0
                                // self.state.entry = .PageDetail
                                // self.state.show_recent_page_detail = true
                                self.page = i.page
                                self.page_id = i.id
                                self.nav_detail = 1
                                self.state.check_sync()
                                
                            }) {
                                PageRow(page_id: i.id, page: i.page)
                            }.buttonStyle(BorderlessButtonStyle())
                            .padding(.vertical, 0).padding(.trailing, -4)
                            // .background(Color.green)
                            /*.sheet(isPresented: self.$state.show_recent_page_detail) {
                             PageDetailView(tab_selection: self.$selection).environmentObject(self.state)
                             }*/
                            Button (action: {
                                switch i.page.page_type {
                                case .Link:
                                    if let url = URL(string: i.page.content) {
                                        UIApplication.shared.open(url)
                                        // _ = NSWorkspace.shared.open(url)
                                    }
                                case .Note:
                                    print("A note")
                                }
                            }) {
                                PageLauncher(width: 32, height: 50, page_type: i.page.page_type)
                            }.buttonStyle(BorderlessButtonStyle())
                            .padding(.vertical, -4)
                        }.padding(.vertical, 0)
                    }.padding(.vertical, 0)
                }
                .onDelete(perform: {index in
                    if let index_value = index.first {
                        let item = self.state.book.history[index_value]
                        self.delete_page_id = item.id
                        self.show_delete_alert = true
                        print("Will remove \(item.id)")
                    }
                    
                }).alert(isPresented: $show_delete_alert) {
                    Alert(title: Text("delete_page"), message: Text("hint_delete"), primaryButton: .destructive(Text("delete")) {
                        self.delete_page()
                    }, secondaryButton: .cancel()
                    )
                }.padding(.vertical, 0).listRowBackground(self.state.style.listBackground)
            }
        }.padding(.top, -20)
        .onAppear(perform: {})
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
