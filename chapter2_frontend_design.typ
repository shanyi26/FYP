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
information and announcements in one place. The problem page uses a 'lift and right' splited layout for the statement
and the code editor. This helps participants read and solve problems more easily. Submission pages
can show the judging status, score, and submitted code. The FAQ and profile pages
provide guidance and account information in the same general style.

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
