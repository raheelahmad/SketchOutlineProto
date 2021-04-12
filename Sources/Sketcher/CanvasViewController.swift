import UIKit
import SwiftUI
import Combine
import SnapKit

import SketchStatusView
import NodeView
import Models
import Style

public final class CanvasViewController: UIViewController {
    private var nodes: [Node] = [] {
        didSet {
            canvasView.update(nodes)
        }
    }

    private let boundsUpdated = PassthroughSubject<CGRect, Never>()

    lazy var canvasView = CanvasUIView()

    lazy var menuView = UIHostingController(
        // LATER: should pass a view model/publisher
        rootView: SketchStatusView.SketchMenuView(items: [.init(title: "Auto layout", imageName: "perspective")]) { [weak self] selection in
            guard let self = self else { return }

            let nodeWidth = NodeUIView.baseSize.width / self.canvasView.bounds.width
            let nodeHeight = NodeUIView.baseSize.height / self.canvasView.bounds.height
            let metrics = NodesAutoLayout.Metrics(
                nodeSize: .init(width: nodeWidth, height: nodeHeight),
                nodeSpacingX: 0.01, nodeSpacingY: 0.02, interSiblingsSpacing: 0.01, rowSpacing: 0.05,
                margins: CGSize(width: 0.03, height: 0.06)
            )
            self.viewModel.autoLayout.send(metrics)
    })

    private lazy var viewModel = CanvasViewModel(
        nodeRecognized: canvasView.nodeRecognized.eraseToAnyPublisher(),
        linkRecognized: canvasView.linkRecognized.eraseToAnyPublisher(),
        textUpdated: canvasView.textUpdated.eraseToAnyPublisher(),
        boundsUpdated: boundsUpdated.eraseToAnyPublisher()
    )

    private var cancellables: [AnyCancellable] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(canvasView)
        canvasView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addChild(menuView)
        view.addSubview(menuView.view!)
        menuView.view.backgroundColor = .clear
        menuView.view!.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(M.Sp.X.small)
        }
        menuView.didMove(toParent: self)

        viewModel.bindRecognizers()
        viewModel.nodes.sink { [weak self] nodes in
            self?.canvasView.update(nodes)
        }.store(in: &cancellables)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boundsUpdated.send(canvasView.bounds)
    }
}
