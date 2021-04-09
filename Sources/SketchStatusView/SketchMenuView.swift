//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/20/21.
//

import SwiftUI
import Style

public struct SketchMenuView: View {
    public struct Item: Identifiable, Hashable {
        public var id: Int { hashValue }

        let title: String
        let imageName: String

        public init(title: String, imageName: String) {
            self.title = title
            self.imageName = imageName
        }
    }

    var items: [Item]

    public typealias Selection = ((Item) -> ())

    @State private var active: Item? {
        didSet {
            if let selected = active {
                selection(selected)
            }
        }
    }
    private let selection: Selection

    public init(items: [Item], selection: @escaping Selection) {
        self.items = items
        self.selection = selection
    }

    public var body: some View {
        HStack(spacing: M.Sp.X.small) {
            ForEach(items) { item in
                Image(systemName: item.imageName)
                    .animation(.easeIn(duration: 0.3))
                    .foregroundColor(Color.blueMed)
                    .scaleEffect(item == active ? 0.84 : 1.0)
                    .onTapGesture {
                        withAnimation {
                            active = active == item ? nil : item
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                active = active == item ? nil : item
                            }
                        }
                    }
            }
        }
        .padding([.leading, .trailing], M.Sp.X.small)
        .padding([.top, .bottom], M.Sp.Y.small)
        .background(Color.gray0105)
        .cornerRadius(M.Sp.X.mini)
    }
}

@available(OSX 11.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SketchMenuView(items: [
                .init(title: "Draw", imageName: "scribble"),
                .init(title: "Draw", imageName: "paperplane"),
            ]) { _ in }
                .previewLayout(.sizeThatFits)
                .frame(width: 400, height: 200)
            .preferredColorScheme(.light)
            .animation(/*@START_MENU_TOKEN@*/.default/*@END_MENU_TOKEN@*/)
        }
    }
}
