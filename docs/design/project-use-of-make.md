# Use of Make

- The core Makefile contains only essential items and *includes*, so that Make files for components can be handled separately
- The settings in the core Makefile enforce the use of Bash for consistency
- The settings in the core Makefile set the error handling that is supported by the baseline Bash and Make versions
- The settings in the core Makefile enforce one shell per target, rather than one per line
