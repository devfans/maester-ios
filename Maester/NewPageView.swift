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
    @State var page: Page
    @State private var page_type = 0
    
    static private let page_types = [PageType.Link, PageType.Note]
    static private let page_types_text = ["Link", "Note"]
    
    // private var back: MainPage
    /*
    init(_ id: String, _ p: Page) {
        print("Setting page \(p.name)")
        page_id = id
        page = p
        page_type = Self.get_page_type_index(pageType: page.page_type)
    }
    */
    
    static func get_page_type_index(pageType: PageType) -> Int {
        if let index = page_types.firstIndex(of: pageType) {
            return  index
        }
        return 0
    }
    
    mutating func set(_ id: String, _ p: Page) {
        self.page_id = id
        self.page = p
    }
    
    var body: some View {
        ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: false) {
            VStack {
                Group {
                    LabelTextField(label: "Name", placeholder: "New Page", value: self.$page.name)
                    LabelTextField(label: "Category", placeholder: "Page Category (Required)", value: self.$page.category)
                    InputSuggestion(book: $state.book.categories, value: self.$page.category)
                    VStack {
                        HStack {
                            Text("Type").font(.headline)
                            Spacer()
                        }
                        
                        Picker(selection: self.$page_type, label: Text("")) {
                            ForEach(Self.page_types.indices) {
                                Text(Self.page_types[$0].rawValue)
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
                        TextField("Page Content (Required)", text: $page.content).padding(.top, 0).lineLimit(5)
                        // MultilineTextField("Page Content (Required)", text: $state.write_page.content, onCommit: nil)
                    }.lineLimit(5).frame(minHeight: 100, alignment: .leading)
                    .background(self.state.style.fieldBackgroundColor)
                }
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    HStack{
                        ForEach(page.tags, id: \.self) { tag in
                            Button(action: {
                                while let index = page.tags.firstIndex(of: tag) {
                                    page.tags.remove(at: index)
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
                            if self.new_tag.count > 0 && !page.tags.contains(self.new_tag) {
                                page.tags.append(self.new_tag)
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
                    let action = PageAction.Put(self.page_id, page)
                    if self.page_type < Self.page_types.count {
                        page.page_type = Self.page_types[self.page_type]
                    }
                    
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
                    .background(page.is_valid() ? MaesterConstants.faceBlue : Color.gray)
                    .cornerRadius(4)
                    .padding(.vertical, 10.0)
                    .padding(.horizontal, 0)
                }
                .padding(.vertical, 5)
                .disabled(!page.is_valid())
                /*
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
                 */
                Spacer()
            }
            
        }
        .padding(.top, 30)
        .padding(.horizontal, 25.0)
    }
}

struct NewPageView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        return NewPageView(page_id: "", page: Page(withLink: ""))
            .environmentObject(state)
    }
}
