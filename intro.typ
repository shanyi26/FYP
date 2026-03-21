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

This separation of concerns is shown in Figure 8.

#figure(
  image("fig/frontend tech.png", width: 100%),
  caption: [Frontend technology structure used in the implementation],
) <fig:frontend-architecture>

= Implementation of Core Participant Features

== Routing and Navigation

The frontend uses React Router to organize the main participant flow into page-level routes. The
route `/contest` shows the contest list, `/contest/:contestId` opens a selected contest, and
`/contest/:contestId/problem/:problemId` leads to the corresponding problem page. Separate routes
are also used for ranking, submissions, FAQ, and profile pages. This makes the overall structure
easier to follow and keeps each page focused on a clear role.

Figure @fig:route-structure summarizes the main participant-facing routes. Auxiliary routes such as
password recovery and FAQ question submission are omitted here for clarity.

#figure(
  image("fig/route-structure.svg", width: 100%),
  caption: [Main route structure of the participant-facing frontend],
) <fig:route-structure>

The sidebar and top-level layout stay consistent across the application. As a result, users can
move between pages without feeling that they have entered a different part of the system each time.

From the implementation side, this routing structure also keeps the frontend easier to manage. Each
page handles its own task, but still fits into one continuous workflow. A participant can move from
contest discovery to problem solving and then to submission review without leaving the same
application frame.

The screenshots shown in the following frontend sections use sample data for demonstration. They do
not represent fully connected live contest data, because backend data transmission was still not
fully ready at the time these interface captures were taken.

== Participant Workflow

From the participant's point of view, the frontend should feel like one continuous flow rather than
a set of unrelated pages. A typical user journey starts with authentication, where the user logs in
or registers with an NTU email account. After entering the system, the participant can browse the
available contests, check their timing and status, and join the intended contest if access is
allowed.

Once inside a contest, the participant can move between the contest overview and the problem pages.
The contest page acts as a central hub by showing the available problems together with the
clarification area, while the problem page provides the space for reading the statement, writing
code, and preparing a submission. After a solution is submitted, the user can inspect the judging
result and, if necessary, return to the same problem for another attempt.

In practice, this workflow is not strictly linear. During a contest, participants often move back
and forth between problems, submissions, rankings, and clarification messages. For that reason, the
frontend was designed to keep navigation stable and predictable, so that users can switch tasks
without losing their sense of context.

== Reusable Components and Shared Layout

Another part of the frontend work was to keep the implementation reusable instead of building every
page from scratch. Although the participant-facing pages serve different purposes, many of them
still need the same basic structure, such as a stable sidebar layout, page headers, card
containers, form controls, dialogs, and status areas. Reusing these patterns made the frontend
easier to extend and also helped the interface stay visually consistent.

This matters because the system contains several pages that differ in content but feel similar in
use. Contest pages, problem pages, submission pages, FAQ, and profile pages all sit inside the same
application frame. Shared components and layout patterns reduce the chance that these pages drift
into unrelated designs over time.

Reusable components also reduce duplication. When a visual or behavioral improvement is made to a
shared component, the same improvement can appear across multiple pages instead of being
reimplemented repeatedly.

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

These pages matter because they are the user's first contact with the platform. If login and
registration already feel confusing, the rest of the contest flow becomes harder to trust. For that
reason, the authentication pages were treated not only as security requirements, but also as part
of the general usability of the frontend.

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

These two contest pages work together as the bridge between general browsing and active
participation. The list page helps users understand what is available and what state each contest is
in, while the detail page shifts attention to the actual contest tasks. Keeping these roles
separate makes the overall flow easier to understand.

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

This page is one of the most important parts of the participant workflow because it brings reading,
coding, and submission preparation into the same place. Instead of forcing the user to move between
separate screens for the statement and the editor, the frontend keeps these tasks close together.
In practice, the page functions more like a working area than a static problem description.

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
list, the user can click the `Review` button to open the corresponding result page for a selected
attempt.

On the result page, the user can immediately see whether the solution passed or failed. The page
also provides two follow-up actions: `Try Again`, which returns the user to the corresponding
problem page, and `Back to Submissions`, which exits the result view and returns to the submission
list.

These submission views are useful not only as records of past attempts, but also as part of the
feedback loop during a contest. After submitting code, the participant can quickly inspect the
result, decide whether another attempt is needed, and return to the problem with minimal
interruption. This matches the iterative nature of programming contests, where users often submit,
review, revise, and submit again.

#figure(
  kind: image,
  image("fig/submission/submission1.png", width: 100%),
  caption: [Submission page],
)

== FAQ and Profile Pages

