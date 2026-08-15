import SwiftUI

struct ReaderView: View {
    @ObservedObject var viewModel: ReaderViewModel
    let bookId: String
    let onBack: () -> Void

    @State private var visibleItemIndex = 0
    @State private var visibleItemMinY: CGFloat = 0

    var body: some View {
        Group {
            if viewModel.uiState.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.uiState.errorMessage {
                ErrorView(message: errorMessage)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            headerSection
                                .trackVisibleItem(index: 0)

                            ForEach(Array(viewModel.uiState.paragraphs.enumerated()), id: \.offset) { index, paragraph in
                                paragraphView(paragraph)
                                    .trackVisibleItem(index: index + 1)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .coordinateSpace(name: "readerScroll")
                    .onPreferenceChange(VisibleItemPositionsKey.self) { positions in
                        updateVisibleItem(from: positions)
                    }
                    .task(id: restoreTaskID) {
                        await restoreScrollPosition(using: proxy)
                    }
                }
            }
        }
        .navigationTitle(viewModel.uiState.title.isEmpty ? "읽기" : viewModel.uiState.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    saveProgressAndBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("뒤로")
                    }
                }
            }
        }
        .onDisappear {
            saveProgressIfNeeded()
        }
        .background(AppTheme.background)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.uiState.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text(viewModel.uiState.author)
                .font(.title3)
                .foregroundStyle(AppTheme.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 12)
        .id(0)
    }

    @ViewBuilder
    private func paragraphView(_ paragraph: String) -> some View {
        Group {
            if paragraph.isEmpty {
                Text("")
                    .padding(.bottom, 4)
            } else {
                Text(paragraph)
                    .font(.system(size: 18))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var restoreTaskID: String {
        [
            viewModel.uiState.bookId,
            String(viewModel.uiState.paragraphs.count),
            String(viewModel.uiState.initialItemIndex),
            String(viewModel.uiState.initialScrollOffset),
        ].joined(separator: "|")
    }

    @MainActor
    private func restoreScrollPosition(using proxy: ScrollViewProxy) async {
        guard !viewModel.uiState.paragraphs.isEmpty else { return }

        let maxIndex = viewModel.uiState.paragraphs.count
        let targetIndex = min(max(viewModel.uiState.initialItemIndex, 0), maxIndex)
        visibleItemIndex = targetIndex

        for attempt in 0..<6 {
            if attempt > 0 {
                try? await Task.sleep(nanoseconds: UInt64(50_000_000 * attempt))
            }
            proxy.scrollTo(targetIndex, anchor: .top)
        }
    }

    private func updateVisibleItem(from positions: [Int: CGFloat]) {
        guard !positions.isEmpty else { return }

        let topThreshold: CGFloat = 140
        let candidates = positions.filter { $0.value <= topThreshold }
        guard let best = candidates.max(by: { $0.value < $1.value }) else { return }

        visibleItemIndex = best.key
        visibleItemMinY = best.value
    }

    private func saveProgressAndBack() {
        saveProgressIfNeeded()
        onBack()
    }

    private func saveProgressIfNeeded() {
        guard !viewModel.uiState.bookId.isEmpty, !viewModel.uiState.paragraphs.isEmpty else { return }

        let scrollOffset = Int(-visibleItemMinY.rounded())
        viewModel.saveProgress(
            bookId: viewModel.uiState.bookId,
            itemIndex: visibleItemIndex,
            scrollOffset: max(scrollOffset, 0)
        )
    }
}

private struct VisibleItemPositionsKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private extension View {
    func trackVisibleItem(index: Int) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: VisibleItemPositionsKey.self,
                    value: [index: geometry.frame(in: .named("readerScroll")).minY]
                )
            }
        }
        .id(index)
    }
}
