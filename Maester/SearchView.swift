//
//  SearchView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/10.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI


struct SearchSuggestion: View {
    var size: Int = 2
    @Binding var book: [String: Int]
    @Binding var value: String
    @Binding var search_type: Int
    
    @EnvironmentObject var state: MaesterState
    
    var searching_type: Int
    
    var body: some View {
        
        HStack{
            ForEach(MaesterBook.suggest(index: self.book, value: self.value), id: \.self) { item in
                Button(action: {
                    self.value = item
                    self.search_type = self.searching_type
                }) {
                    Text(item)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .foregroundColor(self.state.style.tagForegroundColor)
                        .background(self.state.style.tagBackgroundColor)
                        .cornerRadius(10)
                }
                .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}


struct SearchView: View {
    @EnvironmentObject var state: MaesterState
    @State var search_keyword: String
    @State var nav_result :Int?
    
    func get_search_results() -> some View {
        SearchResultView()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Maester")
                        .font(.system(size: 30))
                        .italic()
                        .foregroundColor(self.state.style.launcher)
                    Spacer()
                }
                NavigationLink(destination: LazyView(get_search_results), tag: 1, selection: self.$nav_result) { Text("") }
                // NavigationLink("", destination: SearchResultView(), isActive: $nav_result)
                
                HStack {
                    TextField("ph_search", text: $search_keyword)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 16).background(self.state.style.fieldBackgroundColor)
                    
                    Button(action: {
                        // print("Searching \(self.search_keyword) now")
                        self.state.search_for(self.search_keyword)
                        // self.state.search_keyword = self.search_keyword
                        // self.state.search()
                        // self.state.search_selection = 1
                        self.nav_result = 1
                    }) {
                        Text("search")
                            .padding(.vertical, 17)
                            .padding(.horizontal, 12)
                    }.disabled(self.search_keyword.count < 1)
                    .background(MaesterConstants.faceBlue)
                    .padding(.leading, -10)
                    .foregroundColor(Color.white)
                }//.background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            }.padding(.bottom, 10)
            VStack {
                HStack {
                    Text("tags")
                        .foregroundColor(self.state.style.subtitleColor)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 12)
                
                HStack {
                    SearchSuggestion(book: $state.book.tags, value: $search_keyword, search_type: $state.search_type, searching_type: SearchType.Tag.rawValue)
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("categories")
                        .foregroundColor(self.state.style.subtitleColor)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 12)
                
                HStack {
                    SearchSuggestion(book: $state.book.categories, value: $search_keyword, search_type: $state.search_type, searching_type: SearchType.Category.rawValue)
                    Spacer()
                }
            }
            
            Spacer()
        }.padding(.horizontal, 15)
        .padding(.top, 20)
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(search_keyword: "").environment(\.colorScheme, .dark).environmentObject(MaesterState())
    }
}
