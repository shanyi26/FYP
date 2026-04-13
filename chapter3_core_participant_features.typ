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

The following route excerpt shows how the main participant pages are connected in the frontend.

#figure(
  kind: raw,
  [
    ```tsx
    <Route path="contest" element={<ContestListPage />} />
    <Route path="contest/:contestId" element={<ContestPage />} />
    <Route
      path="contest/:contestId/problem/:problemId"
      element={<ProblemPage />}
    />
    <Route path="submissions" element={<SubmissionsPage />} />
    <Route
      path="contest/:contestId/submission/:submissionId"
      element={<SubmissionResultPage />}
    />
    <Route path="ranking" element={<RankingPage />} />
    ```
  ],
  caption: [Code excerpt showing the main participant route definitions],
)

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

Part of this implementation is shown below. The editor stores both the selected language and the
current draft locally, so users do not lose work immediately when they switch languages or return
to the same problem.

#figure(
  kind: raw,
  [
    ```tsx
    const getStorageKey = (problemId: string, lang: string) =>
      `code_${problemId}_${lang}`

    const saveCode = (problemId: string, lang: string, code: string) => {
      if (!problemId) return
      localStorage.setItem(getStorageKey(problemId, lang), code)
    }

    const saveLanguage = (problemId: string, lang: string) => {
      if (!problemId) return
      localStorage.setItem(`language_${problemId}`, lang)
    }
    ```
  ],
  caption: [Code excerpt showing how the problem editor stores draft code locally],
)

The submit action is kept in the same component. After the request succeeds, the page goes directly
to the submission result view for that attempt.

#figure(
  kind: raw,
  [
    ```tsx
    const handleSubmit = async () => {
      if (!contestId || !problemId) return
      setIsSubmitting(true)
      setSubmitError(null)
      try {
        const submission = await api.contests.get(contestId).createSubmission({
          problem_id: problemId,
          language,
          code,
        })
        void navigate(
          `/contest/${contestId}/submission/${encodeURIComponent(submission.id)}`
        )
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Failed to submit solution."
        setSubmitError(message)
      } finally {
        setIsSubmitting(false)
      }
    }
    ```
  ],
  caption: [Code excerpt showing the submission action and result-page navigation],
)

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
