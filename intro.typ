= Introduction

== Background

Online programming contests are widely used in computing education to train problem-solving,
algorithmic thinking, and programming fluency. Participants can improve their coding skills through
regular contest participation and gain a clearer understanding of their abilities in a competitive
environment. In practice, however, many schools still depend on external contest platforms. While
these platforms are convenient, they often provide limited control over workflows, branding,
permissions, and feature priorities, which can create friction when the system needs to match local
academic requirements or internal event organization.

This project aims to create a virtual judge system for the Nanyang Programming Contests series. At
the system level, the platform is intended to help judges source contest problems from multiple
platforms, support clarifications during contests, allow customized scoring rules, and provide a
reliable load-balancing mechanism for contest operation. In addition to these organizational
requirements, the system also needs to present a clear and usable participant-facing interface for
contest entry, problem solving, submission tracking, and related contest interactions.

Within this larger system, my work focuses on the frontend implementation for the participant-facing
experience. The frontend is responsible for guiding users from authentication into contests and then
supporting the main participation flow through contest pages, problem pages, clarifications,
submissions, and supporting account-related views.
\
\
\
\
\
\
\
\
\

=== Comparison with Existing Platforms

Before finalizing the design direction, we reviewed several existing programming
contest platforms, such as Vjudge, Kattis, and CMS. Therefore, the NanyangOJ is designed to combine the strengths of these platforms while addressing their limitations. 
\


#heading(level: 4, numbering: none)[Vjudge]

Vjudge is strong in aggregation and flexibility: it connects
problems from many existing online judges and makes it convenient to organize practice sets and
contests from distributed problem sources. This makes it useful for training and fast contest
arrangement, but it also means that part of the overall user experience depends on the external
problem sources that it integrates.
\


#heading(level: 4, numbering: none)[Kattis]

Kattis provides a more unified and polished contest environment. Its interface presents problems,
submissions, standings, scoring, and language support in a highly consistent way, which is valuable
for participants because the workflow is easy to understand and the contest experience is smooth from start to finish. At the same time, Kattis is a mature general-purpose platform whose
structure is designed for broad use cases rather than being tailored specifically to the local
needs, workflows, and ownership requirements of one university.
\


#heading(level: 4, numbering: none)[CMS]

CMS is best understood as a contest management infrastructure. It is designed to
support many different contest types, scoring methods, timing models, and administrative workflows.
This makes CMS powerful from an organizational perspective, but it also highlights that a
technically capable contest system still needs an accessible participant-facing layer if it is to
serve daily school use, internal training, and routine academic events.

From this comparison, the design philosophy of NanyangOJ became clearer. The intended platform
should combine the practical usability of a training-oriented system, the consistency of a polished
contest interface, and the controllability of a school-owned deployment. In other words, the goal
is not simply to replicate an existing platform, but to build a system that is straightforward for
students to use, maintainable for developers to evolve, and adaptable for the school to manage in
terms of contest rules, participant experience, branding, and future feature expansion. This is why
NanyangOJ is positioned as a locally controlled contest platform with a clear participant workflow,
unified frontend behavior, and close alignment between frontend design and backend-supported system
state.
\
\
\

=== Motivation

This project aims to create a school contest platform that can meet the unique academic and competitive needs of the school.
A school-owned system gives more
control over interface design, user management, contest rules, and future feature development. It
also makes it possible to create a more coherent experience for students by aligning the platform
with existing school workflows rather than forcing users to adapt to a third-party system.

From a frontend perspective, this motivation translates into two practical requirements. Firstly, the
platform should provide a clear and consistent participant workflow, so that users can move from
login to contest participation without any confusion. Secondly, the frontend should be maintainable and
closely aligned with backend behavior, because a contest system depends heavily on accurate status
updates, authenticated access, and real-time contest information.

== Project Objectives

The frontend work in this project is guided by the following objectives:

