import UIKit
import SwiftUICore

final class AnalyticsViewController: UIViewController {
    
    weak var coordinator: AnalyticsCoordinator?
    private let donutChartView = DonutChartUIKitView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDonutChart()
    }
}

// Пример использования в AnalyticsViewController
extension AnalyticsViewController {
    private func setupDonutChart() {
        view.addSubview(donutChartView)
        
        // Пример данных с UIColor
        let data: [(value: Double, color: UIColor)] = [
            (1, .etbRed), // Красный
            (1, .etGrayBlue), // Синий
            (1, .etGreen), // Зеленый
            (1, .etBlue), // Голубой
            (1, .etYellow), // Оранжевый
            (1, .etPurple), // Фиолетовый
            (1, .etbRed) // Красный
        ]
        
        donutChartView.configure(with: data, overlapAngle: 8)
        
        // Установка констрейнтов
        donutChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            donutChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            donutChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            donutChartView.widthAnchor.constraint(equalToConstant: 130),
            donutChartView.heightAnchor.constraint(equalToConstant: 166)
        ])
    }
}
