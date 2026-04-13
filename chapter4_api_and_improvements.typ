= API Integration, Validation, and Refinement

== Usability and Consistency Refinements

Besides implementing the main contest features, I also refined the frontend so that it felt more
consistent in repeated use. These changes were not the main engineering work, but they still
mattered because a contest interface is used under time pressure and often for long sessions.

=== Theme and Typography

The frontend supports light and dark themes and also allows users to change text size. These
features were added because pages such as problem statements, submission records, and FAQ content
can contain a lot of text and may be used for a long time.

#figure(
  kind: image,
  image("fig/dark/light1.png", width: 100%),
  caption: [Light theme example],
)

#figure(
  kind: image,
  image("fig/dark/dark1.png", width: 100%),
  caption: [Dark theme example],
)

=== Shared Page Structure

I also made the page structure more consistent by using shared cards, page headers, spacing
patterns, and metadata sections. In earlier stages, different pages could drift into slightly
different styles because they were built at different times.

This work also had an engineering side. Once the shared structure was settled, later updates could
be made through shared components and containers instead of redesigning each page again.

Frontend refinement also had to be balanced with integration work. In practice, visual work and
backend alignment moved at the same time, not one after the other.

== Centralized API Service Layer

All frontend API communication is handled through a centralized service module. This module defines
request helpers, authentication handling, and typed interfaces for backend endpoints. After login,
the authorization token is attached automatically to outgoing requests. Zod schemas are then used
to check server responses at runtime.

The request layer uses Axios interceptors to attach the token and convert backend failures into
simple frontend-facing messages.

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

This structure keeps page components simpler. Pages such as the contest list page and contest
detail page can call high-level methods, while HTTP methods, path formatting, authentication
headers, and response validation stay in shared modules.

The service layer also handles error normalization. Backend error codes are not always suitable for
direct display, so the frontend maps them to simpler messages.

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

Runtime validation is handled with Zod schemas. This makes the expected data contract clear in the
frontend code and reduces the risk of silently accepting bad payloads.

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

This runtime layer was important because TypeScript alone only describes what the frontend expects
at compile time. It does not guarantee that the backend will return the same shape at runtime.

This was especially useful because the frontend did not start with a fixed final backend contract.
Early page work often used simplified assumptions or mock data so that layout and workflow could be
built first. When real payloads were introduced, some of these assumptions turned out to be
incomplete.

Contest-related methods are grouped in the same service layer so that route-level components do not
need to rebuild contest request logic again and again.

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
    retrieval through shared authentication requests.],
    [`contests` module], [Contest operations], [Provides contest metadata, participant actions,
    problems, clarifications, and submissions through grouped contest methods.],
    [`system` module], [System status], [Exposes jury-oriented system status data needed for
    administrative monitoring features.],
    [`types/*` schemas], [Validation and typing], [Define TypeScript and Zod-based data structures
    so backend payloads can be parsed and checked consistently.],
  ),
  caption: [Main API and service-layer modules used by the frontend],
)

== Difficulties in Frontend-Backend Integration

The hardest part of connecting the frontend to the backend was not just sending requests. The hard
part was keeping page behavior correct while the data contract and contest state assumptions were
still becoming clear. A contest frontend depends on many related backend facts at the same time:
whether the user is authenticated, whether the contest can be accessed, whether the participant has
already left the contest, what problems belong to that contest, and how a submission result should
be loaded after creation.

This created several difficulties. Some early frontend work used simplified or mocked data so that
pages could be built before the full backend behavior was ready. This helped early development, but
it also meant that some problems appeared only later, when real backend responses introduced fields
or states that were not fully represented in the frontend types.

Contest state was also harder than normal static page data. Actions such as joining, leaving,
opening problems, and viewing submissions depended on timing and participation state. The frontend
had to stay close to backend state changes.

There was also a cross-page problem. Contest metadata, participant state, problem data, and
submission data were used in several places. If one shared assumption was wrong, the issue could
appear on a different page later in the workflow.

These difficulties changed the implementation strategy. Instead of letting each page handle its own
request and validation logic, the frontend moved toward shared service modules, shared schemas, and
clearer route-level responsibilities.

