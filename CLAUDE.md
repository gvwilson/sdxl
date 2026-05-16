# Claude

This project is an introduction to software design by example using
the Lean programming language.

## Audience

Learners have completed the first two years of an undergraduate degree
in computer science. They are comfortable writing programs that are
several hundred lines long in imperative languages such as Python and
Java, but have no prior experience with pure functional programming.
They are interested in learning practical skills rather than in the
theory of computing.

Learners frequently use LLM tools like Claude to help with homework
assignments or in place of search engines.

## Content

-   Each lesson should take one hour to complete, including exercises.
    When in doubt, go slowly.

-   Define new terms using the `%g` shortcode and add definitions to
    `./glossary/index.md`.

-   Each lesson is in its own subdirectory, whose name is a one-word
    descriptive slug. Lessons are included in the `Lessons` section
    of `README.md` in order.

-   Each lesson has an `index.md` file with an H1 title followed by
    sections with H2 titles.

-   Lesson content in each section is written as point-form lists
    using four-space indentation. *NEVER* put tab characters in files.
    Point-form lists may include sub-lists, but only one level deep.

-   Code is put in files in the lesson directory. These files are
    transcluded in the lesson using mccole's `%inc` tag. The shell
    command to run the code (if needed) is put in a `.sh` file in the
    lesson directory, which is also transcluded in the lesson.

-   The final section of each lesson is an H2 titled `Exercises`. It
    is followed by 3-5 exercises, each of which has a brief H3 title
    followed by a point-form description of the exercise.

## Style Rules

-   Each lesson directory must be self-contained and not depend on
    files in other lesson directories, unless the lessons are
    explicitly ordered and one lesson builds directly on the previous
    one.

@~/.claude/mccole.md
