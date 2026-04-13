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

#figure(
  kind: image,
  image("fig/dark/light1.png", width: 100%),
  caption: [Light theme example with normal font size],
)

#figure(
  kind: image,
  image("fig/dark/dark1.png", width: 100%),
  caption: [Dark theme example with normal font size],
)

#figure(
  kind: image,
  image("fig/dark/light2.png", width: 100%),
  caption: [Light theme example with large font size],
)

#figure(
  kind: image,
  image("fig/dark/dark2.png", width: 100%),
  caption: [Dark theme example with large font size],
)

=== Uniform Page Structure

Another improvement was the more consistent use of card-based layouts and shared page structure.
Instead of letting each page drift into its own visual style, I tried to keep a common arrangement
for headers, content areas, metadata blocks, and supporting controls. This makes the contest pages,
problem pages, submission pages, FAQ page, and profile page feel more related to one another.

This kind of consistency matters more than it may first appear. In a contest system, users do not
stay on one page for long. They move from the contest list to the contest view, then to a problem,
then to submissions, and sometimes back again within a few minutes. If each page uses a different
visual structure, the system feels harder to read even when the features are correct. Reusing the
same card patterns and page structure reduced this problem and made the frontend feel more stable.

The same visual changes also made later updates easier. Once a card style, spacing pattern, and
header structure were settled, I could reuse them across several pages instead of redesigning each
screen separately. This was useful during the later rounds of polishing, because it allowed visual
refinements to spread across the frontend without rewriting every page from the beginning.

=== Consistency and User Experience

Although these changes are mostly visual, they still matter in practice. In a contest system,
participants move frequently between different pages, so an inconsistent layout can make the
experience feel fragmented even when the functions work correctly. A more uniform interface makes
the page hierarchy clearer and the overall workflow smoother.

Theme switching and font-size switching also improved usability in a more practical way. Problem
statements, tables, and clarification areas can contain dense text. On long sessions, this can
become tiring to read. Giving users the option to change theme and text size does not change the
core logic of the platform, but it does make the interface easier to adapt to different screens,
lighting conditions, and personal reading preferences.

These changes were not only about appearance. They were meant to make normal use easier. A contest
interface should not make the participant spend extra attention on layout, contrast, or page
structure.

== Centralized API Service Layer

All frontend API communication is handled through a centralized service module. This module defines
request helpers, authentication handling, and typed interfaces for different backend endpoints. An
authorization token stored after login is automatically attached to outgoing requests, which avoids
duplicating token logic in each page component. Zod schemas are used to validate server responses at
runtime, helping the frontend detect unexpected payloads early.

The request layer uses Axios interceptors to attach the token and convert backend errors into
frontend-facing messages.

#figure(
  kind: raw,
  [
    ```ts
    api.interceptors.request.use((config) => {
      const token = localStorage.getItem(AUTH_CONFIG.TOKEN_KEY)
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
      return config
    })

    api.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (!error.response) {
          return Promise.reject(new Error("Could not reach the server. Please try again."))
        }
        return Promise.reject(new Error("Something went wrong. Please try again."))
      }
    )
    ```
  ],
  caption: [Code excerpt showing the Axios interceptor setup for authenticated requests],
)

This architecture improves separation of concerns. Page components such as the contest list page and
contest detail page can request the data they need through high-level methods, while lower-level
details such as path formatting, HTTP methods, and validation are hidden inside the shared service
layer. The same structure also makes it easier to maintain a mock API mode for frontend development
and testing.

Another advantage is that the service layer becomes the main place where backend behavior is
translated into frontend behavior. Authentication headers, payload validation, and friendly error
messages are all handled in the same general area. This avoids a common frontend problem where each
page starts solving the same request issues in a slightly different way.

From an implementation perspective, this service layer also makes the frontend easier to maintain as
the project grows. When an API path or response shape changes, the adjustment can be handled in a
small number of shared modules instead of being scattered across many pages. This is particularly
useful in a contest system, because many views depend on related data such as contest metadata,
participant state, problem information, and submission records. A centralized API layer therefore
helps keep the frontend codebase more organized and reduces the risk of inconsistent request logic
between pages.

This also helps during debugging. If a request fails, I can inspect the shared API module first
instead of checking many separate page components. In a project with several related views, this
saves time and makes the source of an issue easier to narrow down.

One part of this service layer is the conversion of backend error codes into simpler frontend
messages. This keeps the participant-facing interface more understandable when a request fails.

