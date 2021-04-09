import UIKit
import Combine
import SnapKit

final class CanvasViewController: UIViewController {
    private var nodes: [Node] = [] {
        didSet {
            canvasView.update(nodes)
        }
    }

    lazy var canvasView = CanvasUIView(model: CanvasViewModel())

    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(canvasView)
        canvasView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bindRecognizers()
    }

    private func bindRecognizers() {
        canvasView.nodeRecognized
            .sink { [weak self] recognition in
                guard let self = self else { return }

                let posX = self.canvasView.bounds.width / recognition.center.x
                let posY = self.canvasView.bounds.height / recognition.center.y
                let node = Node(
                    id: UUID().uuidString,
                    title: "",
                    colorHex: "8312A8",
                    fractPos: .init(x: Double(posX), y: Double(posY)),
                    linkedNodeIds: []
                )
                self.nodes.append(node)
            }.store(in: &cancellables)
    }
}
