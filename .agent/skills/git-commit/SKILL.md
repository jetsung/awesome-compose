---
name: git-commit
description: Generates standardized git commit messages following the Conventional Commits format with Chinese descriptions.
version: 1.0.0
---

# Git Commit Message Generation

This skill assists in creating git commit messages that adhere to the Conventional Commits specification.

## Instructions

When you are asked to create a commit message or commit changes, follow these steps:

1.  **Analyze the changes**: Examine the staged changes (`git diff --staged`) or the provided context.
2.  **Determine the type**: Use one of the following types:
    *   `feat`: A new feature
    *   `fix`: A bug fix
    *   `docs`: Documentation only changes
    *   `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
    *   `refactor`: A code change that neither fixes a bug nor adds a feature
    *   `perf`: A code change that improves performance
    *   `test`: Adding missing tests or correcting existing tests
    *   `build`: Changes that affect the build system or external dependencies
    *   `ci`: Changes to our CI configuration files and scripts
    *   `chore`: Other changes that don't modify src or test files
    *   `revert`: Reverts a previous commit
3.  **Determine the scope**: (Optional but recommended) The specific module, directory, or component changed (e.g., `acme`, `nginx`, `readme`).
4.  **Write the description**:
    *   Must be in **Chinese (Simplified)**.
    *   Must be concise and descriptive.
    *   Do not end with a period.
5.  **Format**: Combine them as `<type>(<scope>): <description>`.

## Examples

**Example 1:**
*   Input: Added a new configuration file for Adminer.
*   Output: `feat(adminer): 添加 compose 配置文件`

**Example 2:**
*   Input: Fixed a date formatting bug in utils.
*   Output: `fix(utils): 修复日期格式化错误`

**Example 3:**
*   Input: Updated the README file.
*   Output: `docs(README): 更新项目说明`

**Example 4:**
*   Input: Upgraded dependency packages.
*   Output: `chore(deps): 升级依赖包`
