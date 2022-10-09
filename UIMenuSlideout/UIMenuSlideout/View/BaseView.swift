//
//  BaseView.swift
//  UIMenuSlideout
//
//  Created by Brendan Losinski on 8/5/22.
//

import SwiftUI

struct BaseView: View {
    @State var showMenu: Bool = false
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    
    @State var currentTab = "Home"
    
    //Offset Drag gestures and show menu
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    
    //Gesture Offset
    @GestureState var gestureOffset: CGFloat = 0
    
    var body: some View{
        let sideBarWidth = getRect().width - 90
        
        NavigationView{
            HStack(spacing: 0){
                SideMenu(showMenu: $showMenu)
                VStack(spacing: 0){
                    TabView(selection: $currentTab){
                        Home(showMenu: $showMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Home")
                        Search(showMenu: $showMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Search")
                        Notifications(showMenu: $showMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Notifications")
                        Messages(showMenu: $showMenu)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Messages")
                    }
                    
                    VStack(spacing: 0){
                        Divider()
                        HStack(spacing: 0){
                            TabButton(image: "Home")
                            TabButton(image: "Search")
                            TabButton(image: "Notifications")
                            TabButton(image: "Message")
                        }
                        .padding(.top,15)
                        .padding(.bottom,safeArea().bottom == 0 ? 15 : 0)
                    }
                }
                .frame(width: getRect().width)
                .overlay(
                    Rectangle()
                        .fill(
                            Color.primary
                                .opacity(Double((offset / sideBarWidth) / 5))
                        )
                        .ignoresSafeArea(.container, edges: .vertical)
                        .onTapGesture{
                            withAnimation{
                                showMenu.toggle()
                            }
                        }
                )
            }
            // Max Size
            .frame(width: getRect().width + sideBarWidth)
            .offset(x: -sideBarWidth / 2)
            .offset(x: offset > 0 ? offset : 0)
            //Gesture
            .gesture(
                
                DragGesture()
                    .updating($gestureOffset, body: {value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded(onEnd(value:))
            )
            //No nav bar title
            //Hiding nav bar
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .animation(.easeOut, value: offset == 0)
        .onChange(of: showMenu) { newValue in
            if showMenu && offset == 0 {
                offset = sideBarWidth
                lastStoredOffset = offset
            }
            if !showMenu && offset == sideBarWidth{
                offset = 0
                lastStoredOffset = 0
            }
        }
        .onChange(of: gestureOffset) { newValue in
            onChange()
        }
    }
    
    func onChange(){
        let sideBarWidth = getRect().width - 90
        offset = (gestureOffset != 0) ? ((gestureOffset + lastStoredOffset) < sideBarWidth ? (gestureOffset + lastStoredOffset) : offset) : offset
        
        offset = (gestureOffset + lastStoredOffset) > 0 ? offset : 0
    }
    
    func onEnd(value: DragGesture.Value){
        let sideBarWidth = getRect().width - 90
        let translation = value.translation.width
        
        withAnimation{
            if translation > 0{
                if translation > (sideBarWidth / 2){
                    offset = sideBarWidth
                    showMenu = true
                }
                else {
                    if offset == sideBarWidth || showMenu{
                        return
                    }
                    offset = 0
                    showMenu = false
                }
            }
            else {
                if -translation > (sideBarWidth / 2){
                    offset = 0
                    showMenu = false
                }
                else{
                    if offset == 0 || !showMenu{
                        return
                    }
                    offset = sideBarWidth
                    showMenu = true
                }
            }
        }
        lastStoredOffset = offset
    }
    
    @ViewBuilder
    func TabButton(image: String)->some View{
        Button {
            withAnimation{currentTab = image}
        } label: {
            Image(image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 23, height: 22)
                .foregroundColor(currentTab == image ? .primary : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseView()
    }
}
