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
