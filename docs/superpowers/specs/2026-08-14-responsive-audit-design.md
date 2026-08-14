# CINI 2026 Responsive Audit Design

## Objective

Make the current CINI 2026 site comfortable and reliable on phones and tablets from 320 to 1024 pixels wide without redesigning the desktop site or replacing the remote Jekyll theme.

## Scope

Audit and correct the current homepage, navigation, program, program search and results, scientific-session panel, talks, speakers, rooms, and location pages. Preserve existing content, program structure, search ranking, and desktop behavior.

## Approach

Use targeted local CSS and minimal markup changes. Do not copy or replace broad theme layouts unless a confirmed defect cannot be corrected safely with an override. Test representative widths of 320, 375, 768, and 1024 pixels.

## Responsive behavior

- Preserve the visual distinction between the on-site and online program columns.
- On screens too narrow to display the program legibly, retain a horizontally scrollable timetable instead of compressing or stacking the two room columns.
- Keep the timetable's day selector and room headings understandable while scrolling.
- Let the scientific-session control, search input, clear button, and navigation provide comfortable touch targets.
- Stack search results in one column on phones; allow two columns where Bootstrap's existing large breakpoint permits.
- Wrap long talk titles, speaker names, room labels, navigation entries, and user-visible URLs without clipping or causing page-level horizontal overflow.
- Reduce excessive whitespace and oversized headings on phones while preserving readable spacing.
- Keep expanded session details left-aligned and usable on small screens.
- Preserve the existing desktop layout above the responsive ranges affected by each correction.

## Accessibility

- Preserve keyboard access, visible controls, labels, live search status, and expanded/collapsed state semantics.
- Do not reduce text or touch targets below practical mobile sizes.
- Prefer normal wrapping and component-level scrolling over clipped content.

## Verification

- Add automated assertions for the responsive stylesheet and critical program behavior.
- Run the complete Jekyll build and existing content/search validators.
- Check for page-level horizontal overflow and broken components at 320, 375, 768, and 1024 pixels.
- Visually inspect the homepage, program, talks, speakers, room/location, mobile navigation, search results, and expanded session panel.

## Non-goals

- No new visual identity or desktop redesign.
- No replacement of Bootstrap or the remote conference theme.
- No changes to conference content, schedule assignments, or search relevance rules.
