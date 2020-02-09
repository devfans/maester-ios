//
//  NewPageView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/8.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI
import UIKit

struct LabelTextField: View {
    var label: String
    var placeholder: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField(placeholder, text: $value)
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
        }.padding(.horizontal, 15)
    }
}

struct InputSuggestion: View {
    var size: Int = 2
    @Binding var book: [String: Int]
    @Binding var value: String
    
    var body: some View {
        HStack{
            ForEach(MaesterBook.suggest(index: self.book, value: self.value), id: \.self) { item in
                Button(action: {
                    self.value = item
                }) {
                    Text(item)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .foregroundColor(Color(red: 39.0/255.0, green: 83.0/255.0, blue: 124.0/255.0, opacity: 0.8))
                    .background(Color(red: 199.0/255.0, green: 213.0/255.0, blue: 244.0/255.0, opacity: 0.3))
                    
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


struct NewPageView: View {
    @EnvironmentObject var state: MaesterState
    @State var new_tag = ""
    var page_id: String
    // private var back: MainPage
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                LabelTextField(label: "Name", placeholder: "New Page", value: $state.write_page.name)
                LabelTextField(label: "Category", placeholder: "Page Category (Required)", value: $state.write_page.category)
                InputSuggestion(book: $state.book.categories, value: $state.write_page.category)
                /*
                LabelTextField(label: "Tags", placeholder: "Page Tags", value: $new_tag)
                */
                LabelTextField(label: "Content", placeholder: "Page Content (Required)", value: $state.write_page.content)
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    HStack{
                        ForEach(state.write_page.tags, id: \.self) { tag in
                            Button(action: {
                                while let index = self.state.write_page.tags.firstIndex(of: tag) {
                                    self.state.write_page.tags.remove(at: index)
                                }
                            }) {
                                HStack {
                                    Text(tag)
                                    Image(systemName: "xmark.circle")
                                }
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
                    HStack {
                        TextField("Add a new tag", text: $new_tag)
                            .padding(.all)
                            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                        Button(action: {
                            if self.new_tag.count > 0 && !self.state.write_page.tags.contains(self.new_tag) {
                                self.state.write_page.tags.append(self.new_tag)
                            }
                            self.new_tag = ""

                        }) {
                            Text("Add")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(Color(red: 89.0/255.0, green: 143.0/255.0, blue: 244.0/255.0, opacity: 1.0))

                        }
                        .cornerRadius(2)
                        .foregroundColor(.white)
                        .padding(10)
                    }
                }.padding(.horizontal, 15)
                InputSuggestion(book: $state.book.tags, value: $new_tag)
                Spacer()
                Button(action: {
                    let action = PageAction.Put(self.page_id, self.state.write_page)
                    _ = self.state.book.apply_action(action: action)
                    self.state.book.update()
                    NSLog("Added new page")
                    self.state.entry = .Main
                    self.state.new_page_data = [:]
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10.0)
                        Spacer()
                    }
                    .background(self.state.write_page.is_valid() ? Color.red : Color.gray)
                    .cornerRadius(2)
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 0)
                }
                .padding(.vertical, 10.0)
                .padding(.horizontal, 15.0)
                .disabled(!self.state.write_page.is_valid())
                Spacer()
            }
            .padding(.top, 10)
        }.padding(.top, 0)
    }
}

struct NewPageView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        state.entry = .AddPage
        state.write_page.content = "https://bing.com"
        state.write_page.tags = ["adfasfasdfefasdfaewfasdfefasdf", "efjaslkdjfkjekfkahsdkjfhkjahjfef", "efaskdhtoeifhoiasdf"]
        return NewPageView(page_id: "")
            .environmentObject(state)
    }
}
