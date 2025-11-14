# Contributing to Home Lab Setup

Thank you for your interest in contributing to this project! This document provides guidelines and best practices for contributing.

## 🌿 Branch Strategy

### Branch Types

1. **`main`** - Production-ready code
   - Protected branch
   - Requires PR review before merge
   - All releases are tagged from main

2. **`dev`** - Development integration branch
   - Protected branch
   - Feature branches merge here first
   - Tested before merging to main

3. **`feature/*`** - New features
   - Branch from: `dev`
   - Merge to: `dev`
   - Naming: `feature/descriptive-name`
   - **⚠️ DO NOT DELETE after merge** - Keep for history

4. **`bugfix/*`** - Bug fixes
   - Branch from: `dev`
   - Merge to: `dev`
   - Naming: `bugfix/issue-description`
   - **⚠️ DO NOT DELETE after merge** - Keep for history

5. **`hotfix/*`** - Critical production fixes
   - Branch from: `main`
   - Merge to: `main` and `dev`
   - Naming: `hotfix/critical-issue`
   - **⚠️ DO NOT DELETE after merge** - Keep for history

### Branch Protection Policy

**All feature, bugfix, and hotfix branches should be preserved after merging.**

Reasons:
- Maintains complete project history
- Allows easy reference to implementation details
- Facilitates code archaeology and debugging
- Enables rollback if needed

## 🔄 Workflow

### Creating a New Feature

1. **Sync with dev branch:**
   ```bash
   git checkout dev
   git pull origin dev
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes:**
   - Write clean, documented code
   - Follow existing code style
   - Add tests if applicable
   - Update documentation

4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: descriptive commit message"
   ```

5. **Push to remote:**
   ```bash
   git push -u origin feature/your-feature-name
   ```

6. **Create Pull Request:**
   ```bash
   gh pr create --base dev --title "feat: Your Feature Title" --body "Description of changes"
   ```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```
feat: Add regex pattern support for Pi-hole lists
fix: Resolve authentication timeout issue
docs: Update README with new configuration options
chore: Update dependencies to latest versions
```

## 📋 Pull Request Guidelines

### Before Creating a PR

- [ ] Code follows project conventions
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages follow convention
- [ ] Branch is up to date with target branch

### PR Description Template

```markdown
## 🎯 Summary
Brief description of changes

## ✨ Changes Made
- Change 1
- Change 2
- Change 3

## 🧪 Testing
How the changes were tested

## 📚 Documentation
Documentation updates made

## ✅ Checklist
- [ ] Code follows conventions
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes
```

### PR Review Process

1. Create PR to `dev` branch
2. Automated checks run
3. Code review by maintainers
4. Address feedback if needed
5. Merge when approved
6. **DO NOT delete the feature branch**

## 🛠️ Development Setup

### Prerequisites

- Ansible 2.9+
- Python 3.8+
- SSH access to target server
- GitHub CLI (optional, for PR management)

### Local Development

1. **Clone repository:**
   ```bash
   git clone https://github.com/aldrineeinsteen/home-lab-setup.git
   cd home-lab-setup
   ```

2. **Configure environment:**
   ```bash
   cp .env.template.yaml .env.yaml
   # Edit .env.yaml with your settings
   ```

3. **Test connection:**
   ```bash
   ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping
   ```

## 🧪 Testing

### Manual Testing

Test your changes on a development Pi-hole instance:

```bash
# Test specific tags
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml \
  --extra-vars "@.env.yaml" --tags lists

# Full deployment test
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml \
  --extra-vars "@.env.yaml"
```

### Validation Checklist

- [ ] Playbook runs without errors
- [ ] Idempotent (safe to run multiple times)
- [ ] No unintended side effects
- [ ] Documentation matches implementation
- [ ] Configuration examples work

## 📝 Documentation

### What to Document

- New features and their usage
- Configuration options
- Breaking changes
- Migration guides
- Troubleshooting tips

### Where to Document

- **README.md** - User-facing documentation
- **CONTRIBUTING.md** - Contributor guidelines (this file)
- **Code comments** - Complex logic explanation
- **Commit messages** - Change rationale

## 🐛 Reporting Issues

### Before Reporting

1. Check existing issues
2. Verify it's reproducible
3. Gather relevant information

### Issue Template

```markdown
**Description:**
Clear description of the issue

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Environment:**
- OS: Ubuntu 22.04
- Ansible: 2.15.0
- Pi-hole: v6.2.2

**Additional Context:**
Any other relevant information
```

## 🔐 Security

### Reporting Security Issues

**DO NOT** create public issues for security vulnerabilities.

Instead:
1. Email security concerns privately
2. Include detailed description
3. Provide steps to reproduce
4. Allow time for fix before disclosure

### Security Best Practices

- Never commit sensitive data (`.env.yaml` is in `.gitignore`)
- Use SSH keys instead of passwords
- Keep dependencies updated
- Follow principle of least privilege

## 📜 Code Style

### Ansible

- Use 2 spaces for indentation
- Quote strings when needed
- Use descriptive task names
- Add comments for complex logic
- Follow [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### YAML

- Consistent indentation (2 spaces)
- Use `---` at file start
- Quote strings with special characters
- Use lists for multiple items

### Documentation

- Use clear, concise language
- Include code examples
- Add emojis for visual clarity (sparingly)
- Keep line length reasonable (80-120 chars)

## 🎓 Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 📞 Getting Help

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and community support
- **Pull Requests** - Code contributions

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

**Thank you for contributing! 🎉**

*Last updated: 2025-11-14*