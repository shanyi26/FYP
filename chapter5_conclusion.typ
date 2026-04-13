= Conclusion

This project focused on the participant frontend of NanyangOJ as one part of a school-owned online
judge. The work covered both interface design and frontend implementation.

The main goals of the project were achieved in the following ways. The participant interface was
planned in Figma and implemented in React and TypeScript. The main workflow was built through
structured routing, reusable components, and contest-scoped pages. Frontend-backend communication
was moved into a shared API service layer. The implemented frontend supports login, contest entry,
problem solving, clarifications, submission review, ranking access, and profile access. Later
integration work also improved correctness by updating routes and types to match the current
backend contract.

One main lesson from the project is that contest frontend work is not only about making pages look
complete. The frontend also has to keep the workflow clear, read backend state correctly, and stay
easy to maintain as the system changes.

The project also showed that frontend-backend integration was one of the hardest parts of the work.
Participant actions depend on authenticated identity, contest participation state, route
parameters, and the exact shape of backend responses.

The current frontend provides a practical base for a school-owned contest platform. There is still
more work to do on live integration, automated end-to-end testing, and formal usability testing.
