= Implementation of Core Participant Features

== Routing and Navigation

The frontend uses React Router to organize the participant flow into clear route-level tasks. Users
start from contest discovery, enter a contest, open a problem, and then move to submission review
or other supporting views. This route structure is easier to manage than putting too much behavior
inside only a few large pages.

@fig:route-structure summarizes the main participant-facing routes. Auxiliary routes such as
password recovery and FAQ question submission are omitted for clarity.

#figure(
  image("fig/route-structure.svg", width: 100%),
  caption: [Main route structure of the participant-facing frontend],
) <fig:route-structure>

The routing design also keeps a stable application frame. The sidebar and top-level layout stay the
same while the route-specific content changes. This is useful in a contest because users often move
quickly between problems, submissions, and contest information.

The following route excerpt shows how the core participant pages are connected.

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

The screenshots used in this chapter are shown in @fig:login-page, @fig:register-page,
@fig:contest-list-page, @fig:contest-password-dialog, @fig:contest-detail-page,
@fig:problem-page, @fig:submission-result-page, @fig:submission-list-page, @fig:faq-page, and
@fig:profile-page. Some were captured
while parts of the backend were still being finalized, so they show the implemented frontend flow
rather than a fully populated live contest environment.

== Participant Workflow

From the participant's point of view, the frontend should feel like one continuous process. A
typical user starts with login or registration, then browses contests, enters a contest, solves
problems, reads clarifications, and reviews submissions.

This workflow is not fully linear. Participants may go back to the contest detail page
(@fig:contest-detail-page), open another problem page (@fig:problem-page), check the result page
(@fig:submission-result-page), and return to the editor many times. Because of this,
route structure, shared layout, and page roles were treated as part of the system design, not only
as UI choices.

This also makes the project different from a normal content website. In a contest system, state
depends on time, permissions, and recent actions. A participant may be able to enter a contest at
one moment and lose access after leaving it.

== Reusable Components and Shared Layout

One important implementation decision was to avoid building every page separately. Many
participant-facing pages need the same basic elements: a stable sidebar, page headers, card
containers, form controls, dialogs, loading states, and error states. Reusing these patterns
reduced duplication and made later updates easier.

This also improved consistency. If shared components handle common actions such as dialogs and
status display, users do not need to learn a different pattern on each page. It also made later
spacing and layout changes easier to apply.

Another option was faster page-by-page implementation with more local styling and local logic. That
might have been quicker at the start, but it would have made later alignment work harder when
several pages had to change in the same way.

== Authentication Pages

The authentication pages, shown in @fig:login-page and @fig:register-page, are the user's first
entry point, so they were treated as part of the overall frontend usability. The login page
(@fig:login-page) provides a simple sign-in form. The registration page (@fig:register-page) is
for NTU users and validates username, NTU email format, password rules, and
password confirmation before submission.

This validation helps in two ways. It improves the form experience by catching obvious invalid
input early. It also reduces unnecessary backend requests for cases that can already be checked on
the client side.

#figure(
  kind: image,
  image("fig/signuplogin/sign up1.jpeg", width: 100%),
  caption: [Implemented login page],
) <fig:login-page>

#figure(
  kind: image,
  image("fig/signuplogin/sign up2.jpeg", width: 100%),
  caption: [Implemented registration page],
) <fig:register-page>

After a successful login, the user enters the main application flow. If a protected request later
finds an invalid or missing authenticated state, the frontend sends the user back to the login
page.

== Contest List and Contest Detail Pages

The contest list page (@fig:contest-list-page) connects authentication with active
participation. It loads contest data from the API layer and shows each contest with its title,
timing information, and current state. Countdown labels and state indicators such as upcoming,
ongoing, ended, or exited help users judge when and how to enter a contest.

The contest join flow uses a password dialog (@fig:contest-password-dialog) because some
contests should not be entered directly from the list view. After the user joins a contest, the
contest detail page (@fig:contest-detail-page) becomes the main work area. It combines the
problem list and the clarification area on the same page.

This arrangement reduces extra page changes during the contest. Users often move between the
problem list and clarification updates, so keeping them together is more practical.

The contest detail page (@fig:contest-detail-page) also shows one of the main
frontend-backend integration difficulties. The frontend has to read not only contest metadata, but
also participation state, such as whether the user has already left the contest and which actions
should still be shown.

