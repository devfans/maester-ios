//
//  SearchResultView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/10.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    @EnvironmentObject var state: MaesterState
    
    func set_read_page(_ page_id: String, _ page: Page) -> PageDetailView {
        self.state.read_page_id = page_id
        self.state.read_page = page
        return PageDetailView()
    }
    var body: some View {
        VStack {
            List {
                ForEach(self.state.book.search(self.state.search_keyword, self.state.search_type), id: \.self) { page_id in
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
        }
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView().environmentObject(MaesterState())
    }
}
