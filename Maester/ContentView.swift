//
//  ContentView.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/3.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import SwiftUI


struct SyncStatusView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    @Binding var status: SyncStatus
    
    private let images = [SyncStatus.On: Self.load_gif("on_sync"),
                          SyncStatus.In: Self.load_gif("in_sync"),
                          SyncStatus.Out: Self.load_gif("out_sync"),
                          SyncStatus.Login: Self.load_gif("out_sync")]
        
    func makeUIView(context: UIViewRepresentableContext<SyncStatusView>) -> UIImageView {
        return Self.img_view(self.images[self.status]!)
    }
    
    func updateUIView(_ uiView: UIImageView, context: UIViewRepresentableContext<SyncStatusView>) {
        // print("updating view for \(self.status)")
        // uiView.stopAnimating()
        uiView.image = self.images[self.status]!
        // uiView.startAnimating()
    }
    
    static func load_gif(_ path: String) -> UIImage {
        // let source = CGImageSourceCreateWithData(NSDataAsset(name: path)!.data as CFData, nil)
        // let image = UIImage(data: NSDataAsset(name: path)!.data as CG)!
        
        // image.resizingMode = .stretch
        let img = UIImage.gif(asset: path, size: CGSize(width: 20, height: 20))!
        // img.size = .init(width: 40, height: 40)
        // let newSize = CGSize.init(width: 40, height: 40)
        /*
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        img.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        */
        /*
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image { _ in
            img.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        */
        return img
    }
    
    static func img_view(_ image: UIImage) -> UIImageView {
        let image_view = UIImageView(image: image)
        // image_view.imageScaling = .scaleProportionallyUpOrDown
        // image_view.animates = true
        image_view.contentMode = .scaleAspectFit
        // image_view.frame = CGRect.init(x: 0, y: 0, width: 10, height: 10)
        // image_view.frame = CGRectMake(0, 0, 10, 10);
        // image_view.center = image_view.superview!.center;
        // image_view.contentMode = .scaleAspectFit

        /*
        image_view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        image_view.sizeToFit()
        */
        // image_view.startAnimating()
        
        return image_view
    }
}


struct PageLauncher: View
{
    let width: CGFloat
    let height: CGFloat
    let label: String? = nil
    
    let page_type: PageType
    
    @State var color = Color.blue
    
    static let images = [PageType.Link: Image("page_link")]

    var body: some View {
        VStack {
            Self.images[self.page_type]!
                .resizable()
                .renderingMode(.template)
                .foregroundColor(self.color)
                .accessibility(label: Text("Page Launcher"))
                .aspectRatio(1, contentMode: .fit)
                .padding(.top, -2)
                .padding(.trailing, 1)
        }
        .frame(width: width, height: height)
        // .contentShape(Rectangle())
        // .background(MaesterConstants.backgroundColor)
    }
}

struct PageRow: View {
    var page_id: String
    var page: Page
    @Binding var read_page_id: String
    @State private var color = Color.black

    var body: some View {
        VStack {
            HStack {
                Text(page.name)
                    .font(.system(size: 15))
                    .foregroundColor(Color.black).lineLimit(1)
                Spacer()
                ForEach(page.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12))
                        .padding(.horizontal, 4)
                        //.background(Color(red: 189.0/255.0, green: 183.0/255.0, blue: 184.0/255.0, opacity: 0.3))
                    .cornerRadius(5)
                }
            }
            HStack {
                Text(page.content)
                    .font(.system(size: 10))
                    .foregroundColor(Color.gray).lineLimit(1)
                Spacer()
                Text(page.category)
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
            }
        }
            .padding(.bottom, 2)
            .padding(.top, 1)
            .padding(.trailing, 10)
            .padding(.leading, 15)
        // .background(self.read_page_id == self.page_id ? self.color_selected : self.color_hover)
    }
}