- To design a consistent participant interface for the major contest-related pages.
- To implement the designed interface in React and TypeScript using reusable components and clear
  routing structure.
- To integrate the frontend with backend APIs through a centralized service layer.
- To support the core participant workflow, including authentication, contest entry, problem
  navigation, clarification viewing, submission tracking, ranking display, and profile access.
- To improve frontend correctness by aligning API usage and response handling with the current
  backend implementation.

The overall participant workflow supported by the implemented frontend is summarized in
Figure @fig:participant-workflow.

#figure(
  image("fig/participant-workflow.svg", width: 100%),
  caption: [Participant workflow supported by the frontend],
) <fig:participant-workflow>

== Scope of Contribution

My contribution is centered on the frontend of NanyangOJ, especially the participant view. Based on
the earlier design work in Figma, I implemented or refined the main user-facing pages, including:

- Login and signup pages
- Contest list and contest detail pages
- Problem page with code editor area
- Clarification Page
- Submission history and submission result pages
- FAQ page
- User profile page
- Theme Design

In addition to page implementation, I also worked on the frontend architecture needed to support
these pages, including routing, API abstraction, authentication token handling, shared UI
components, and response validation. In the recent stage of the project, I further improved the
integration between the frontend and the backend by correcting mismatched API routes and replacing a
browser-only contest exit mechanism with a server-backed workflow.

#figure(
  table(
    columns: (1.2fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Page*], [*Primary role*], [*Supported user task*],
    [Login and register], [Authentication], [Allow users to access the platform and enter contest
    features securely.],
    [Contest list], [Contest discovery], [Browse available contests and understand contest status
    before joining.],
    [Contest detail], [Contest overview], [Inspect problems, clarifications, and contest-level
    actions in one place.],
    [Clarification panel], [Communication], [Receive jury announcements and allow participants to
    submit clarification questions during the contest.],
    [Problem page], [Problem solving], [Read the statement, write code, and prepare submissions
    during a contest.],
    [Submission views], [Progress tracking], [Review judging results and inspect previous
    attempts.],
    [Ranking page], [Performance feedback], [View the ranking and performance of individual participant among all contestants in a contest.],
    [FAQ and profile], [Support pages], [Access platform guidance and check personal account
    information.],
  ),
  caption: [Main participant-facing pages and their functions],
)

= Frontend Design

== UI/UX Design with Figma

Before implementation, I designed the participant-facing interface in Figma to define the visual
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
    figma-shot("fig/Contest (1)/Log In.png"),
    figma-shot("fig/Contest (1)/Sign Up.png"),
  ),
  caption: [Figma designs for authentication pages],
)

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/Contest (1)/Contest Page.png"),
  ),
  caption: [Figma design for the contest overview page],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/Contest (1)/Problem.png"),
    figma-shot("fig/Contest (1)/Problem Page.png"),
  ),
  caption: [Figma designs for problem list and problem-solving pages],
)

#figure(
  kind: image,
  grid(
    columns: 1,
    gutter: 0.6cm,
    figma-shot("fig/Contest (1)/Submission Page.png"),
  ),
  caption: [Figma design for the submission page],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/Contest (1)/Pass.png"),
    figma-shot("fig/Contest (1)/Fail.png"),
  ),
  caption: [Figma designs for submission result feedback],
)

#figure(
  kind: image,
  grid(
    columns: 2,
    gutter: 0.6cm,
    figma-shot("fig/Contest (1)/FAQ.png"),
    figma-shot("fig/Contest (1)/My Account.png"),
  ),
  caption: [Figma designs for supporting participant pages],
)

The contest-related pages were designed to support a main workflow. The contest page presents the
active contest together with its problem list and clarification area, so that participants can
access both task information and announcements in one place. The problem page follows a split
layout that separates the statement from the code editor section, allowing participants to read and
solve problems efficiently. Submission pages were designed to make status, score, and submitted
code easy to inspect, while the FAQ and profile pages provide platform guidance and user account
information in a familiar layout.

