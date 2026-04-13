= Abstract

NanyangOJ is a school-owned online programming contest platform for local contests and training.
This report focuses on the participant frontend, not the whole judge system. The aim was to build
a frontend that is easy to use during contests, easy to maintain, and able to match backend
behavior closely.

My work covered both design and implementation. I first used Figma to plan the main user flow and
shared page layout. I then implemented the main pages in React and TypeScript, including login,
contest entry, contest and problem pages, submissions, FAQ, and profile pages. The frontend also
uses shared routing, shared layout components, and a centralized API service layer for
authentication, request handling, response validation, and error handling.

Later, I spent a lot of time on integration and stability work. I updated routes and data types to
match the current backend contract, fixed outdated endpoints, and added validation checks to catch
response mismatches earlier. I used manual end-to-end walkthroughs, local builds, and type checks
to verify the main participant flow after these changes.

The project shows how a contest frontend can be built as one connected part of a larger system. It
also provides a practical base for a school-owned online judge. There is still more work to do on
live integration and formal usability testing.
