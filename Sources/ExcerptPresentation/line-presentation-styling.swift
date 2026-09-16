public protocol LinePresentationStyling:
    Sendable
{
    func render(
        role: LinePresentation.Role?,
        text: String
    ) -> String
}

public struct PlainLinePresentationStyling:
    LinePresentationStyling
{
    public init() {}

    public func render(
        role: LinePresentation.Role?,
        text: String
    ) -> String {
        text
    }
}

public extension LinePresentation.Gutter.Column {
    func rendered(
        using styling: any LinePresentationStyling
    ) -> String {
        let padding = String(
            repeating: " ",
            count: max(
                0,
                width - text.count
            )
        )
        let renderedText = styling.render(
            role: role,
            text: text
        )

        switch alignment {
        case .leading:
            return renderedText + padding

        case .trailing:
            return padding + renderedText
        }
    }
}

public extension LinePresentation.Gutter {
    func rendered(
        using styling: any LinePresentationStyling
    ) -> String {
        columns
            .map { column in
                column.rendered(
                    using: styling
                )
            }
            .joined(
                separator: separator
            )
    }
}

public extension LinePresentation.Row {
    func rendered(
        using styling: any LinePresentationStyling
    ) -> String {
        let spacing = String(
            repeating: " ",
            count: componentSpacing
        )
        let content = segments
            .map { segment in
                styling.render(
                    role: segment.role,
                    text: segment.text
                )
            }
            .joined(
                separator: spacing
            )

        guard let gutter else {
            return content
        }

        let renderedGutter = gutter.rendered(
            using: styling
        )

        guard !content.isEmpty else {
            return renderedGutter
        }

        return renderedGutter
            + String(
                repeating: " ",
                count: gutterSpacing
            )
            + content
    }
}