== Frontend Technology Choices

The frontend is implemented as a React and TypeScript single-page application and built with Vite.
React Router is used to define both participant and administrative routes, while Material UI and
Emotion provide the main design system, component styling, and theme support across the interface.
\
For backend communication, the project uses Axios through a centralized API service layer with
request and response interceptors for token handling and error processing. Zod schemas are used
alongside TypeScript types to validate backend payloads at runtime, which helps reduce hidden
integration mismatches. In feature-specific areas, the frontend also uses Monaco Editor for code
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

This separation of concerns is shown in Figure 8

#figure(
  image("fig/frontend tech.png", width: 100%),
  caption: [Frontend technology structure used in the implementation],
) <fig:frontend-architecture>

= Implementation of Core Participant Features

== Routing and Navigation

The frontend uses React Router to organize the participant workflow into clear page-level routes.
The route `/contest` displays the contest list, `/contest/:contestId` opens the selected contest,
and `/contest/:contestId/problem/:problemId` leads to the corresponding problem page. Additional
routes are used for ranking, submissions, FAQ, and profile pages. This routing structure supports a
coherent participant journey and helps separate the responsibilities of different pages in the
frontend.

Figure @fig:route-structure summarizes the main participant-facing routes. Auxiliary routes such as
password recovery and FAQ question submission are omitted here for clarity.

#figure(
  image("fig/route-structure.svg", width: 100%),
  caption: [Main route structure of the participant-facing frontend],
) <fig:route-structure>

The sidebar and top-level layout provide a consistent navigation frame across the application. This
reduces context switching for users, because the overall page structure stays stable while the main
content changes according to the current task.

The screenshots shown in the following frontend sections use sample data for demonstration. They do
not represent fully connected live contest data, because backend data transmission was still not
fully ready at the time these interface captures were taken.

== Authentication Pages

Before entering contests, participants first interact with the authentication pages. The login page
provides a simple sign-in form with fields for username or email together with password input. On a
successful login, the user is redirected to the application root, which then leads into the main
participant area.

The registration page is designed specifically for NTU users. It collects a username, an NTU email
address, a password, and a confirmation password. The form performs frontend validation on empty
fields, email format, password rules, and password confirmation, and it also shows a password
strength indicator during input. After successful registration, the user is redirected to the login
page to continue with authentication.

Users are expected to register with an NTU student email address, using the supported NTU email
domains provided by the registration form. Before a user logs in successfully, contest data and
other protected participant content are not available through authenticated requests. If the
frontend detects an invalid or missing login state while requesting protected data, it redirects the
user back to the login page.

#figure(
  kind: image,
  image("fig/signuplogin/sign up1.jpeg", width: 100%),
  caption: [Login page],
)

#figure(
  kind: image,
  image("fig/signuplogin/sign up2.jpeg", width: 100%),
  caption: [Sign up page],
)

In addition to these main entry pages, the router also includes password-recovery routes. Although
they are not part of the core contest workflow, they help complete the account access flow for the
frontend.

== Contest List and Contest Detail Pages

The contest list page presents the contests currently available to participants. It retrieves
contest data through the centralized API layer and renders each entry with its title, start time,
end time, and status. To make contest timing easier to understand, the page computes live countdown
labels and status indicators such as upcoming, ongoing, ended, or exited. It also supports the
contest join flow through a password dialog, so participants must enter the correct contest password
before they can enter the selected contest.

The contest detail page fetches contest problems and visible clarifications using the contest ID
from the current route. The page combines these data sources into a single view so that participants
can review problems and contest announcements without leaving the contest context. It also supports
submitting clarification questions, including optional problem-specific questions, and updates the
clarification list dynamically when new information is received from the contest stream. In
addition, the contest exit flow is confirmed through a dialog, and once a participant leaves the
contest, the interface reflects that the contest can no longer be re-entered.

