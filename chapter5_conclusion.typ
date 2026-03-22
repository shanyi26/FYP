= Conclusion

This project focuses on the participant-facing frontend of NanyangOJ, a school-owned online judge
intended to support local programming contests and training activities. My work covered both design
and implementation. I first planned the main interface structure in Figma, and then implemented the
core participant pages in React and TypeScript, including authentication, contest access, problem
solving, submissions, FAQ, and profile-related views.

Beyond page implementation, the project also involved building the frontend structure needed to
support these functions in a maintainable way. This included routing, shared components, theme and
layout consistency, and a centralized API layer for communicating with the backend. In the later
stages of the work, I also focused on improving frontend reliability by aligning requests and data
handling more closely with the current backend behavior.

From a practical point of view, this frontend is important because it gives the contest platform a
usable participant-facing layer. A contest system is not only about judging submissions correctly.
It also needs pages that help users log in, find contests, read problems, submit code, check
results, and handle common questions without confusion. For this reason, the work in this project
was not limited to building separate screens. It was also about connecting these screens into one
clear flow that participants can follow during real use.

The project also shows that frontend work in a contest platform involves both interface design and
system alignment. A page may look complete on its own, but it still depends on correct routing,
shared state, reusable components, and accurate backend communication. Because of this, a large part
of the work was making sure that the frontend remained consistent in both appearance and behavior.
This was especially important when refining participant pages and adjusting the frontend to match
the current backend contract more closely.

There is still room for further work. Some parts of the platform can be connected more deeply to
live backend data, and some pages can continue to be refined as the full system becomes more
complete. Even so, the frontend implemented in this project already provides a solid base for a
school-owned online judge. It supports the main participant workflow and shows how the platform can
be developed into a more reliable and coherent contest environment for students.
