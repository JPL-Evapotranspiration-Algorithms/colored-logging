#!/usr/bin/env bash

# Script to automate conda-forge submission
# Usage: ./scripts/submit_to_conda_forge.sh [version]
# Example: ./scripts/submit_to_conda_forge.sh 1.0.1

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Package name (with dash for PyPI, underscore for file)
PACKAGE_NAME_PYPI="colored-logging"
PACKAGE_NAME_FILE="colored_logging"

# Get version from argument or pyproject.toml
if [ -n "$1" ]; then
    VERSION="$1"
else
    VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
fi

echo -e "${BLUE}=== conda-forge Submission Script ===${NC}"
echo -e "${BLUE}Package: ${PACKAGE_NAME_PYPI}${NC}"
echo -e "${BLUE}Version: ${VERSION}${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}Warning: GitHub CLI (gh) not found. PR creation will be skipped.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
    HAS_GH=false
else
    HAS_GH=true
fi

# Step 1: Check if staged-recipes fork exists
echo -e "${BLUE}Step 1: Checking for staged-recipes fork...${NC}"
STAGED_RECIPES_DIR="$HOME/conda-forge-staged-recipes"

if [ ! -d "$STAGED_RECIPES_DIR" ]; then
    echo -e "${YELLOW}Staged recipes fork not found at $STAGED_RECIPES_DIR${NC}"
    echo -e "${YELLOW}Please fork https://github.com/conda-forge/staged-recipes first.${NC}"
    echo ""
    echo "Run these commands:"
    echo "  gh repo fork conda-forge/staged-recipes --clone --remote"
    echo "  mv staged-recipes $STAGED_RECIPES_DIR"
    echo ""
    read -p "Do you want to fork now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] && [ "$HAS_GH" = true ]; then
        cd "$HOME"
        gh repo fork conda-forge/staged-recipes --clone --remote
        mv staged-recipes "$STAGED_RECIPES_DIR"
        cd "$STAGED_RECIPES_DIR"
    else
        echo -e "${RED}Cannot continue without staged-recipes fork.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Found staged-recipes fork${NC}"
    cd "$STAGED_RECIPES_DIR"
fi

# Step 2: Update from upstream
echo ""
echo -e "${BLUE}Step 2: Updating from upstream...${NC}"
git checkout main 2>/dev/null || git checkout master 2>/dev/null
git fetch upstream 2>/dev/null || git remote add upstream https://github.com/conda-forge/staged-recipes.git
git fetch upstream
git merge upstream/main 2>/dev/null || git merge upstream/master 2>/dev/null
echo -e "${GREEN}✓ Updated from upstream${NC}"

# Step 3: Create branch
BRANCH_NAME="add-${PACKAGE_NAME_PYPI}-${VERSION}"
echo ""
echo -e "${BLUE}Step 3: Creating branch ${BRANCH_NAME}...${NC}"
git checkout -B "$BRANCH_NAME"
echo -e "${GREEN}✓ Created branch${NC}"

# Step 4: Create recipe directory
RECIPE_DIR="recipes/${PACKAGE_NAME_PYPI}"
echo ""
echo -e "${BLUE}Step 4: Creating recipe directory...${NC}"
mkdir -p "$RECIPE_DIR"
echo -e "${GREEN}✓ Created $RECIPE_DIR${NC}"

# Step 5: Download package from PyPI and calculate SHA256
echo ""
echo -e "${BLUE}Step 5: Downloading package from PyPI and calculating SHA256...${NC}"
PYPI_URL="https://pypi.io/packages/source/${PACKAGE_NAME_PYPI:0:1}/${PACKAGE_NAME_PYPI}/${PACKAGE_NAME_FILE}-${VERSION}.tar.gz"
TEMP_FILE=$(mktemp)

echo "  Downloading from: $PYPI_URL"
if curl -L -f -o "$TEMP_FILE" "$PYPI_URL"; then
    SHA256=$(shasum -a 256 "$TEMP_FILE" | awk '{print $1}')
    echo -e "${GREEN}✓ SHA256: $SHA256${NC}"
    rm "$TEMP_FILE"