struct PageRow_Previews: PreviewProvider {
    @State static var read_page_id = "page_id"
    static var previews: some View {
        Group {
            PageRow(page_id: "", page: Page(withLink: "http://link1.com"), read_page_id: $read_page_id)
            PageRow(page_id: "page_id", page: Page(withLink: "http://link2.com"), read_page_id: $read_page_id)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

struct ContentView: View {
    @State private var selection = 0
    @EnvironmentObject var state: MaesterState
    @State private var show_account = false
    // @State private var show_page_detail = false
 
    var body: some View {
        Group {
            
            VStack {
                SyncStatusView(status: self.$state.sync_status)
                    .padding(.bottom, -12)
                    .padding(.top, -16)
            }.frame(width: 30, height: 0).zIndex(100).padding(.top, 0)
            
            
            // if self.state.entry == MainPage.Main {
            TabView(selection: $selection) {
                NavigationView {
                    List {
                        ForEach(self.state.book.history.indices, id: \.self) { index in
                            Group {
                                HStack {
                                    Button (action: {
                                        let page = self.state.book.history[index]
                                        self.state.read_page = page.1
                                        self.state.read_page_id = page.0
                                        // self.state.entry = .PageDetail
                                        self.state.show_page_detail = true
                                        self.state.check_sync()
                                        
                                    }) {
                                        PageRow(page_id: self.state.book.history[index].0, page: self.state.book.history[index].1, read_page_id: self.$state.read_page_id)
                                        }.buttonStyle(BorderlessButtonStyle())
                                    .padding(.vertical, 0).padding(.trailing, -4)
                                        .sheet(isPresented: self.$state.show_page_detail) {
                                            PageDetailView().environmentObject(self.state)
                                    }
                                    Button (action: {
                                        let page = self.state.book.history[index].1
                                        switch page.page_type {
                                        case .Link:
                                            if let url = URL(string: page.content) {
                                                UIApplication.shared.open(url)
                                                // _ = NSWorkspace.shared.open(url)
                                            }
                                        }
                                    }) {
                                        PageLauncher(width: 32, height: 50, page_type: self.state.book.history[index].1.page_type)
                                        }.buttonStyle(BorderlessButtonStyle())
                                    .padding(.vertical, 0)
                                }.padding(.vertical, -4)
                            }
                        }
                    }
                    .navigationBarTitle(Text("Recent"))
                    .navigationBarItems(
                        leading: NavigationLink(destination: AccountView()) {
                            /*Image("user").resizable().renderingMode(.template).foregroundColor(Color.blue)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 20, height: 20)*/
                            Image(systemName: "person.crop.circle")
                        },
                        trailing: Button(action: {
                            self.state.write_page = Page(withLink: "")
                            self.state.new_page_data = [:]
                            // self.state.entry = .AddPage
                            self.state.show_new_page = true
                            self.state.check_sync()
                        }) {
                            Image(systemName: "square.and.pencil")
                        }.sheet(isPresented: self.$state.show_new_page) {
                            NewPageView(page_id: "").environmentObject(self.state)
                        }
                    )
                    .navigationBarHidden(false)
                }
                    .tabItem {
                        VStack {
                            Image("recent").renderingMode(.template)
                            Text("Recent")
                        }
                    }
                    .tag(1)
                NavigationView {
                    SearchView()
                    .navigationBarItems(
                        leading: NavigationLink(destination: AccountView()) {
                            /*Image("user").resizable().renderingMode(.template).foregroundColor(Color.blue)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 20, height: 20)*/
                            Image(systemName: "person.crop.circle")
                        },
                        trailing: Button(action: {
                            self.state.write_page = Page(withLink: "")
                            self.state.new_page_data = [:]
                            // self.state.entry = .AddPage
                            self.state.show_new_page = true
                            self.state.check_sync()
                        }) {
                            Image(systemName: "square.and.pencil")
                        }.sheet(isPresented: self.$state.show_new_page) {
                            NewPageView(page_id: "").environmentObject(self.state)
                        }
                    )
                    .navigationBarTitle(Text("Search"))
                    
                }
                    .tabItem {
                        VStack {
                            Image("search").renderingMode(.template)
                            Text("Search")
                        }
                    }
                    .tag(0)
            }
            /*
            } else if self.state.entry == MainPage.AddPage {
                NavigationView  {
                    NewPageView(page_id: "")
                        .navigationBarHidden(false)
                        .navigationBarTitle(Text("New Page"))
                        .navigationBarItems(leading: Button(action: {
                            self.state.entry = .Main
                            self.state.new_page_data = [:]
                            self.state.check_sync()
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
                               self.state.entry = .Main
                               self.state.check_sync()
                           })
                           {
                               Text("Cancel")
                           })
                    }
            } else {
                NavigationView {
                    PageDetailView(main_selection: $selection)
                        .navigationBarHidden(false)
                        .navigationBarTitle(Text("Page Detail"))
                        .navigationBarItems(leading: Button(action: {
                            self.state.entry = .Main
                            self.state.check_sync()
                        })
                        {
                            Text("Back")
                        }, trailing: Button(action: {
                            self.state.write_page = self.state.read_page
                            self.state.entry = .EditPage
                            self.state.check_sync()
                        })
                        {
                            Text("Edit")
                        })
                }
            }*/
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MaesterState()
        state.sync(force: true)
        for (id, page) in state.book.entity.data {
            state.book.insert_into_history(id: id, page: page)
        }
        return ContentView()
        .environmentObject(state)
    }
}
