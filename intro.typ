= Introduction

== Background

Online programming contests are widely used in computing education to train problem-solving,
algorithmic thinking, and programming fluency. Participant are welcomed to improve their coding skills in contests and get better knowledge of their abilities among all the competitors. In practice, many schools rely on external contest
platforms, which may be convenient to use but offer limited control over contest workflows,
branding, permissions, and feature priorities. For a university setting, this creates friction when
the platform needs to match local teaching requirements or internal event organization.

NanyangOJ is developed as a school-owned online judge and contest platform. The goal is not only to
provide a place for students to submit code, but also to support the full contest experience,
including joining contests, reading problems, viewing clarifications, tracking submissions, and
checking rankings. Within this larger system, my work focuses on the frontend implementation for
the participant-facing experience.

=== Comparison with Existing Platforms

Before finalizing the design direction, we reviewed several existing programming
contest platforms, such as Vjudge, Kattis, and CMS. Therefore, the NanyangOJ is designed to combine the strengths of these platforms while addressing their limitations. 

Vjudge: Vjudge is strong in aggregation and flexibility: it connects
problems from many existing online judges and makes it convenient to organize practice sets and
contests from distributed problem sources. This makes it useful for training and fast contest
arrangement, but it also means that part of the overall user experience depends on the external
problem sources that it integrates.

Kattis:Kattis provides a more unified and polished contest environment. Its interface presents problems,
submissions, standings, scoring, and language support in a highly consistent way, which is valuable
for participants because the workflow is easy to understand and the contest experience is smooth from start to finish. At the same time, Kattis is a mature general-purpose platform whose
structure is designed for broad use cases rather than being tailored specifically to the local
needs, workflows, and ownership requirements of one university.

CMS: CMS is best understood as a contest management infrastructure. It is designed to
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
- Submission history and submission result pages
- Ranking page
- FAQ page
- User profile page

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
    [Problem page], [Problem solving], [Read the statement, write code, and prepare submissions
    during a contest.],
    [Submission views], [Progress tracking], [Review judging results and inspect previous
    attempts.],
    [Ranking, FAQ, profile], [Support pages], [Monitor standings, access guidance, and check
    personal account information.],
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

The contest-related pages were designed to support a focused workflow. The contest page presents the
active contest together with its problem list and clarification area, so that participants can
access both task information and announcements in one place. The problem page follows a split
layout that separates the statement from the code editor section, allowing participants to read and
solve problems efficiently. Submission pages were designed to make status, score, and submitted
code easy to inspect, while the ranking and profile pages provide contest feedback and user account
information in a familiar layout.

== Frontend Technology Choices

The frontend is implemented with React and TypeScript. React Router is used to define navigation
between pages, while Material UI provides a consistent component base for layout, forms, dialogs,
and tables. The project also uses a centralized service layer for API access and Zod schemas for
runtime validation of backend responses. This combination improves maintainability because the page
components can focus on interaction and presentation, while request logic and response parsing are
handled in a single place.

#figure(
  table(
    columns: (1.1fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Technology*], [*Category*], [*Purpose in the project*],
    [React], [UI framework], [Implements page-based interfaces through reusable components and
    supports a consistent participant experience.],
    [TypeScript], [Language], [Adds static typing so frontend logic, props, and API-facing types
    remain easier to maintain.],
    [Material UI], [Component library], [Provides common UI elements such as forms, dialogs, cards,
    and tables with a consistent design base.],
    [React Router], [Routing], [Defines navigation between contest pages and keeps the participant
    workflow structured.],
    [Zod], [Validation], [Validates backend responses at runtime to catch schema mismatches early.],
  ),
  caption: [Technology stack used in the frontend implementation],
)

The project structure separates concerns into pages, reusable components, type definitions, and
service modules. This is particularly useful for a contest platform because many pages depend on the
same authenticated data flow. Instead of embedding fetch logic separately in every component, the
frontend uses a shared API abstraction that exposes contest, authentication, submission, and jury
operations with a consistent interface.

This separation of concerns is shown in Figure @fig:frontend-architecture.

#figure(
  image("fig/frontend-architecture.svg", width: 100%),
  caption: [High-level frontend architecture and its relationship with the backend],
) <fig:frontend-architecture>

= Implementation of Core Participant Features

== Routing and Navigation

The main participant routes are defined in the application router. The route `/contest` leads to
the contest list page, `/contest/:contestId` opens the contest detail page, and
`/contest/:contestId/problem/:problemId` leads to an individual problem page. Additional routes are
defined for ranking, submissions, FAQ, and profile. This route structure mirrors the intended
contest workflow and helps keep page responsibilities clear.

Figure @fig:route-structure illustrates the main route relationships in the participant-facing
frontend.

#figure(
  image("fig/route-structure.svg", width: 100%),
  caption: [Main route structure of the participant-facing frontend],
) <fig:route-structure>

The sidebar and top-level layout provide a consistent navigation frame across the application. This
reduces context switching for users, because the overall page structure stays stable while the main
content changes according to the current task.

== Contest List and Contest Detail Pages

The contest list page is responsible for presenting active and upcoming contests. It retrieves
contest data from the centralized API layer and renders each contest with its title, timing
information, and current status. To make contest timing easier to understand, the page computes
countdown labels such as whether a contest is upcoming, ongoing, or ended. This helps users quickly
decide which contest they can enter.

The contest detail page fetches contest problems and visible clarifications using the contest ID
from the current route. The page combines these data sources into a single view so that participants
can review problems and contest announcements without leaving the contest context. It also supports
submitting clarification questions and updates the clarification list dynamically when new
information is received from the server stream.

The contest header component displays core contest metadata such as title and timing information. It
also provides contest-level actions, including the contest exit flow that was improved in the latest
revision of the frontend.

== Problem Solving and Submission Views

The problem page is designed to support direct contest participation. It presents the problem
statement together with an editor area where participants can prepare and submit solutions. This
layout reduces unnecessary navigation and keeps the relevant information on the same screen.

Submission-related pages provide visibility into user progress during the contest. Participants can
review previous submissions, inspect individual submission results, and check judging outcomes. This
feedback loop is important in a contest environment because users often iterate on solutions and
need to understand the status of each attempt clearly.

== Ranking, FAQ, and Profile Pages

Beyond the core contest workflow, the participant interface includes supporting pages that improve
usability. The ranking page presents standings information so that participants can monitor their
relative performance. The FAQ page provides quick access to platform guidance and common questions.
The profile page allows users to review their account information within the same unified interface
style used by the rest of the application.

Although these pages serve different purposes, they share a common design language and are
implemented through the same routing and layout system. This consistency is important because it
makes the platform feel like a single integrated product rather than a collection of unrelated
screens.

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
    problems, clarifications, submissions, and ranking access through grouped contest methods.],
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
