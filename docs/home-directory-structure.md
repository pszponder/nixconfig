# Home Directory Structure

```
~/
├── repos/                    # Source-controlled projects and repositories
│   └── github/
│       └── pszponder/        # Personal GitHub repositories
│
├── resources/                # Learning materials, reference material, and knowledge
│   ├── courses/               # Course materials, tutorials, and learning programs
│   ├── books/                 # Books, ebooks, and book-related material
│   ├── datasets/               # Datasets and data used for learning, analysis, or experimentation
│   ├── cheatsheets/            # Quick-reference guides and condensed technical references
│   └── notes/                  # Personal notes, summaries, and distilled knowledge
│
└── scratch/                  # Temporary, disposable work and quick experiments
```

Native NixOS per-user tmpfiles rules create these ordinary writable directories
during user setup, with no cleanup age. Existing directory permissions are retained. Existing contents are preserved. Removing a
directory from the declaration does not delete it, and `scratch` has no automatic
cleanup. SSH directories are also created with permissions `0700`; keys are
generated separately with `just bootstrap-ssh`.

Run `just bootstrap` as your normal user to create the directories immediately
and interactively generate any missing SSH key pairs. The two steps are also
available separately as `just bootstrap-home` and `just bootstrap-ssh`.

The directory list in `modules/features/home-directories/directories` is shared
by the bootstrap script and the NixOS tmpfiles rules. Neither step activates the
system configuration. Existing key pairs are retained; incomplete pairs and
symlink key destinations cause SSH bootstrap to stop for inspection.
