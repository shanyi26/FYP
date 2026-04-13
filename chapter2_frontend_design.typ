= Frontend Design

== UI/UX Design with Figma

Before implementation, I designed the interface in Figma @figma to define the visual
structure and user flow of the platform. This design stage helped establish consistency in spacing,
typography, page hierarchy, and navigation patterns across the application. Common interface
elements such as the sidebar, page containers, cards, and form layouts were planned before coding,
which reduced uncertainty during implementation and made the later React development more direct.

#let figma-shot(path) = image(path, width: 100%)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/Log In.png"),
    figma-shot("fig/figma/Sign Up.png"),
  ),
  caption: [Figma designs for authentication pages],
)

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/figma/Contest Page.png"),
  ),
  caption: [Figma design for the contest overview page],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/Problem.png"),
    figma-shot("fig/figma/Problem Page.png"),
  ),
  caption: [Figma designs for problem list and problem-solving pages],
)

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/figma/Submission Page.png"),
  ),
  caption: [Figma design for the submission page],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/Pass.png"),
    figma-shot("fig/figma/Fail.png"),
  ),
  caption: [Figma designs for submission result feedback],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/figma/FAQ.png"),
    figma-shot("fig/figma/My Account.png"),
  ),
  caption: [Figma designs for supporting participant pages],
)

The contest-related pages were designed around one main workflow. The contest page shows the active
contest together with its problem list and clarification area where participants can see both task
information and announcements in one place. The problem page uses a left-and-right split layout for
the statement and the code editor. This helps participants read and solve problems more easily.
Submission pages can show the judging status, score, and submitted code. The FAQ and profile pages
provide guidance and account information in the same general style.

== Layout and Interaction Rationale

After the initial Figma planning, I had to decide how the participant workflow should feel in real
use. The main goal was to keep the pages clean and make page switching feel stable. Because of
this, the frontend uses one fixed sidebar across the main participant views. Contest, problems,
submissions, and ranking all stay in the same place. Users do not need to find the main actions
again every time the page changes.

The contest page keeps the problem list and clarification area on the same screen. During a
contest, participants often need both at the same time. They may check the problem list, read a
clarification, or send a question to the jury one after another. Putting these parts together cuts
down extra page switching.

The problem page uses a split layout so that the statement and the code editor can be seen
together. Participants often read part of the statement, check a sample, and then go back to their
code. If the statement and editor are too far apart, this becomes slow and repetitive. The split
layout keeps both tasks close to each other.

I also added theme and typography options. The frontend supports light and dark themes, and it also
supports a larger font mode. This helps on dense pages such as problem statements, submission
records, and FAQ content. It also gives users a simpler way to adjust the interface to their own
reading preference.

The basic theme logic is implemented in the shared theme provider. It stores both the color mode
and the font size mode in local storage so the preference stays after refresh.

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

The switch actions are kept simple as well. Both settings are updated from one shared context, so
the same controls can be reused across the frontend.

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

The frontend is implemented as a React @react and TypeScript @typescript single-page application
and built with Vite @vite. React Router is used to define both participant and administrative
routes. Material UI and Emotion provide the main design system, component styling, and theme
support across the interface.
\
For backend communication, the project uses Axios through a centralized API service layer with
request and response interceptors for token handling and error processing. Zod schemas are used
with TypeScript types to validate backend payloads at runtime. This helps reduce hidden integration
mismatches. In specific parts of the frontend, the project also uses Monaco Editor for code
submission and React Markdown with `remark-gfm` and syntax highlighting for rendering problem
content.

#figure(
  table(
    columns: (1.1fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Technology*], [*Category*], [*Purpose in the project*],
    [Vite], [Build tool], [Provides the development server and frontend build pipeline for the React
    application.],
    [React], [UI framework], [Implements page-based interfaces through reusable components and
    supports a consistent participant experience.],
    [TypeScript], [Language], [Adds static typing so frontend logic, props, and API-facing types
    remain easier to maintain.],
    [Material UI], [Component library], [Provides common UI elements such as forms, dialogs, cards,
    and tables with a consistent design base.],
    [Emotion], [Styling], [Supports theme-aware styling and integrates with Material UI for custom
    interface design.],
    [React Router], [Routing], [Defines navigation between contest pages and keeps the participant
    workflow structured.],
    [Axios], [HTTP client], [Handles API requests through a shared service layer with centralized
    authentication and error handling.],
    [Zod], [Validation], [Validates backend responses at runtime to catch schema mismatches early.],
    [Monaco Editor], [Code editor], [Provides the in-browser programming editor used on the problem
    submission page.],
    [React Markdown], [Content rendering], [Renders problem statements and rich text content in the
    frontend interface.],
  ),
  caption: [Technology stack used in the frontend implementation],
)

The project structure separates concerns into pages, reusable components, type definitions, and
service modules. This is particularly useful for a contest platform because many pages depend on the
same authenticated data flow. Instead of embedding fetch logic separately in every component, the
frontend uses a shared API abstraction that exposes contest, authentication, submission, and jury
operations with a consistent interface.

This separation of concerns is shown in Figure 8.

#figure(
  image("fig/frontend tech.png", width: 100%),
  caption: [Frontend technology structure used in the implementation],
) <fig:frontend-architecture>
