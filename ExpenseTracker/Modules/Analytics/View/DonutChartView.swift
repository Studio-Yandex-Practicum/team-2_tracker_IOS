import SwiftUI
import UIKit

struct DonutChartView: View {
    let data: [(value: Double, color: UIColor)]
    let size: CGFloat
    let lineWidth: CGFloat
    let overlapAngle: Double
    @State private var trimEnd: CGFloat = 0
    
    init(data: [(value: Double, color: UIColor)], size: CGFloat = 130, lineWidth: CGFloat = 20, overlapAngle: Double = 5) {
        let total = data.reduce(0) { $0 + $1.value }
        self.data = data.map { ($0.value / total, $0.color) }
        self.size = size
        self.lineWidth = lineWidth
        self.overlapAngle = overlapAngle
    }
    
    var body: some View {
        ZStack {
            ForEach((0..<data.count).reversed(), id: \.self) { index in
                DonutSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: Color(data[index].color),
                    lineWidth: lineWidth,
                    trimEnd: trimEnd
                )
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                trimEnd = 1.0
            }
        }
    }
    
    private func startAngle(for index: Int) -> Double {
        let previousValues = data.prefix(index).map { $0.value }
        let previousSum = previousValues.reduce(0, +)
        return previousSum * 360
    }
    
    private func endAngle(for index: Int) -> Double {
        let previousValues = data.prefix(index + 1).map { $0.value }
        let sum = previousValues.reduce(0, +)
        return sum * 360
    }
}

struct DonutSlice: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    let lineWidth: CGFloat
    let trimEnd: CGFloat
    
    private var sliceAngle: Double {
        endAngle - startAngle
    }
    
    var body: some View {
        Circle()
            .trim(from: startAngle / 360, to: (startAngle + sliceAngle * Double(trimEnd)) / 360)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: 110, height: 110)
    }
}

// UIKit wrapper
final class DonutChartUIKitView: UIView {
    
    private var hostingController: UIHostingController<DonutChartView>?
    
    func configure(with data: [(value: Double, color: UIColor)], size: CGFloat = 130, lineWidth: CGFloat = 16, overlapAngle: Double = 5) {
        let donutChart = DonutChartView(data: data, size: size, lineWidth: lineWidth, overlapAngle: overlapAngle)
        
        if let hostingController = hostingController {
            hostingController.rootView = donutChart
        } else {
            let hostingController = UIHostingController(rootView: donutChart)
            self.hostingController = hostingController
            
            addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}
