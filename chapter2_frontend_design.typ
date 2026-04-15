= Frontend Design

== UI/UX Design with Figma

Before implementation, I used Figma @figma to plan the participant interface and the main user
flow. I did not use this stage just to make visual mockups. I also used it to check whether the
workflow could support contest use without too much page switching or confusing interaction
patterns. By deciding the placement of navigation, cards, forms, headers, and content areas early,
I reduced the amount of structural rework needed during React implementation.

The Figma stage also helped me separate two questions: what information a page should show, and how
that information should be arranged so that users can act on it quickly. This was important because
contest users often move between statements, clarifications, submissions, and code editing under
time pressure.

#let figma-shot(path) = image(path, width: 100%)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/Log In.png"),
    figma-shot("fig/figma/Sign Up.png"),
  ),
  caption: [Figma designs for the authentication flow],
) <fig:figma-auth-flow>

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/figma/Contest Page.png"),
  ),
  caption: [Figma design for the contest detail page],
) <fig:figma-contest-detail>

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/Problem.png"),
    figma-shot("fig/figma/Problem Page.png"),
  ),
  caption: [Figma designs for the problem-solving page (left) and the contest problem list page
  (right)],
) <fig:figma-problem-pages>

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/figma/Submission Page.png"),
  ),
  caption: [Figma design for the submission list page],
) <fig:figma-submission-page>

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/FAQ.png"),
    figma-shot("fig/figma/My Account.png"),
  ),
  caption: [Figma designs for the FAQ page (left) and the profile page (right)],
) <fig:figma-faq-profile>

These designs set the basic page templates later reused across the frontend. The authentication flow
is shown in @fig:figma-auth-flow. The contest detail page is shown in
@fig:figma-contest-detail. The problem-solving page and contest problem list page are shown in
@fig:figma-problem-pages. The submission list page is shown in @fig:figma-submission-page. The FAQ
page and profile page are shown in @fig:figma-faq-profile.

== Layout and Interaction Rationale

The participant interface was designed around four main constraints. Users switch context often.
Contest pages contain dense technical content. Some actions depend on time and contest state. The
system may also be used for long reading sessions.

The frontend uses a stable application frame with persistent navigation. This reduces the cost of
moving between contest pages because users do not need to find the main actions again on every
screen. It also helps users keep one clear view of the full contest workflow.

The contest detail page in @fig:figma-contest-detail keeps the problem list and
clarification area on the same page. These two parts are often used together during a contest. If
they were split too much, users would need more page changes.

The problem-solving page in @fig:figma-problem-pages uses a split layout so that reading and
coding stay close together. Participants often move between the statement, the examples, and the
editor. A split layout makes this easier. It does reduce horizontal space, so the layout has to
stay simple. This choice mainly fits laptop or desktop use during contests. If the statement area
gets too narrow, the layout is less comfortable.

The design also includes theme and font-size options. These are not only visual features. Contest
pages can contain long statements, dense tables, and many clarifications, so users may need a page
that is easier to read on different screens and in different lighting conditions.

These choices also involve trade-offs. A persistent sidebar uses some screen space, but it gives
better navigation across many pages. A split problem layout leaves less horizontal room, but it
fits the read-code cycle better during problem solving.

The basic preference logic is handled in a shared theme provider, which restores the selected mode
and font-size setting from local storage.

#figure(
  kind: raw,
  [
    ```tsx
    const [mode, setMode] = useState<"light" | "dark">(() => {
      const storedTheme = localStorage.getItem("theme")
      return storedTheme === "dark" ? "dark" : "light"
    })

    const [fontSizeMode, setFontSizeMode] = useState<"normal" | "large">(() => {
      const stored = localStorage.getItem("font_size_mode")
      return stored === "large" ? "large" : "normal"
    })

    useEffect(() => {
      window.document.documentElement.style.fontSize =
        fontSizeMode === "large" ? "20px" : "16px"
      localStorage.setItem("font_size_mode", fontSizeMode)
    }, [fontSizeMode])
    ```
  ],
  caption: [Code excerpt showing how theme and font-size preferences are restored],
)

The controls are also shared so that the same interaction can be reused across the frontend.

#figure(
  kind: raw,
  [
    ```tsx
    const toggleTheme = () => {
      setMode((prev) => {
        const next = prev === "light" ? "dark" : "light"
        localStorage.setItem("theme", next)
        return next
      })
    }

    const toggleFontSize = () => {
      setFontSizeMode((prev) => {
        const next = prev === "normal" ? "large" : "normal"
        localStorage.setItem("font_size_mode", next)
        return next
      })
    }
    ```
  ],
  caption: [Code excerpt showing the shared theme and font-size toggle actions],
)

== Frontend Technology Choices

The frontend is a React @react and TypeScript @typescript single-page application built with Vite
@vite. This stack fits the project because the system needs route-based navigation, reusable
components, and steady UI development. React Router @react-router models contest-scoped routes.
Material UI @mui and Emotion @emotion provide a common design base and theme support.

For backend communication, the project uses Axios @axios through a centralized API service layer
with request and response interceptors. Zod @zod is used with TypeScript so that backend payloads
can be checked at runtime, not only described at compile time. This is useful because many
participant pages depend on backend data that can change during development.

The project also uses Monaco Editor @monaco-editor for code submission and React Markdown
@react-markdown with `remark-gfm` and syntax highlighting for problem statements. These tools
support the two main tasks on the participant side: reading technical content and writing code.

These choices also involve trade-offs. Request logic could have been kept inside each page, but
that would make backend changes harder to track and could lead to different error handling on
different pages. TypeScript interfaces alone would also be simpler, but they would not catch bad
live payloads at runtime.

#figure(
  table(
    columns: (1.1fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Technology*], [*Category*], [*Reason for selection*],
    [Vite], [Build tool], [Provides a lightweight development and build pipeline that suits
    iterative frontend work.],
    [React], [UI framework], [Supports reusable components and route-based interfaces for a
    multi-page participant workflow.],
    [TypeScript], [Language], [Improves maintainability in component logic, props, and API-facing
    types.],
    [Material UI], [Component library], [Provides consistent form, dialog, card, and table
    primitives that can be themed across the application.],
    [Emotion], [Styling], [Supports theme-aware styling and integrates naturally with Material UI.],
    [React Router], [Routing], [Models contest-scoped navigation and keeps page transitions
    explicit.],
    [Axios], [HTTP client], [Supports centralized request handling, authentication headers, and
    error interception.],
    [Zod], [Validation], [Checks backend payloads at runtime so integration mismatches can be
    detected earlier.],
    [Monaco Editor], [Code editor], [Provides an in-browser editor suitable for multi-language code
    submission.],
    [React Markdown], [Content rendering], [Renders problem statements and related rich text in a
    structured way.],
  ),
  caption: [Technology stack used in the frontend implementation],
)

The project structure separates pages, reusable components, service modules, and typed schemas.
This became useful later when API changes had to be handled in shared modules instead of many page
components.

#figure(
  image("fig/frontend tech.png", width: 100%),
  caption: [Frontend technology structure used in the implementation],
) <fig:frontend-architecture>
