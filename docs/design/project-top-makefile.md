# The Top-Level Makefile

- The top-level Makefile contains only essential items and *includes*, so that Make files for components can be handled separately
- The syntax of the Makefile is compatible with GNU Make 3. This is the version that is provided with macOS.
- The settings in the core Makefile set the error handling that is supported by POSIX shell
- The settings in the core Makefile enforce one shell per target, rather than one per line
