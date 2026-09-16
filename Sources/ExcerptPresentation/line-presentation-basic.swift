public extension LinePresentation {
    enum Basic {
        public static func render(
            _ rows: [Row]
        ) -> String {
            rows
                .map(\.plainText)
                .joined(
                    separator: "\n"
                )
        }

        public static func render(
            _ plan: Plan
        ) -> String {
            plan.blocks
                .map { block in
                    render(
                        block
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
            switch block.border {
            case .none:
                var lines: [String] = []

                if let title = block.title {
                    lines.append(
                        title.text
                    )
                }

                lines.append(
                    contentsOf: block.rows.map(
                        \.plainText
                    )
                )

                return lines.joined(
                    separator: "\n"
                )

            case .square:
                return renderBox(
                    block,
                    characters: .square
                )

            case .rounded:
                return renderBox(
                    block,
                    characters: .rounded
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
            characters: BoxCharacters
        ) -> String {
            let rows = block.rows.map(
                \.plainText
            )
            let title = block.title?.text
            let titleWidth = title.map { value in
                value.count + 1
            } ?? 0
            let contentWidth = max(
                1,
                titleWidth,
                rows.map(\.count).max() ?? 0
            )
            let innerWidth = contentWidth + 2
            let horizontal = String(
                characters.horizontal
            )
            let top: String

            if let title {
                let prefix = horizontal
                    + " "
                    + title
                    + " "
                let remainder = max(
                    0,
                    innerWidth - prefix.count
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

            let body = rows.map { row in
                String(
                    characters.vertical
                )
                    + " "
                    + row
                    + String(
                        repeating: " ",
                        count: max(
                            0,
                            contentWidth - row.count
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
