# conda-forge Setup Guide

This guide explains how to make `colored-logging` available on conda-forge with fully automated releases.

## Quick Start (Automated)

The easiest way to submit to conda-forge is using the automated script:

```bash
# Submit the current version from pyproject.toml
make conda-forge-submit

# Or specify a version explicitly
make conda-forge-submit-version VERSION=1.0.2
```

The script will:
- Fork staged-recipes (if needed)
- Download the package from PyPI
- Calculate SHA256 hash automatically
- Update meta.yaml with correct version and hash
- Create a branch and commit
- Push to your fork
- Create a Pull Request (if GitHub CLI is installed)

### Prerequisites

1. **One-time**: Fork [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes) or let the script do it
2. **Optional**: Install GitHub CLI for automatic PR creation:
   ```bash
   brew install gh
   gh auth login
   ```

## Manual Setup (Alternative)

If you prefer to submit manually or need more control:

### Step 1: Initial Submission to conda-forge

1. Fork the [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes) repository

2. Create a new branch in your fork:
   ```bash
   git checkout -b add-colored-logging
   ```

3. Create a directory for your recipe:
   ```bash
   mkdir recipes/colored-logging
   ```

4. Copy the `meta.yaml` file from this repository's `conda-recipe/` directory to `recipes/colored-logging/meta.yaml`

5. Update the SHA256 hash in `meta.yaml`:
   - Go to https://pypi.org/project/colored-logging/#files
   - Download the source distribution (.tar.gz)
   - Calculate its SHA256 hash:
     ```bash
     shasum -a 256 colored_logging-1.0.1.tar.gz
     ```
   - Replace the `sha256:` field in `meta.yaml` with this hash

6. Commit and push:
   ```bash
   git add recipes/colored-logging/meta.yaml
   git commit -m "Add colored-logging package"
   git push origin add-colored-logging
   ```

7. Create a Pull Request to conda-forge/staged-recipes

8. Wait for review (typically 1-2 weeks). The conda-forge team will:
   - Review your recipe
   - Provide feedback if needed
   - Merge when approved

### Step 2: Configure Your Feedstock for Auto-Updates

Once your PR is merged, conda-forge will automatically create a feedstock repository at:
`https://github.com/conda-forge/colored-logging-feedstock`

To enable fully automated releases:

1. You'll be added as a maintainer to the feedstock repository

2. Navigate to the feedstock and create a file `conda-forge.yml` (if it doesn't exist) or edit it:
   ```yaml
   bot:
     automerge: true
     check_solvable: true
   conda_build_tool: conda-build
   ```

3. Commit this configuration:
   ```bash
   git add conda-forge.yml
   git commit -m "Enable automerge for version updates"
   git push
   ```

## How Automated Releases Work

After the one-time setup, the release process is fully automated:

1. **You publish a new release** to PyPI (using your existing GitHub Actions workflow)

2. **conda-forge bot detects it** (usually within a few hours)

3. **Bot creates a PR** to the feedstock with:
   - Updated version number
   - Updated SHA256 hash
   - Any necessary dependency updates

4. **Automated checks run**:
   - Package builds on Linux, macOS, and Windows
   - Tests pass
   - Dependencies are solvable

5. **Auto-merge happens** if:
   - All CI checks pass
   - You enabled `automerge: true`
   - No conflicts detected

6. **Package is published** to conda-forge automatically

## Manual Override

If you need to manually update the feedstock (e.g., for build configuration changes):

1. Clone the feedstock:
   ```bash
   git clone https://github.com/conda-forge/colored-logging-feedstock
   cd colored-logging-feedstock
   ```

2. Create a branch and make changes to `recipe/meta.yaml`

3. Commit, push, and create a PR

4. Once CI passes and you merge, the package will be published

## Monitoring

- Watch the feedstock repository for bot PRs
- Check https://anaconda.org/conda-forge/colored-logging for published versions
- Review https://conda-forge.org/status/ for build status

## Troubleshooting

If the bot doesn't create a PR after a PyPI release:

1. Check if there's already an open PR
2. Wait 24 hours (the bot runs on a schedule)
3. Manually create an issue in the feedstock requesting an update
4. As a last resort, manually update the recipe

## Additional Resources

- [conda-forge documentation](https://conda-forge.org/docs/)
- [Maintainer documentation](https://conda-forge.org/docs/maintainer/)
- [conda-forge status page](https://conda-forge.org/status/)