#figure(
  kind: raw,
  [
    ```ts
    const getFriendlyErrorMessage = (code: string, message: string) => {
      switch (code) {
        case "INVALID_CREDS":
          return "Incorrect username or password."
        case "INVALID_CONTEST_PASSWORD":
          return "The contest password is incorrect."
        case "PRIVATE_CONTEST":
          return "You cannot access this contest right now."
        default:
          return message || "Something went wrong. Please try again."
      }
    }
    ```
  ],
  caption: [Code excerpt showing backend error messages translated into simpler frontend text],
)

Runtime validation is handled with Zod schemas. This makes the expected submission payload shape
explicit in the frontend code.

#figure(
  kind: raw,
  [
    ```ts
    export const Attempt = z.object({
      problem_id: z.string(),
      language: z.string(),
      code: z.string(),
    })

    export const SubmittedAttempt = z.object({
      id: z.string(),
      problem_id: z.string(),
      problem_title: z.string(),
      username: z.string().optional(),
      status: ProblemStatus,
      score: z.number(),
    })
    ```
  ],
  caption: [Code excerpt showing Zod schemas used to validate submission data],
)

Runtime validation was useful because static typing alone was not enough. TypeScript can describe
what the frontend expects, but it cannot guarantee that the backend actually sends that shape at
runtime. In a system where contest data, participant state, and submission results come from many
requests, this matters. A mismatch may not always crash the page immediately. Sometimes it only
shows up as missing text, a wrong status label, or a broken interaction flow. Runtime validation
made these mismatches easier to spot earlier.

It also made the data contracts more explicit inside the frontend code. Instead of treating backend
payloads as loosely shaped objects, the schemas made it clearer what fields were required and which
ones were optional. This was especially useful while the frontend was still being aligned with the
current backend implementation.

Contest API methods are grouped in the same service layer. This keeps contest-related requests in
one place instead of scattering them across many page components.

#figure(
  kind: raw,
  [
    ```ts
    const contestMethods = (contestId: string) => ({
      get: () => doRequest(() => api.get(`/api/contests/${contestId}`), Contest),
      getProblems: () =>
        doRequest(() => api.get(`/api/contests/${contestId}/problems`), Problem.array()),
      createSubmission: (body: CreateSubmissionInput) =>
        doRequest(
          () => api.post(`/api/contests/${contestId}/submissions`, body),
          SubmittedAttempt
        ),
    })
    ```
  ],
  caption: [Code excerpt showing grouped contest API methods in the shared service module],
)

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

This kind of alignment work is easy to underestimate. A page may still compile and render even when
it uses an outdated route or an old field name. The problem only becomes visible when a user tries
to perform a real action, such as joining a contest, viewing a profile, or submitting a solution.
For that reason, keeping the frontend contract close to the backend contract became an important
part of the implementation, not just a small cleanup task.

== Challenges and Issues Faced

One recurring challenge was the gap between sample data and real backend data. Early frontend work
was often done with fixed or simplified values so that the page structure could be built first.
This made it easier to design and style the interface, but it also meant that some later issues
only appeared when the frontend was connected to real responses. Fields that looked simple in a
mocked example sometimes behaved differently in the actual backend payload.

Another challenge was keeping frontend state and contest state in sync. In a contest system, page
state is not just local UI state. It is tied to time-sensitive actions such as joining a contest,
leaving a contest, opening problems, and viewing submissions. If the frontend makes the wrong
assumption about contest status, the user can end up seeing an interface that looks valid but no
longer matches the real backend state.

Dark mode and layout consistency created a different kind of challenge. Once the platform supported
multiple themes, every page needed to be checked again for contrast, background colors, and shared
components. A layout that looked acceptable in light mode could become awkward in dark mode,
especially around cards, forms, and table-like sections. This was one reason why shared layout
patterns became important in the later stage of the project.

There was also the issue of gradual refinement. Many pages were first built to be functional, and
only later polished for readability and consistency. This is normal in frontend work, but it means
the codebase changes in two directions at once: one part focuses on correct behavior, while another
part focuses on presentation and user experience. Balancing these two goals took time, especially
because a visual improvement on one page often suggested similar updates on several other pages.

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

In practice, this checking included more than one kind of validation. Local builds were used to
confirm that the project still compiled, and TypeScript checks were used to catch mismatched props,
request types, and data shapes after changes to shared modules. Manual checking was also important,
because many frontend issues only appear when moving through real user flows such as login, joining
a contest, opening a problem, submitting code, and returning to the results page.

This combination of compile-time checks and manual flow testing was useful because the frontend is a
connected system rather than a set of isolated pages. A small change to a shared service, route, or
theme component can affect several other views. Verifying stability after each round of changes
helped reduce the chance that a new improvement in one area would quietly break behavior in another.
