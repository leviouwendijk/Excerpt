public enum LinePresentation {}

public extension LinePresentation {
    struct Role:
        RawRepresentable,
        Sendable,
        Codable,
        Hashable
    {
        public let rawValue: String

        public init(
            rawValue: String
        ) {
            self.rawValue = rawValue
        }

        public init(
            _ rawValue: String
        ) {
            self.init(
                rawValue: rawValue
            )
        }
    }

    struct Segment:
        Sendable,
        Codable,
        Hashable
    {
        public let role: Role?
        public let text: String

        public init(
            role: Role? = nil,
            text: String
        ) {
            self.role = role
            self.text = text
        }
    }

    struct Gutter:
        Sendable,
        Codable,
        Hashable
    {
        public enum Alignment:
            String,
            Sendable,
            Codable,
            Hashable
        {
            case leading
            case trailing
        }

        public struct Column:
            Sendable,
            Codable,
            Hashable
        {
            public let text: String
            public let width: Int
            public let alignment: Alignment

            public init(
                text: String,
                width: Int? = nil,
                alignment: Alignment = .leading
            ) {
                self.text = text
                self.width = max(
                    text.count,
                    width ?? text.count
                )
                self.alignment = alignment
            }

            public static func number(
                _ value: Int?,
                width: Int,
                missingCharacter: Character = "-"
            ) -> Self {
                let text: String

                if let value {
                    text = String(
                        value
                    )
                } else {
                    text = String(
                        repeating: missingCharacter,
                        count: max(
                            0,
                            width
                        )
                    )
                }

                return .init(
                    text: text,
                    width: width,
                    alignment: .trailing
                )
            }

            public var rendered: String {
                let padding = String(
                    repeating: " ",
                    count: max(
                        0,
                        width - text.count
                    )
                )

                switch alignment {
                case .leading:
                    return text + padding

                case .trailing:
                    return padding + text
                }
            }
        }

        public let columns: [Column]
        public let separator: String

        public init(
            columns: [Column],
            separator: String = " "
        ) {
            self.columns = columns
            self.separator = separator
        }

        public var text: String {
            columns
                .map(\.rendered)
                .joined(
                    separator: separator
                )
        }

        public var width: Int {
            text.count
        }

        public static func numberWidth(
            values: [Int?]
        ) -> Int {
            values
                .compactMap { value in
                    value
                }
                .map { value in
                    String(
                        value
                    ).count
                }
                .max()
                ?? 0
        }
    }

    struct Row:
        Sendable,
        Codable,
        Hashable
    {
        public let gutter: Gutter?
        public let segments: [Segment]
        public let componentSpacing: Int
        public let gutterSpacing: Int

        public init(
            gutter: Gutter? = nil,
            segments: [Segment],
            componentSpacing: Int = 0,
            gutterSpacing: Int = 1
        ) {
            self.gutter = gutter
            self.segments = segments
            self.componentSpacing = max(
                0,
                componentSpacing
            )
            self.gutterSpacing = max(
                0,
                gutterSpacing
            )
        }

        public var plainText: String {
            let spacing = String(
                repeating: " ",
                count: componentSpacing
            )
            let content = segments
                .map(\.text)
                .joined(
                    separator: spacing
                )

            guard let gutter else {
                return content
            }

            guard !content.isEmpty else {
                return gutter.text
            }

            return gutter.text
                + String(
                    repeating: " ",
                    count: gutterSpacing
                )
                + content
        }
    }

    enum BorderStyle:
        String,
        Sendable,
        Codable,
        Hashable
    {
        case none
        case square
        case rounded
    }

    struct Block:
        Sendable,
        Codable,
        Hashable
    {
        public let title: Segment?
        public let rows: [Row]
        public let border: BorderStyle

        public init(
            title: Segment? = nil,
            rows: [Row],
            border: BorderStyle = .none
        ) {
            self.title = title
            self.rows = rows
            self.border = border
        }
    }

    struct Plan:
        Sendable,
        Codable,
        Hashable
    {
        public let blocks: [Block]
        public let blockSpacing: Int

        public init(
            blocks: [Block],
            blockSpacing: Int = 1
        ) {
            self.blocks = blocks
            self.blockSpacing = max(
                0,
                blockSpacing
            )
        }
    }
}
