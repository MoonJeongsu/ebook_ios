import SwiftUI

struct ReaderView: View {
    @ObservedObject var viewModel: ReaderViewModel
    let bookId: String
    let onBack: () -> Void

    @State private var visibleItemIndex = 0
    @State private var hasRestoredScroll = false

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
                            .id("header")

                            ForEach(Array(viewModel.uiState.paragraphs.enumerated()), id: \.offset) { index, paragraph in
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
                                .id(index)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.preference(
                                            key: VisibleParagraphPreferenceKey.self,
                                            value: geometry.frame(in: .named("readerScroll")).minY <= 120
                                                ? index
                                                : nil
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .coordinateSpace(name: "readerScroll")
                    .onPreferenceChange(VisibleParagraphPreferenceKey.self) { index in
                        if let index {
                            visibleItemIndex = index + 1
                        }
                    }
                    .onAppear {
                        guard !hasRestoredScroll else { return }
                        hasRestoredScroll = true
                        let targetIndex = min(
                            max(viewModel.uiState.initialItemIndex, 0),
                            viewModel.uiState.paragraphs.count
                        )
                        DispatchQueue.main.async {
                            proxy.scrollTo(targetIndex == 0 ? "header" : targetIndex - 1, anchor: .top)
                        }
                        visibleItemIndex = targetIndex
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

    private func saveProgressAndBack() {
        saveProgressIfNeeded()
        onBack()
    }

    private func saveProgressIfNeeded() {
        guard !viewModel.uiState.bookId.isEmpty, !viewModel.uiState.paragraphs.isEmpty else { return }
        viewModel.saveProgress(
            bookId: viewModel.uiState.bookId,
            itemIndex: visibleItemIndex,
            scrollOffset: 0
        )
    }
}

private struct VisibleParagraphPreferenceKey: PreferenceKey {
    static var defaultValue: Int?

    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        if let next = nextValue() {
            value = next
        }
    }
}
