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
                        .foregroundColor(Color(red: 39.0/255.0, green: 83.0/255.0, blue: 124.0/255.0, opacity: 0.8))
                    .background(Color(red: 199.0/255.0, green: 213.0/255.0, blue: 244.0/255.0, opacity: 0.3))
                    .cornerRadius(10)
                }
                .lineLimit(1)
                // .padding(.horizontal, 8)
                // .padding(.vertical, 5)
                // .foregroundColor(.blue)
                // .background(Color.clear)
                // .cornerRadius(10)
                // .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}
/*
struct SearchSuggestion: View {
    var size: Int = 2
    @Binding var book: [String: Int]
    @Binding var value: String
    @Binding var search_type: SearchType
    var searching_type: SearchType
    
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
                        .foregroundColor(Color(red: 39.0/255.0, green: 83.0/255.0, blue: 124.0/255.0, opacity: 0.8))
                    .background(Color(red: 199.0/255.0, green: 213.0/255.0, blue: 244.0/255.0, opacity: 0.3))
                    .cornerRadius(10)
                    
                }
                .lineLimit(1)
                // .padding(.horizontal, 8)
                // .padding(.vertical, 5)
                // .foregroundColor(.blue)
                // .background(Color.clear)
                // .cornerRadius(10)
                // .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}*/

struct SearchView: View {
    @EnvironmentObject var state: MaesterState
    @State var selection: Int? = nil

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                /*
                HStack {
                    Text("Search")
                        .font(.title)
                        .padding(.leading, 20)
                    Spacer()
                }*/
                HStack {
                    TextField("Search Tags, Categories, Keyword", text: $state.search_keyword)
                        .padding(.leading, 10)
                    .padding(.vertical, 16)
                    
                    NavigationLink(destination: SearchResultView(), tag: 1, selection: $selection) {
                        Button(action: {
                            self.state.search()
                            self.selection = 1
                        }) {
                        Text("Search")
                            .padding(.vertical, 16)
                            .padding(.horizontal, 10)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                        }
                    }.disabled(self.state.search_keyword.count < 1)
                }.background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            }.padding(.bottom, 10)
            VStack {
                HStack {
                    Text("Tags")
                        .foregroundColor(Color.blue)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 12)
                
                HStack {
                    SearchSuggestion(book: $state.book.tags, value: $state.search_keyword, search_type: $state.search_type, searching_type: SearchType.Tag.rawValue)
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Categories")
                        .foregroundColor(Color.blue)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 12)
                
                HStack {
                    SearchSuggestion(book: $state.book.categories, value: $state.search_keyword, search_type: $state.search_type, searching_type: SearchType.Category.rawValue)
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
        SearchView().environmentObject(MaesterState())
    }
}
