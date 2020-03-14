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
    
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField(placeholder, text: $value)
                .padding(.all)
                .background(self.state.style.fieldBackgroundColor)
        }
    }
}

struct InputSuggestion: View {
    var size: Int = 2
    @Binding var book: [String: Int]
    @Binding var value: String
    
    @EnvironmentObject var state: MaesterState
    
    var body: some View {
        HStack{
            ForEach(MaesterBook.suggest(index: self.book, value: self.value), id: \.self) { item in
                Button(action: {
                    self.value = item
                }) {
                    Text(item)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .foregroundColor(self.state.style.tagForegroundColor)
                        .background(self.state.style.tagBackgroundColor)
                    
                }
                .lineLimit(1)
                // .padding(.horizontal, 8)
                // .padding(.vertical, 5)
                // .foregroundColor(.blue)
                // .background(Color.clear)
                .cornerRadius(5)
                // .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 12)
    }
}

/*
   HStack {
       Text("Type").font(.headline)
       Spacer()
   }
   
   Picker(selection: $state.write_page_type, label: Text("")) {
       ForEach(self.page_types.indices) {
           Text(self.page_types[$0].rawValue)
       }
   }.pickerStyle(SegmentedPickerStyle()).foregroundColor(MaesterConstants.lightBlue)*/

struct NewPageView: View {
    @EnvironmentObject var state: MaesterState
    // @Environment(\.presentationMode) var presentationMode
    @State var new_tag = ""
    var page_id: String
    
    private let page_types = [PageType.Link, PageType.Note]
    private let page_types_text = ["Link", "Note"]
    
    // private var back: MainPage
    
    var body: some View {
        VStack {
            Group {
                LabelTextField(label: "Name", placeholder: "New Page", value: $state.write_page.name)
                LabelTextField(label: "Category", placeholder: "Page Category (Required)", value: $state.write_page.category)
                InputSuggestion(book: $state.book.categories, value: $state.write_page.category)
                VStack {
                    HStack {
                        Text("Type").font(.headline)
                        Spacer()
                    }
                    
                    Picker(selection: $state.write_page_type, label: Text("")) {
                        ForEach(self.page_types.indices) {
                            Text(self.page_types[$0].rawValue)
                        }
                    }.pickerStyle(SegmentedPickerStyle())//.foregroundColor(MaesterConstants.lightBlue)
                }
            }
            // LabelTextField(label: "Tags", placeholder: "Page Tags", value: $new_tag)
            // LabelTextField(label: "Content", placeholder: "Page Content (Required)", value: $state.write_page.content)

            VStack(alignment: .leading) {
                Text("Content")
                    .font(.headline)
                ScrollView {
                    TextField("Page Content (Required)", text: $state.write_page.content).padding(.top, 0).lineLimit(5)
                    // MultilineTextField("Page Content (Required)", text: $state.write_page.content, onCommit: nil)
                }.lineLimit(5).frame(maxHeight: 100, alignment: .leading)
                    .background(self.state.style.fieldBackgroundColor)
            }
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
                            }.foregroundColor(self.state.style.tagForegroundColor)
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
                        .background(self.state.style.fieldBackgroundColor)
                    Button(action: {
                        if self.new_tag.count > 0 && !self.state.write_page.tags.contains(self.new_tag) {
                            self.state.write_page.tags.append(self.new_tag)
                        }
                        self.new_tag = ""

                    }) {
                        Text("Add")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(MaesterConstants.faceBlue)

                    }
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                }
            }
            InputSuggestion(book: $state.book.tags, value: $new_tag)
            Spacer()
            Button(action: {
                let action = PageAction.Put(self.page_id, self.state.write_page)
                self.state.read_page = self.state.write_page
                self.state.read_page_id = self.state.write_page.gen_id()
                
                _ = self.state.book.apply_action(action: action)
                self.state.sync()
                print("Added new page")
                // self.state.entry = .Main
                self.state.new_page_data = [:]
                // self.presentationMode.wrappedValue.dismiss()
                self.state.show_new_page = false
                self.state.search()
            }) {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10.0)
                    Spacer()
                }
                .background(self.state.write_page.is_valid() ? MaesterConstants.faceBlue : Color.gray)
                .cornerRadius(4)
                .padding(.vertical, 10.0)
                .padding(.horizontal, 0)
            }
            .padding(.vertical, 5)
            .disabled(!self.state.write_page.is_valid())
            Button(action: {
                // self.presentationMode.wrappedValue.dismiss()
                self.state.show_new_page = false
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
            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 25.0)
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