#figure(
  kind: image,
  image("fig/contest page/contest1.png", width: 100%),
  caption: [Show all the contests available to participants],
)

#figure(
  kind: image,
  image("fig/contest page/contest2.png", width: 100%),
  caption: [Password dialog shown when a participant joins a contest],
)

#figure(
  kind: image,
  image("fig/contest page/contest5.png", width: 100%),
  caption: [Contest view showing all problems and the clarification section],
)

#figure(
  kind: image,
  image("fig/contest page/contest3.png", width: 100%),
  caption: [Confirmation page for ending a contest],
)

#figure(
  kind: image,
  image("fig/contest page/contest4.png", width: 100%),
  caption: [Contest page after ending the contest, where re-entry is no longer allowed],
)

The contest header component displays core contest metadata such as the contest title, start time,
and end time. It also provides contest-level actions, including an exit flow that sends a leave
request to the backend before returning the participant to the contest list.

== Problem Page

The problem page is implemented as a contest-scoped view that reads both `contestId` and
`problemId` from the route before requesting the corresponding problem data from the backend. After
the data is loaded, the page constructs a structured presentation from the returned fields. The
problem description is rendered as a main content section, and any sample inputs and outputs
received from the API are grouped into a dedicated sample section so that participants can inspect
examples without leaving the page.

The header of the page displays the problem title together with its time limit and memory limit.
Below the statement, the page includes an integrated code editor that supports multiple languages,
including C, C++, Java, Python, and Go. The selected language and draft code are stored locally per
problem, so the participant can switch languages or return to the same problem without immediately
losing work. When the user submits code, the page sends the solution through the contest submission
API and then navigates directly to the corresponding submission result page. In jury or root mode,
the same page also exposes editing controls for adding, reordering, updating, and deleting problem
sections, so the page can support both participation and content maintenance.

#figure(
  kind: image,
  image("fig/problem/problem4.png", width: 100%),
  caption: [Problem page],
)

#figure(
  kind: image,
  image("fig/problem/problem1.jpeg", width: 100%),
  caption: [Detailed view of a selected problem],
)

#figure(
  kind: image,
  image("fig/problem/problem2.png", width: 100%),
  caption: [Code editor],
)

#figure(
  kind: image,
  image("fig/problem/problem3.png", width: 100%),
  caption: [Result page],
)

== Submission Views

Submission-related pages provide visibility into user progress during the contest. The submissions
page first loads the active contests and then fetches the submissions for the selected contest. It
shows the submission records in a table view. The page also includes filtering functions, allowing
the user to narrow the list by problem, user, language, and judging status. From the submission
page shown in Figure 21, the user can click the `Review` button to open the result page shown in
Figure 20.

On the result page, the user can immediately see whether the solution passed or failed. The page
also provides two follow-up actions: `Try Again`, which returns the user to the corresponding
problem page, and `Back to Submissions`, which exits the result view and returns to the submission
list.

#figure(
  kind: image,
  image("fig/submission/submission1.png", width: 100%),
  caption: [Submission page],
)

== FAQ and Profile Pages

Beyond the core contest workflow, the participant interface includes supporting pages that improve
usability. The FAQ page provides quick access to platform guidance and common questions. It also includes an `Ask a Question` entry point, which allows participants
to write and submit a question to the jury.

The profile page allows users to review their account information within the same unified interface
style used by the rest of the application. In addition to username and email, the profile page also
adds fields for matric number and phone number. These fields are useful for practical contest
administration, because they make it easier to contact participants and arrange prize distribution
when necessary.

Although these pages serve different purposes, they share a common design language and are
implemented through the same routing and layout system. This consistency is important because it
makes the platform feel like a single integrated product rather than a collection of unrelated
screens.

#figure(
  kind: image,
  image("fig/faq and profile/FAQ.png", width: 100%),
  caption: [FAQ page],
)