else
    echo -e "${RED}✗ Failed to download package from PyPI${NC}"
    echo -e "${RED}  Make sure version ${VERSION} is published to PyPI${NC}"
    rm "$TEMP_FILE"
    exit 1
fi

# Step 6: Copy and update meta.yaml
echo ""
echo -e "${BLUE}Step 6: Creating meta.yaml...${NC}"
SOURCE_REPO=$(pwd)
cd - > /dev/null  # Go back to original directory

# Read the template meta.yaml
META_YAML_SOURCE="conda-recipe/meta.yaml"
META_YAML_DEST="$STAGED_RECIPES_DIR/$RECIPE_DIR/meta.yaml"

# Create meta.yaml with updated version and SHA256
cat "$META_YAML_SOURCE" | \
    sed "s/^{% set version = \".*\" %}$/{% set version = \"${VERSION}\" %}/" | \
    sed "s/sha256:.*/sha256: ${SHA256}/" > "$META_YAML_DEST"

echo -e "${GREEN}✓ Created meta.yaml with version ${VERSION} and SHA256${NC}"

# Step 7: Commit changes
cd "$STAGED_RECIPES_DIR"
echo ""
echo -e "${BLUE}Step 7: Committing changes...${NC}"
git add "$RECIPE_DIR/meta.yaml"
git commit -m "Add ${PACKAGE_NAME_PYPI} v${VERSION}"
echo -e "${GREEN}✓ Committed changes${NC}"

# Step 8: Push branch
echo ""
echo -e "${BLUE}Step 8: Pushing branch...${NC}"
git push -u origin "$BRANCH_NAME" --force
echo -e "${GREEN}✓ Pushed branch${NC}"

# Step 9: Create PR (if gh CLI is available)
echo ""
if [ "$HAS_GH" = true ]; then
    echo -e "${BLUE}Step 9: Creating Pull Request...${NC}"
    
    PR_TITLE="Add ${PACKAGE_NAME_PYPI} v${VERSION}"
    PR_BODY="This PR adds the ${PACKAGE_NAME_PYPI} package to conda-forge.

**Package Information:**
- PyPI: https://pypi.org/project/${PACKAGE_NAME_PYPI}/
- GitHub: https://github.com/JPL-Evapotranspiration-Algorithms/${PACKAGE_NAME_PYPI}
- Version: ${VERSION}
- License: Apache-2.0

**Checklist:**
- [x] License file is packaged
- [x] Source URL is from an official source (PyPI)
- [x] SHA256 is correct
- [x] Package runs on noarch/python
- [x] Tests included (import test)
- [x] All dependencies specified

This is an automated submission created by the package maintainer."

    if gh pr create --repo conda-forge/staged-recipes --title "$PR_TITLE" --body "$PR_BODY" --head "$USER:$BRANCH_NAME"; then
        echo -e "${GREEN}✓ Pull Request created successfully!${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to create PR automatically${NC}"
        echo "  Create it manually at: https://github.com/conda-forge/staged-recipes/compare/main...$USER:$BRANCH_NAME"
    fi
else
    echo -e "${YELLOW}Step 9: Skipped (GitHub CLI not available)${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Go to: https://github.com/conda-forge/staged-recipes"
    echo "  2. Click 'Compare & pull request' for branch: $BRANCH_NAME"
    echo "  3. Fill in the PR template and submit"
fi

echo ""
echo -e "${GREEN}=== Submission Complete ===${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Package: ${PACKAGE_NAME_PYPI}"
echo "  Version: ${VERSION}"
echo "  SHA256: ${SHA256}"
echo "  Branch: ${BRANCH_NAME}"
echo ""
echo -e "${BLUE}What's next:${NC}"
echo "  1. Wait for conda-forge review (typically 1-2 weeks)"
echo "  2. Respond to any feedback"
echo "  3. Once merged, a feedstock will be created automatically"
echo "  4. Future releases will be automated by conda-forge bot"
