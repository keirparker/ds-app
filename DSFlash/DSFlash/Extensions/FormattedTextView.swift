import SwiftUI

/// Renders card text that may contain:
///   - Triple-backtick code blocks:  ```\ncode\n```
///   - Inline code spans:            `identifier`
///
/// Everything else is rendered as plain body text.
/// Existing cards using plain Unicode math (∇, θ, Σ, O(n log n)) render
/// unchanged. New cards can use backtick syntax for highlighted code.
struct FormattedTextView: View {
    let text: String
    var fontSize: CGFloat = 17
    var fontWeight: Font.Weight = .regular
    var textColor: Color = Color.theme.textPrimary
    var lineSpacing: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .plain(let s):
                    inlineText(s)
                        .lineSpacing(lineSpacing)
                        .fixedSize(horizontal: false, vertical: true)
                case .codeBlock(let code):
                    CodeBlockView(code: code)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Block-level splitting (triple backticks)

    private enum Block { case plain(String), codeBlock(String) }

    private var blocks: [Block] {
        var result: [Block] = []
        let parts = text.components(separatedBy: "```")
        for (i, part) in parts.enumerated() {
            guard !part.isEmpty else { continue }
            result.append(i.isMultiple(of: 2)
                ? .plain(part)
                : .codeBlock(part.trimmingCharacters(in: .newlines))
            )
        }
        return result.isEmpty ? [.plain(text)] : result
    }

    // MARK: - Inline rendering (single backticks → code span)

    private func inlineText(_ s: String) -> Text {
        let parts = s.components(separatedBy: "`")
        return parts.enumerated().reduce(Text("")) { acc, pair in
            let (i, part) = pair
            if i.isMultiple(of: 2) {
                // Regular text
                return acc + Text(part)
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(textColor)
            } else {
                // Code span — monospaced cyan, no background (Text doesn't support bg)
                return acc + Text(part)
                    .font(.system(size: fontSize - 1, design: .monospaced))
                    .foregroundColor(Color.theme.codeForeground)
            }
        }
    }
}

// MARK: - Code block

private struct CodeBlockView: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.theme.codeForeground)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.codeBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.theme.codeForeground.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