#figure(
  kind: image,
  image("fig/faq and profile/profile page.png", width: 100%),
  caption: [Profile page],
)

= API Integration and Recent Improvements

== Centralized API Service Layer

All frontend API communication is handled through a centralized service module. This module defines
request helpers, authentication handling, and typed interfaces for different backend endpoints. An
authorization token stored after login is automatically attached to outgoing requests, which avoids
duplicating token logic in each page component. Zod schemas are used to validate server responses at
runtime, helping the frontend detect unexpected payloads early.

This architecture improves separation of concerns. Page components such as the contest list page and
contest detail page can request the data they need through high-level methods, while lower-level
details such as path formatting, HTTP methods, and validation are hidden inside the shared service
layer. The same structure also makes it easier to maintain a mock API mode for frontend development
and testing.

#figure(
  table(
    columns: (1.2fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Module*], [*Responsibility*], [*Role in the frontend*],
    [`api.ts`], [API selection], [Chooses between the mock API and the server API so the frontend
    can work in different development modes.],
    [`auth` module], [Authentication and identity], [Handles login, registration, and current-user
    retrieval through the `/me` endpoint and related auth requests.],
    [`contests` module], [Contest operations], [Provides contest metadata, participant actions,
    problems, clarifications, and submissions through grouped contest methods.],
    [`system` module], [System status], [Exposes jury-oriented system status data needed for
    administrative monitoring features.],
    [`types/*` schemas], [Validation and typing], [Define TypeScript and Zod-based data structures
    so backend payloads can be parsed and checked consistently.],
  ),
  caption: [Main API and service-layer modules used by the frontend],
)

== Alignment with the Current Backend

In the latest round of work, I focused on aligning the frontend implementation with the current
backend contract. One issue was that the frontend user profile request used an outdated path. This
was corrected by changing the request to the backend's current `/me` endpoint. Contest-related
frontend types were also updated to reflect actual backend fields, including `left_contest` and the
`participants` response structure.

These changes are important because an online contest system depends on accurate state handling.
When frontend routes or types drift away from the backend, the interface may still render but the
behavior becomes unreliable. By aligning the API layer with the current backend, the frontend now
handles contest and profile data more correctly and with less hidden inconsistency.

== Improvement of the Contest Exit Flow

Another important improvement was the contest exit workflow. Earlier frontend logic relied on local
browser storage to remember whether a participant had exited a contest. This was only a local state
approximation and could easily become inconsistent after a refresh, a device change, or a backend
state update.

The contest exit flow was therefore revised to use the backend's leave endpoint directly. The
frontend now sends a real contest leave request and uses the backend's `left_contest` field as the
source of truth when rendering contest status. On the contest list page, a contest that has been
left is shown with an `Exited` state and the join action is disabled accordingly. This change makes
the frontend behavior consistent with backend data and better reflects the actual contest
participation state of the user.

== Validation and Stability

After the API alignment work, the updated frontend was verified through local build and targeted lint
checks on the affected files. The revised pages and service layer compiled successfully, indicating
that the integration changes were consistent with the current frontend codebase. This validation is
especially important in a typed React project because interface-level mismatches can otherwise
propagate across multiple pages.

= Conclusion

This project contributes the participant-facing frontend of NanyangOJ, a school-owned contest
platform designed to support local academic and competitive programming activities. My work covered
both design and implementation: I first defined the participant interface in Figma, and then
implemented the main pages and frontend architecture needed to support the contest workflow in
React.

The recent improvements further strengthened the reliability of the frontend by aligning API usage
with the current backend and by replacing local-only contest exit logic with a proper backend-driven
process. These changes move the platform closer to a stable and maintainable state for real usage.
Future work can continue to expand backend-supported features and further connect currently
simplified pages, but the implemented frontend already provides a solid foundation for a coherent
school-managed online contest experience.
