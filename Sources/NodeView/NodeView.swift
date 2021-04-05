//
//  NodeView.swift
//  
//
//  Created by Raheel Ahmad on 3/30/21.
//

import SwiftUI
import SnapKit
import Combine

import Style

struct NodeView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        NodeUIView(id: UUID().uuidString)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

public final class NodeUIView: UIView {
    public let id: String

    let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Text"
        field.textColor = .systemGray6
        return field
    }()

    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        backgroundColor = [UIColor.hex(0x454440), UIColor.hex(0x409D8F), UIColor.hex(0xF92943)].randomElement()!
        addSubview(field)
        field.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(44)
            make.center.equalToSuperview()
        }

        layer.cornerRadius = 8
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let w = field.bounds.width + 40
        let h = field.bounds.height + 40
        bounds = .init(x: 0, y: 0, width: w, height: h)

    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension NodeUIView {
    public func activateEditing() {
        field.becomeFirstResponder()
    }

    public func highlighted(_ active: Bool) {
        alpha = active ? 0.3 : 1.0
        layer.shadowOpacity = active ? 0.8 : 1.0
    }

    @objc
    func longPressed(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .recognized else {
            return
        }
        highlighted(true)
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NodeView()
            Text("Hello")
        }
          .previewDevice(/*@START_MENU_TOKEN@*/"iPhone 12 mini"/*@END_MENU_TOKEN@*/)
    }
}
