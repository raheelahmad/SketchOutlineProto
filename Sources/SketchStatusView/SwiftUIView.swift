//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/20/21.
//

import SwiftUI
import Style

public struct SwiftUIView: View {
    public init() { }

    public var body: some View {
        VStack(alignment: .center) {
            Text("Status".uppercased())
                .bold()
                .foregroundColor(.primaryBackground)
                .tracking(1.3)
        }
        .padding()
        .background(
            LinearGradient(gradient: .statusOverlay, startPoint: .top, endPoint: .bottom))
    }
}

@available(OSX 11.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SwiftUIView()
                .previewLayout(.sizeThatFits)
                .frame(width: 400, height: 200)
                .preferredColorScheme(.light)
            SwiftUIView()
                .previewLayout(.sizeThatFits)
                .frame(width: 400, height: 200)
                .preferredColorScheme(.dark)
        }
    }
}
