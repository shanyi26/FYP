= Introduction

== Background

Online programming contests are widely used in computing education because they bring together
problem solving, time pressure, and automatic judging. They are useful for competitive training,
class activities, selection contests, and regular skills practice. Guides on running online
contests also show that clear rules, reliable timing, and clear participant communication are
important @aswell-online-contest @icpc-rules-info.

Many schools use external contest platforms. This is convenient, but it also means that workflow,
branding, permissions, feature priority, and data ownership are shaped by systems built for general
use. For Nanyang Programming Contests, a school-owned platform is a better fit because it can be
adjusted to local contest formats and school needs.

NanyangOJ is meant to serve that role. At the system level, it supports problem management,
clarifications, scoring rules, and contest operation. In this report, I only focus on one part of
the system: the participant frontend. This frontend takes users from login to contest
participation and supports contest pages, problem pages, submissions, clarifications, rankings, and
account pages.

== Existing Platforms and Design Implications

Before starting the frontend design, I looked at several existing contest platforms, including
Vjudge @vjudge, Kattis @kattis, CMS @cms-official, and Codeforces @codeforces. I was not trying to
copy one platform directly. I mainly wanted to see which strengths were useful and which gaps a
school-owned system still needed to cover.

#figure(
  table(
    columns: (1fr, 1.5fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Platform*], [*Relevant strength*], [*Frontend implication for NanyangOJ*],
    [Vjudge], [Problem aggregation and flexible contest setup], [It shows the value of a practical
    workflow, but the user experience should not depend too much on mixed external sources.],
    [Kattis], [Consistent and polished participant experience], [It shows the value of clear
    navigation and a stable interface across main pages.],
    [CMS], [Strong contest-management flexibility], [It shows that a strong backend still needs a
    participant interface that is easy to use.],
    [Codeforces], [Fast movement between statements, submissions, and standings], [It shows the
    value of quick context switching during a contest.],
  ),
  caption: [Reference platforms and the main lessons they provided for the frontend design],
)

This comparison led to three main points. The participant workflow should be clear for repeated use
in contests and training. Navigation should stay stable when users move between problems,
clarifications, submissions, and rankings. The system should also keep the control of a school-run
deployment instead of following the priorities of a third-party platform.

== Motivation

This work has two main motivations. First, a school-owned contest system gives the school more
control over contest access, interface behavior, branding, and future development. Second, the
participant interface must still work well when backend behavior changes over time.

In this report, the frontend is not treated as just a visual layer. In a contest system, the
frontend has to turn backend state into correct user actions. Contest status, problem access,
submission results, clarifications, and account state all depend on correct routing, request
handling, and response handling.

This is one of the main technical difficulties in the project. A page can look complete and still
behave in the wrong way if its route logic, state assumptions, or expected response fields do not
match the backend contract anymore. So I could not judge the frontend only by how it looked. I
also had to check whether it handled contest state in the right way.

== Project Objectives

The frontend work in this project has five objectives:

- To design a participant interface that presents the main contest workflow in a clear and
  consistent way.
- To implement the main participant pages in React and TypeScript with reusable components and a
  clear routing structure.
- To centralize frontend-backend communication in a shared API service layer.
- To support the main participant tasks of login, contest entry, problem solving, clarifications,
  submission review, ranking access, and profile access.
- To improve frontend correctness by matching routes, requests, and response typing to the current
  backend contract.

The participant workflow covered by these objectives is shown in @fig:participant-workflow.

#figure(
  image("fig/participant-workflow.svg", width: 100%),
  caption: [Participant workflow supported by the frontend],
) <fig:participant-workflow>

== Scope of Contribution

My contribution is focused on the participant frontend of NanyangOJ, not the full online judge
stack. Within this scope, my work includes both design and implementation:

- Designing the participant workflow and shared page patterns in Figma.
- Implementing the main participant pages and their navigation structure.
- Building reusable frontend components and shared layout patterns.
- Connecting the frontend to backend APIs through a centralized service layer.
- Updating the frontend to better match the current backend contract.

The main participant pages covered by the frontend are shown in the following table.

#figure(
  table(
    columns: (1.2fr, 1fr, 2.2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Page*], [*Primary role*], [*Supported user task*],
    [Login and register], [Authentication], [Allow users to access the platform and enter contest
    features securely.],
    [Contest list], [Contest discovery], [Browse available contests and understand contest state
    before joining.],
    [Contest detail], [Contest overview], [Inspect problems, clarifications, and contest-level
    actions in one place.],
    [Clarification panel], [Communication], [Receive jury announcements and submit clarification
    questions during a contest.],
    [Problem page], [Problem solving], [Read the statement, write code, and prepare submissions
    during a contest.],
    [Submission views], [Progress tracking], [Review judging results and inspect previous
    attempts.],
    [Ranking page], [Performance feedback], [View standing information within a contest context.],
    [FAQ and profile], [Support pages], [Access guidance and review account information within the
    same application.],
  ),
  caption: [Main participant-facing pages and their functions],
)

Some important parts of the full platform are outside the scope of this report. These include the
internal judge, problem ingestion from external sources, load-balancing infrastructure, and the
full backend administration workflow. They still matter to the platform, but they are not the main
focus of my work here.