Beyond the core contest workflow, the participant interface also includes supporting pages. The FAQ
page provides quick access to platform guidance and common questions. It also includes an `Ask a
Question` entry point, which allows participants to write and submit a question to the jury.

The profile page allows users to review their account information within the same unified interface
style used by the rest of the application. In addition to username and email, the profile page also
adds fields for matric number and phone number. These fields are useful for practical contest
administration, because they make it easier to contact participants and arrange prize distribution
when necessary.

Although these pages serve different purposes, they share a common design language and are
implemented through the same routing and layout system. This consistency is important because it
makes the platform feel like a single integrated product rather than a collection of unrelated
screens.

Including these supporting pages makes the platform feel more complete. A contest system is not used
only for solving problems, but also for handling practical questions, account information, and
general guidance. Keeping these functions inside the same frontend environment means participants do
not need to leave the platform to deal with common issues.

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

== Frontend Beautification

Besides implementing the core functions and connecting the frontend to the backend, I also spent
time improving the visual presentation of the interface. These changes were not meant to add new
functions, but to make the platform easier to read, more consistent across pages, and more
comfortable to use during a contest.

=== Theme and Typography

One part of this work was theme and typography support. The frontend allows users to switch between
light and dark themes, which makes the interface more flexible under different viewing conditions.
I also added adjustable text sizing so that dense pages are easier to read. This is especially
helpful on pages such as problem statements, submission records, and FAQ content.

=== Uniform Page Structure

Another improvement was the more consistent use of card-based layouts and shared page structure.
Instead of letting each page drift into its own visual style, I tried to keep a common arrangement
for headers, content areas, metadata blocks, and supporting controls. This makes the contest pages,
problem pages, submission pages, FAQ page, and profile page feel more related to one another.

=== Consistency and User Experience

Although these changes are mostly visual, they still matter in practice. In a contest system,
participants move frequently between different pages, so an inconsistent layout can make the
experience feel fragmented even when the functions work correctly. A more uniform interface makes
the page hierarchy clearer and the overall workflow smoother.

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

From an implementation perspective, this service layer also makes the frontend easier to maintain as
the project grows. When an API path or response shape changes, the adjustment can be handled in a
small number of shared modules instead of being scattered across many pages. This is particularly
useful in a contest system, because many views depend on related data such as contest metadata,
participant state, problem information, and submission records. A centralized API layer therefore
helps keep the frontend codebase more organized and reduces the risk of inconsistent request logic
between pages.

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

These changes matter because an online contest system depends on accurate state handling. When
frontend routes or types drift away from the backend, the interface may still render, but the
behavior becomes unreliable. Aligning the API layer with the current backend reduced this kind of
hidden inconsistency.

This alignment work was not limited to a single page. It required checking how the frontend
interpreted backend data across several participant-facing features, including profile information,
contest state, and contest-related lists. Doing this reduced the gap between what the frontend
assumed and what the backend actually returned.

== Validation and Stability

After these integration and interface changes, the frontend was checked through local build and
type-level validation to confirm that the updated code remained consistent. This step is important
in a React and TypeScript project because changes in one shared type, API method, or page-level
prop can easily affect several other parts of the application.

The validation process was not only about confirming that the project could still compile. It also
helped check whether the updated pages remained compatible with the shared service layer, routing
structure, and reusable components already used across the frontend. In this kind of project,
stability means that improvements should not create new inconsistencies elsewhere in the user flow.

This is especially relevant for a contest platform, where users move quickly between authentication,
contest pages, problem pages, submissions, and supporting views. If one part of the frontend falls
out of sync with another, the result may not always be an obvious crash, but rather a confusing
workflow or incorrect interface state. For that reason, validation and stability checking formed an
important part of the frontend work alongside feature implementation and visual refinement.

= Conclusion

This project focuses on the participant-facing frontend of NanyangOJ, a school-owned online judge
intended to support local programming contests and training activities. My work covered both design
and implementation. I first planned the main interface structure in Figma, and then implemented the
core participant pages in React and TypeScript, including authentication, contest access, problem
solving, submissions, FAQ, and profile-related views.

Beyond page implementation, the project also involved building the frontend structure needed to
support these functions in a maintainable way. This included routing, shared components, theme and
layout consistency, and a centralized API layer for communicating with the backend. In the later
stages of the work, I also focused on improving frontend reliability by aligning requests and data
handling more closely with the current backend behavior.

Taken together, these parts form a usable foundation for the participant side of the platform. The
system is still not fully complete, and some features can be extended further in future work,
especially as backend support becomes more mature. Even so, the current frontend already shows how
the platform can provide a more coherent and school-controlled contest experience for students.
