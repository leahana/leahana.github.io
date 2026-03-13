Review this project for security vulnerabilities. Focus on:

1. **Secrets & Credentials**: Scan all source files for hardcoded passwords, API keys, tokens, connection strings, and other sensitive data. Use the patterns from `bin/check-secrets.sh` as a baseline, but also look for anything the regex patterns might miss.

2. **Configuration Security**: Check `_config.yml` and `_config.kratos-rebirth.yml` for exposed secrets, insecure defaults, or misconfigured settings.

3. **Script Injection**: Review shell scripts in `bin/` and `.githooks/` for command injection risks, unsafe variable expansion, or path traversal vulnerabilities.

4. **GitHub Actions**: Audit `.github/workflows/deploy.yml` for:
   - Insecure action versions (missing hash pinning)
   - Secret exposure in logs
   - Overly broad permissions

5. **Dependency Risk**: Check `package.json` for known vulnerable or suspicious packages.

6. **Content Security**: Scan markdown posts in `source/_posts/` for accidentally committed private information (internal URLs, email addresses, internal project names).

Output a structured report with:
- **Critical**: Issues that must be fixed immediately
- **Warning**: Issues that should be addressed
- **Info**: Recommendations for improvement

For each finding, provide the file path, line number, and a recommended fix.