#figure(
  kind: image,
  image("fig/contest page/contest1.png", width: 100%),
  caption: [Contest list page showing available contests and their state],
) <fig:contest-list-page>

#figure(
  kind: image,
  image("fig/contest page/contest2.png", width: 100%),
  caption: [Password dialog used during contest entry],
) <fig:contest-password-dialog>

#figure(
  kind: image,
  image("fig/contest page/contest5.png", width: 100%),
  caption: [Contest detail page combining problem access and clarifications],
) <fig:contest-detail-page>

The contest header in the contest detail page (@fig:contest-detail-page) shows the title,
start time, end time, and contest-level actions such as the exit flow.

== Problem Page

The problem page (@fig:problem-page) is the most important participant-facing page because
it brings together reading, coding, and submission preparation. The page reads both `contestId`
and `problemId` from the route, requests the problem from the backend, and renders the statement,
constraints, examples, and code editor.

The problem page (@fig:problem-page) was designed to keep reading and action close together.
Instead of sending the user to a separate submission screen right away, the editor stays next to
the statement. The page supports multiple programming languages, and the selected language and
draft code are stored locally for each problem.

This local persistence is useful because participants may switch languages, leave the page for a
moment, or refresh the browser. A simpler design could keep drafts only in component state, but
that would make the editing session fragile. Local storage adds some extra state logic, but keeping
user work was more important.

Part of this logic is shown below.

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
  caption: [Code excerpt showing local draft persistence on the problem page],
)

The submit action is handled on the same page (@fig:problem-page). After a successful
request, the frontend goes straight to the result view for the new submission
(@fig:submission-result-page).

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
  caption: [Code excerpt showing submission handling and result-page navigation],
)

#figure(
  kind: image,
  image("fig/problem/problem4.png", width: 100%),
  caption: [Implemented problem-solving view],
) <fig:problem-page>

#figure(
  kind: image,
  image("fig/problem/problem3.png", width: 100%),
  caption: [Submission result page reached directly from problem submission],
) <fig:submission-result-page>

In jury or root mode, the same problem page (@fig:problem-page) also shows editing controls
for content maintenance. This means the route has to handle role-sensitive behavior as well as
normal participant behavior.

The problem page (@fig:problem-page) is also a clear example of frontend-backend coupling.
The contest ID, problem ID, problem payload, language handling, and submission endpoint all need to
match. If one of them does not match, the page may still look fine while the solve-and-submit flow
breaks.

== Submission Views

Submission pages, shown in @fig:submission-list-page and @fig:submission-result-page,
form the feedback loop of the participant workflow. The submissions page
(@fig:submission-list-page) loads contest-scoped submission data and shows it in a table with
filters for problem, user, language, and status.

The result page (@fig:submission-result-page) turns a submission record into a clear next
step. Users can review the outcome, try again, or go back to the submission list page
(@fig:submission-list-page). This fits the way contest users usually work: submit, check, revise,
and submit again.

This loop also shows another implementation difficulty. The problem page (@fig:problem-page)
creates a submission, the result page (@fig:submission-result-page) reads the returned
identifier and status, and the submission list page (@fig:submission-list-page) loads the
same attempt again as part of a list. These pages had to stay consistent with one another across
route changes.

#figure(
  kind: image,
  image("fig/submission/submission1.png", width: 100%),
  caption: [Submission list view used for reviewing attempts],
) <fig:submission-list-page>

== FAQ and Profile Pages

The FAQ page (@fig:faq-page) and profile page (@fig:profile-page) are support pages rather than the
center of the contest workflow, but they help make the frontend feel like a complete application.
The FAQ page (@fig:faq-page) provides guidance and a way to ask questions. The profile page
(@fig:profile-page) keeps account information in the same design style as the contest pages.

The FAQ page (@fig:faq-page) and profile page (@fig:profile-page) also reuse the
same routing, layout, and component patterns used in the rest of the frontend.

#figure(
  kind: image,
  image("fig/faq and profile/FAQ.png", width: 100%),
  caption: [FAQ page],
) <fig:faq-page>

#figure(
  kind: image,
  image("fig/faq and profile/profile page.png", width: 100%),
  caption: [Profile page],
) <fig:profile-page>
