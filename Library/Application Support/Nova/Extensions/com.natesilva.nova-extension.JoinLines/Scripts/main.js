nova.commands.register("join-lines.joinLines", (editor) => {
  const noTrailingWhitespace =
    nova.workspace.config.get("join-lines.no-trailing-whitespace", "boolean") ||
    false;

  // A RegExp that selects all occurrences of eol and surrounding
  // whitespace, unless it occurs at the very end of the text.
  const rx = new RegExp(`\\s*${editor.document.eol}\\s*(?!$)`, "g");

  // Get ranges in reverse order so ranges don’t “shift” as we edit.
  const ranges = [...editor.selectedRanges].reverse();

  editor.edit((e) => {
    ranges.forEach((r) => {
      let extendedRange = editor.getLineRangeForRange(r);
      let text = editor.getTextInRange(extendedRange);

      if (!rx.test(text)) {
        // A single line, or part of a single line was selected.
        // Extend the selection to the following line.
        const nextLine = editor.getLineRangeForRange(
          new Range(extendedRange.end, extendedRange.end)
        );
        extendedRange = extendedRange.union(nextLine);
        text = editor.getTextInRange(extendedRange);
      }

      const replacementText = text.replace(rx, noTrailingWhitespace ? "" : " ");

      if (replacementText !== text) {
        e.replace(extendedRange, replacementText);
      }
    });
  });
});
