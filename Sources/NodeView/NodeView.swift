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
    public static var baseSize: CGSize = .init(width: 160, height: 60)
    public let id: String

    let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.textAlignment = .center
        field.font = .systemFont(ofSize: 14, weight: .semibold)
        field.textColor = .white
        return field
    }()

    public init(id: String) {
        self.id = id
        super.init(frame: .init(origin: .zero, size: Self.baseSize))
        addSubview(field)
        field.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(M.Sp.X.small)
            make.top.bottom.equalToSuperview().inset(M.Sp.Y.small)
        }
        field.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)

        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
    }

    public let textUpdated = PassthroughSubject<String?, Never>()

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

extension NodeUIView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @objc func textChanged(textField: UITextField) {
        textUpdated.send(textField.text)
    }

    public func updateText(_ text: String?) {
        field.text = text
    }

    public func updateColor(_ color: UIColor?) {
        backgroundColor = color
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
