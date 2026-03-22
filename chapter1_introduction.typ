= Introduction

== Background

Online programming contests are commonly used in computing education. They help students practise
problem solving, algorithmic thinking, and programming skills. By joining contests regularly,
participants can improve their coding ability and better understand their level in a competitive
setting. However, many schools still rely on external contest platforms. These platforms are
convenient, but they often give limited control over workflow, branding, permissions, and feature
priority. This can be a problem when the system needs to match local academic or organizational
needs.

Practical guidance on running online contests also shows that clear workflows, rules, timing, and
participant communication matter a lot for the overall contest experience @aswell-online-contest.

This project aims to create a virtual judge system for the Nanyang Programming Contests series. At
the system level, the platform is meant to help judges collect contest problems from different
sources, support clarifications during contests, allow custom scoring rules, and provide reliable
load balancing. At the same time, the system also needs a clear participant-facing interface for
joining contests, solving problems, checking submissions, and handling other contest actions.

Within this project, my work focuses on the frontend implementation for the participant-facing
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

Before deciding the design direction, we looked at several existing contest platforms, such as
Vjudge @vjudge, Kattis @kattis, and CMS @cms. NanyangOJ was then planned to keep some of their
strengths while avoiding some of their limitations.
\


#heading(level: 4, numbering: none)[Vjudge]

Vjudge @vjudge is strong in aggregation and flexibility: it connects
problems from many existing online judges and makes it convenient to organize practice sets and
contests from distributed problem sources. This makes it useful for training and fast contest
arrangement, but it also means that part of the overall user experience depends on the external
problem sources that it integrates.
\


#heading(level: 4, numbering: none)[Kattis]

Kattis @kattis provides a more unified and polished contest environment. Its interface presents problems,
submissions, standings, scoring, and language support in a highly consistent way, which is valuable
for participants because the workflow is easy to understand and the contest experience is smooth
from start to finish. At the same time, Kattis is a mature general-purpose platform whose
structure is designed for broad use cases rather than being tailored specifically to the local
needs, workflows, and ownership requirements of one university.
\


#heading(level: 4, numbering: none)[CMS]

CMS @cms is a contest management infrastructure. It is designed to
support many different contest types, scoring methods, timing models, and administrative workflows.
This makes CMS powerful from an organizational perspective, but it also highlights that a
technically capable contest system still needs an accessible participant-facing layer if it is to
serve daily school use, internal training, and routine academic events.

After this comparison, the direction of NanyangOJ became clearer. The platform should combine the
practical usability of a training system, the consistency of a polished contest interface, and the
control of a school-owned deployment. The aim is not simply to copy an existing platform. The aim
is to build a system that is easy for students to use, manageable for developers, and flexible
enough for the school to adjust in the future.
\
\
\

=== Motivation

This project aims to create a school contest platform that can meet the academic and competitive
needs of the school. A school-owned system gives more
control over interface design, user management, contest rules, and future feature development. It
also makes it possible to create a more coherent experience for students by aligning the platform
with existing school workflows rather than forcing users to adapt to a third-party system.

From the frontend side, this leads to two practical needs. First, the platform should provide a
clear and consistent participant workflow, so users can move from login to contest participation
without confusion. Second, the frontend should be maintainable and closely aligned with backend
behavior, because a contest system depends on correct status updates, authenticated access, and
real-time contest information.

== Project Objectives

The frontend work in this project follows these objectives:

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
components, and response validation. In the later stage of the project, I also improved the
integration between the frontend and the backend by correcting API mismatches and improving how the
frontend handled contest-related state.

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
