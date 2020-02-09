//
//  ContentView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/3.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct PageRow: View {
    var page: Page

    var body: some View {
        HStack {
            Text(page.content)
            Spacer()
        }
    }
}

struct PageRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PageRow(page: Page(withLink: "http://link1.com"))
            PageRow(page: Page(withLink: "http://link2.com"))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

struct ContentView: View {
    @State private var selection = 0
    @EnvironmentObject var state: MaesterState
    
    func getRow(page_id: String) -> AnyView {
        if let page = self.state.book.entity.data[page_id] {
            return AnyView(NavigationLink(
                destination: PageDetailView()
            ) {
                PageRow(page: page)
            })
        } else {
            return AnyView(EmptyView())
        }
    }
 
    var body: some View {
        Group {
            if self.state.entry == MainPage.Main {
                TabView(selection: $selection) {
                    NavigationView {
                        List {
                            ForEach(self.state.book.history, id: \.self) { page_id in
                                Group {
                                    if self.state.book.has_page(id: page_id) {
                                        Button (action: {
                                            if let page = self.state.book.entity.data[page_id] {
                                                self.state.read_page = page
                                                self.state.read_page_id = page_id
                                                self.state.entry = MainPage.PageDetail
                                            }
                                        }) {
                                            PageRow(page: self.state.book.get_page(id: page_id))
                                        }
                                    }
                                }
                            }
                        }
                        .navigationBarTitle(Text("Recent"))
                        .navigationBarItems(trailing: Button(action: {
                            self.state.write_page = Page(withLink: "")
                            self.state.new_page_data = [:]
                            self.state.entry = .AddPage
                        }, label: { Text("Add") }))
                        .navigationBarHidden(false)
                    }
                        .tabItem {
                            VStack {
                                Image("first")
                                Text("Recent")
                            }
                        }
                        .tag(0)
                    NavigationView {
                        SearchView()
                        .navigationBarItems(trailing: Button(action: {
                            self.state.write_page = Page(withLink: "")
                            self.state.new_page_data = [:]
                            self.state.entry = .AddPage
                        }, label: { Text("Add") }))
                        .navigationBarHidden(false)
                    }
                        .tabItem {
                            VStack {
                                Image("second")
                                Text("Search")
                            }
                        }
                        .tag(1)
                }
            // } else if case .AddPage = self.state.enry {
            } else if self.state.entry == MainPage.AddPage {
                NavigationView  {
                    NewPageView(page_id: "")
                        .navigationBarHidden(false)
                        .navigationBarTitle(Text("New Page"))
                        .navigationBarItems(leading: Button(action: {
                            self.state.entry = .Main
                            self.state.new_page_data = [:]
                        })
                        {
                            Text("Cancel")
                        })
                }
            } else if self.state.entry == MainPage.EditPage {
                   NavigationView  {
                       EditPageView()
                           .navigationBarHidden(false)
                           .navigationBarTitle(Text("Edit Page"))
                           .navigationBarItems(leading: Button(action: {
                               self.state.entry = .PageDetail
                           })
                           {
                               Text("Cancel")
                           })
                    }
            } else {
                NavigationView {
                    PageDetailView()
                        .navigationBarHidden(false)
                        .navigationBarTitle(Text("Page Detail"))
                        .navigationBarItems(leading: Button(action: {
                            self.state.entry = .Main
                        })
                        {
                            Text("Back")
                        }, trailing: Button(action: {
                            self.state.write_page = self.state.read_page
                            self.state.entry = .EditPage
                        })
                        {
                            Text("Edit")
                        })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        state.book.update(true)
        for id in state.book.entity.data.keys {
            state.book.history.append(id)
        }
        return ContentView()
        .environmentObject(state)
    }
}
