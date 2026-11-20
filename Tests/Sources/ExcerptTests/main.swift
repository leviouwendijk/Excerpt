import Excerpt
import ExcerptPresentation
import Foundation
import Position

enum RegressionFailure: Error {
    case assertion(String)
}

func expect(
    _ condition: @autoclosure () -> Bool,
    _ message: String
) throws {
    guard condition() else {
        throw RegressionFailure.assertion(
            message
        )
    }
}

func sourceExcerptCoalescesContextAndExactRanges() throws {
    let file = URL(
        fileURLWithPath: "/tmp/excerpt.swift"
    )
    let first = try LineRange(start: 3, end: 3)
    let duplicate = try LineRange(start: 3, end: 3)
    let second = try LineRange(start: 5, end: 5)
    let far = try LineRange(start: 10, end: 10)
    let lines = (1...12).map { line in
        "line \(line)"
    }

    let excerpt = SourceExcerpt.make(
        file: file,
        lines: lines,
        ranges: [
            first,
            duplicate,
            second,
            far,
        ],
        options: .init(
            contextLines: 1,
            mergeGap: 0
        )
    )

    try expect(
        excerpt.windows.count == 2,
        "nearby context windows coalesce"
    )
    try expect(
        excerpt.windows[0].ranges == [
            first,
            second,
        ],
        "exact duplicate ranges collapse"
    )
    try expect(
        excerpt.windows[0].slice.startLine == 2,
        "first excerpt context start"
    )
    try expect(
        excerpt.windows[0].slice.lines == [
            "line 2",
            "line 3",
            "line 4",
            "line 5",
            "line 6",
        ],
        "first excerpt context contents"
    )
    try expect(
        excerpt.windows[1].slice.startLine == 9,
        "far finding gets a separate window"
    )
}

func linePresentationRendersGuttersAndRoundedBlocks() throws {
    let gutter = LinePresentation.Gutter(
        columns: [
            .number(
                7,
                width: 2
            ),
            .init(
                text: "│"
            ),
        ],
        separator: " "
    )
    let row = LinePresentation.Row(
        gutter: gutter,
        segments: [
            .init(
                text: "value"
            ),
        ]
    )
    let block = LinePresentation.Block(
        title: .init(
            text: "Example"
        ),
        rows: [
            row,
        ],
        border: .rounded
    )
    let rendered = LinePresentation.Basic.render(
        .init(
            blocks: [
                block,
            ]
        )
    )

    try expect(
        rendered.contains(
            "╭─ Example"
        ),
        "rounded title border"
    )
    try expect(
        rendered.contains(
            " 7 │ value"
        ),
        "numbered gutter"
    )
    try expect(
        rendered.hasSuffix(
            "╯"
        ),
        "rounded bottom border"
    )
}

private struct TaggedStyling:
    LinePresentationStyling
{
    func render(
        role: LinePresentation.Role?,
        text: String
    ) -> String {
        guard let role else {
            return text
        }

        return "<\(role.rawValue)>"
            + text
            + "</\(role.rawValue)>"
    }
}

func styledPresentationMeasuresRawText() throws {
    let titleRole = LinePresentation.Role(
        "title"
    )
    let warningRole = LinePresentation.Role(
        "warning"
    )
    let lineRole = LinePresentation.Role(
        "line"
    )
    let block = LinePresentation.Block(
        title: .init(
            role: titleRole,
            text: "Example"
        ),
        rows: [
            .init(
                gutter: .init(
                    columns: [
                        .number(
                            7,
                            width: 2,
                            role: lineRole
                        ),
                    ]
                ),
                segments: [
                    .init(
                        role: warningRole,
                        text: "value"
                    ),
                ]
            ),
        ],
        border: .rounded
    )
    let rendered = LinePresentation.Basic.render(
        block,
        styling: TaggedStyling()
    )

    try expect(
        rendered.contains(
            "<title>Example</title>"
        ),
        "title role styling"
    )
    try expect(
        rendered.contains(
            "<line>7</line>"
        ),
        "gutter column role styling"
    )
    try expect(
        rendered.contains(
            "<warning>value</warning>"
        ),
        "segment role styling"
    )
    try expect(
        rendered.hasSuffix(
            "╰──────────╯"
        ),
        "box width is measured from raw text rather than styled output"
    )
}

try sourceExcerptCoalescesContextAndExactRanges()
try linePresentationRendersGuttersAndRoundedBlocks()
try styledPresentationMeasuresRawText()
print("ExcerptTests: passed")