== Alignment with the Current Backend Contract

In the later stage of the project, one important task was fixing mismatches between frontend
assumptions and the current backend contract. For example, the frontend profile request used an
outdated path and had to be changed to the backend's current `/me` endpoint. Contest-related types
also had to be updated to match real backend fields, including `left_contest` and the structure of
the `participants` response.

These issues were important because a page can still compile and render even when it depends on an
outdated route or field name. The problem may only appear when a user tries to view a profile, join
a contest, or submit code.

These problems also affected workflow correctness. An outdated profile route does not just break one
request. It also weakens the assumption that authenticated identity is being handled in a consistent
way. A missing contest-state field does not just affect typing. It can also make the frontend show
actions that should no longer be available.

#figure(
  table(
    columns: (1.1fr, 1.3fr, 2.1fr),
    inset: 8pt,
    stroke: luma(180),
    [*Area*], [*Adjustment made*], [*Reason it mattered*],
    [Profile retrieval], [Updated the request to use the backend's `/me` endpoint], [Ensured that
    authenticated user information was fetched from the current backend route rather than an
    outdated assumption.],
    [Contest state typing], [Updated frontend types to include fields such as `left_contest`], [The
    frontend needed these fields to interpret whether a participant could still access contest
    actions correctly.],
    [Participant-related responses], [Aligned the frontend with the actual `participants` response
    structure], [Reduced the risk of route-level pages misreading contest participation data.],
  ),
  caption: [Examples of frontend-backend alignment work carried out during the project],
)

== Validation and Scenario-Based Evaluation

The project did not include a formal user study, so evaluation was based on engineering checks and
scenario-based walkthroughs. I used three main forms of verification: local builds, TypeScript
checks, and manual end-to-end testing of the main participant flow.

These checks were chosen because they cover the parts of the system most likely to break when
frontend and backend alignment changes. Build and type checks can catch obvious structural
problems. Manual walkthroughs are still needed because many contest issues only appear when a user
moves across several pages in sequence.

#figure(
  table(
    columns: (1.4fr, 1.2fr, 2fr),
    inset: 8pt,
    stroke: luma(180),
    [*Scenario*], [*Validation approach*], [*Observed outcome*],
    [Login and protected access], [Manual walkthrough and request verification], [Users could enter
    the participant area after authentication, while invalid or missing authenticated state was
    redirected back to login.],
    [Contest discovery and entry], [Manual walkthrough of list, password dialog, and contest view],
    [Contest metadata, state labels, and contest entry flow remained consistent after API-layer
    changes.],
    [Problem solving and draft persistence], [Manual walkthrough of problem page interactions],
    [Problem data could be loaded, draft code could be preserved locally, and the user could remain
    in a continuous read-code-submit workflow.],
    [Submission and result navigation], [Manual walkthrough of create-submission flow], [A
    successful submission could lead directly to the corresponding result page without breaking the
    contest context.],
    [Profile retrieval], [Route check after endpoint correction], [Profile data could be requested
    through the updated backend contract rather than an outdated route.],
    [Shared type and module consistency], [Local build and type-level validation], [Changes to
    routes, request helpers, and shared types did not introduce immediate compile-time
    inconsistencies.],
  ),
  caption: [Scenario-based validation used to check the revised participant frontend],
)

The selected scenarios match the main participant tasks discussed earlier: entering the system,
joining a contest, opening a problem, preserving work, submitting a solution, viewing the result,
and retrieving user information through the corrected backend route.

== Limitations and Future Work

Several limitations remain. The evaluation in this report is based on local validation and manual
walkthroughs, not a formal usability study. Some screenshots were taken while parts of the backend
were still being finalized. The report also focuses on the participant frontend, so it does not
cover the full administrative or judging workflow.

These limitations suggest clear future work:

- Add automated end-to-end tests for key contest scenarios such as contest entry, submission, and
  profile retrieval.
- Conduct structured usability evaluation with student participants during realistic contest tasks.
- Extend live integration testing as more backend features stabilize.
- Continue refining participant-facing feedback for error states, contest status changes, and
  clarification updates.
