public extension LinePresentation {
    enum Basic {
        public static func render(
            _ rows: [Row]
        ) -> String {
            render(
                rows,
                styling: PlainLinePresentationStyling()
            )
        }

        public static func render(
            _ rows: [Row],
            styling: any LinePresentationStyling
        ) -> String {
            rows
                .map { row in
                    row.rendered(
                        using: styling
                    )
                }
                .joined(
                    separator: "\n"
                )
        }

        public static func render(
            _ plan: Plan
        ) -> String {
            render(
                plan,
                styling: PlainLinePresentationStyling()
            )
        }

        public static func render(
            _ plan: Plan,
            styling: any LinePresentationStyling
        ) -> String {
            plan.blocks
                .map { block in
                    render(
                        block,
                        styling: styling
                    )
                }
                .joined(
                    separator: String(
                        repeating: "\n",
                        count: plan.blockSpacing + 1
                    )
                )
        }

        public static func render(
            _ block: Block
        ) -> String {
            render(
                block,
                styling: PlainLinePresentationStyling()
            )
        }

        public static func render(
            _ block: Block,
            styling: any LinePresentationStyling
        ) -> String {
            switch block.border {
            case .none:
                var lines: [String] = []

                if let title = block.title {
                    lines.append(
                        styling.render(
                            role: title.role,
                            text: title.text
                        )
                    )
                }

                lines.append(
                    contentsOf: block.rows.map { row in
                        row.rendered(
                            using: styling
                        )
                    }
                )

                return lines.joined(
                    separator: "\n"
                )

            case .square:
                return renderBox(
                    block,
                    characters: .square,
                    styling: styling
                )

            case .rounded:
                return renderBox(
                    block,
                    characters: .rounded,
                    styling: styling
                )
            }
        }

        private struct BoxCharacters {
            let topLeft: Character
            let topRight: Character
            let bottomLeft: Character
            let bottomRight: Character
            let horizontal: Character
            let vertical: Character

            static let square = Self(
                topLeft: "┌",
                topRight: "┐",
                bottomLeft: "└",
                bottomRight: "┘",
                horizontal: "─",
                vertical: "│"
            )

            static let rounded = Self(
                topLeft: "╭",
                topRight: "╮",
                bottomLeft: "╰",
                bottomRight: "╯",
                horizontal: "─",
                vertical: "│"
            )
        }

        private static func renderBox(
            _ block: Block,
            characters: BoxCharacters,
            styling: any LinePresentationStyling
        ) -> String {
            let rawRows = block.rows.map(
                \.plainText
            )
            let renderedRows = block.rows.map { row in
                row.rendered(
                    using: styling
                )
            }
            let title = block.title
            let titleWidth = title.map { value in
                value.text.count + 1
            } ?? 0
            let contentWidth = max(
                1,
                titleWidth,
                rawRows.map(\.count).max() ?? 0
            )
            let innerWidth = contentWidth + 2
            let horizontal = String(
                characters.horizontal
            )
            let top: String

            if let title {
                let renderedTitle = styling.render(
                    role: title.role,
                    text: title.text
                )
                let prefix = horizontal
                    + " "
                    + renderedTitle
                    + " "
                let rawPrefixWidth = title.text.count + 3
                let remainder = max(
                    0,
                    innerWidth - rawPrefixWidth
                )

                top = String(
                    characters.topLeft
                )
                    + prefix
                    + String(
                        repeating: horizontal,
                        count: remainder
                    )
                    + String(
                        characters.topRight
                    )
            } else {
                top = String(
                    characters.topLeft
                )
                    + String(
                        repeating: horizontal,
                        count: innerWidth
                    )
                    + String(
                        characters.topRight
                    )
            }

            let body = zip(
                rawRows,
                renderedRows
            )
            .map { rawRow, renderedRow in
                String(
                    characters.vertical
                )
                    + " "
                    + renderedRow
                    + String(
                        repeating: " ",
                        count: max(
                            0,
                            contentWidth - rawRow.count
                        )
                    )
                    + " "
                    + String(
                        characters.vertical
                    )
            }
            let bottom = String(
                characters.bottomLeft
            )
                + String(
                    repeating: horizontal,
                    count: innerWidth
                )
                + String(
                    characters.bottomRight
                )

            return (
                [
                    top,
                ]
                    + body
                    + [
                        bottom,
                    ]
            )
            .joined(
                separator: "\n"
            )
        }
    }
}
