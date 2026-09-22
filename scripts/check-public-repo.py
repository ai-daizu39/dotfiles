#!/usr/bin/env python3
"""Check outgoing commits for secrets and personal/local environment data."""

from __future__ import annotations

import argparse
import os
import re
import socket
import subprocess
import sys
from pathlib import PurePosixPath

ZERO_SHA = "0" * 40

PRIVATE_FILE_PATTERNS = (
    re.compile(r"(^|/)(?:id_rsa|id_dsa|id_ecdsa|id_ed25519)$", re.I),
    re.compile(
        r"(^|/)\.env(?:\.(?!(?:example|sample|template|dist)$).+)?$",
        re.I,
    ),
    re.compile(r"\.(?:key|pem|p12|pfx)$", re.I),
    re.compile(r"(^|/)(?:credentials?|secrets?)\.(?:json|ya?ml|toml)$", re.I),
)

EMAIL_RE = re.compile(r"\b[A-Z0-9._%+-]+@([A-Z0-9.-]+\.[A-Z]{2,})\b", re.I)
HOME_PATH_RE = re.compile(
    r"(?:/home/(?!user\b|example\b)[A-Za-z0-9._-]+"
    r"|/Users/(?!user\b|example\b)[A-Za-z0-9._-]+"
    r"|[A-Za-z]:\\Users\\(?!user\b|example\b)[^\\\s]+)"
)

RULES = (
    (
        "private-key",
        re.compile(r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"),
    ),
    (
        "github-token",
        re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b"),
    ),
    (
        "aws-access-key",
        re.compile(r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
    ),
    (
        "slack-token",
        re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
    ),
)

GENERIC_SECRET_RE = re.compile(
    r"""(?ix)
    ["']?
    \b(password|passwd|token|api[_-]?key|client[_-]?secret|access[_-]?key|secret)\b
    ["']?\s*[:=]\s*
    (?:
        "([^"\r\n]{8,})"
        | '([^'\r\n]{8,})'
        | ((?:\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\{\{[^{}\r\n]+\}\}|<[A-Za-z0-9_.:-]+>)(?=$|[\s"'#,}\]])|[^\s"'#,}\]]{8,})
    )
    """
)

TEMPLATE_SECRET_RE = re.compile(
    r"^(?:\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\{\{[^{}\r\n]+\}\}|<[A-Za-z0-9_.:-]+>)$"
)

SAFE_EMAIL_DOMAINS = {
    "example.com",
    "example.net",
    "example.org",
    "users.noreply.github.com",
}

SAFE_SECRET_VALUES = {
    "changeme",
    "change-me",
    "dummy",
    "example",
    "placeholder",
    "redacted",
    "xxxxxxxx",
}


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def outgoing_commits(
    base: str,
    head: str,
    remote_name: str | None = None,
    current_refs: list[str] | None = None,
) -> list[str]:
    if head == ZERO_SHA:
        return []

    if base and base != ZERO_SHA:
        output = git("rev-list", "--reverse", f"{base}..{head}")
        return [line for line in output.splitlines() if line]

    if current_refs:
        current = set(current_refs)
        refs = git("for-each-ref", "--format=%(refname)").splitlines()
        other_refs = [ref for ref in refs if ref and ref not in current]
        args = ["rev-list", "--reverse", head]
        if other_refs:
            args.extend(["--not", *other_refs])
        output = git(*args)
    elif remote_name:
        output = git(
            "rev-list",
            "--reverse",
            head,
            "--not",
            f"--remotes={remote_name}",
        )
    else:
        # Safe fallback for a brand-new ref when no destination context is
        # available: scan all commits reachable from the pushed head.
        output = git("rev-list", "--reverse", head)

    return [line for line in output.splitlines() if line]


def changed_paths(commit: str) -> list[str]:
    output = git(
        "diff-tree",
        "--root",
        "--no-commit-id",
        "--name-only",
        "--no-renames",
        "--diff-filter=ACMRTUXB",
        "-r",
        commit,
    )
    return [line for line in output.splitlines() if line]


def added_lines(commit: str):
    patch = git(
        "show",
        "--format=",
        "--unified=0",
        "--no-ext-diff",
        "--text",
        commit,
    )
    path = ""
    for line in patch.splitlines():
        if line.startswith("+++ b/"):
            path = line[6:]
            continue
        if line.startswith("+") and not line.startswith("+++"):
            yield path, line[1:]


def local_markers() -> list[tuple[str, str]]:
    markers: list[tuple[str, str]] = []

    home = os.path.expanduser("~")
    if home and home not in {"/", "/root"}:
        markers.append(("local-home", home))

    user = os.environ.get("USER") or os.environ.get("USERNAME") or ""
    if len(user) >= 5 and user.lower() not in {"runner", "ubuntu", "github"}:
        markers.append(("local-username", user))

    hostname = socket.gethostname().strip()
    if len(hostname) >= 5 and hostname.lower() not in {"localhost"}:
        markers.append(("local-hostname", hostname))

    extra = os.environ.get("PUBLIC_REPO_BLOCKLIST", "")
    for value in extra.splitlines():
        value = value.strip()
        if value:
            markers.append(("custom-blocklist", value))

    return markers


def secret_value_is_placeholder(value: str) -> bool:
    normalized = value.strip("'\"").rstrip(",;")
    lower = normalized.lower()

    if lower in SAFE_SECRET_VALUES:
        return True
    if TEMPLATE_SECRET_RE.fullmatch(normalized):
        return True
    return False


def scan_line(line: str, markers: list[tuple[str, str]]) -> set[str]:
    findings: set[str] = set()

    for name, regex in RULES:
        if regex.search(line):
            findings.add(name)

    for generic in GENERIC_SECRET_RE.finditer(line):
        value = next(
            (group for group in generic.groups()[1:] if group is not None),
            "",
        )
        if value and not secret_value_is_placeholder(value):
            findings.add("credential-assignment")

    for match in EMAIL_RE.finditer(line):
        if match.group(1).lower() not in SAFE_EMAIL_DOMAINS:
            findings.add("email-address")

    if HOME_PATH_RE.search(line):
        findings.add("user-home-path")

    for name, value in markers:
        if value in line:
            findings.add(name)

    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=ZERO_SHA)
    parser.add_argument("--head")
    parser.add_argument("--local-sha")
    parser.add_argument("--remote-sha", default=ZERO_SHA)
    parser.add_argument("--remote-name")
    parser.add_argument("--current-ref", action="append", default=[])
    args = parser.parse_args()

    head = args.head or args.local_sha
    base = args.base if args.head else args.remote_sha

    if not head:
        parser.error("--head or --local-sha is required")

    commits = outgoing_commits(
        base,
        head,
        remote_name=args.remote_name,
        current_refs=args.current_ref,
    )
    if not commits:
        print("public-repo check: no outgoing commits")
        return 0

    markers = local_markers()
    findings: set[tuple[str, str, str]] = set()

    for commit in commits:
        short = commit[:12]

        for path in changed_paths(commit):
            filename = PurePosixPath(path).as_posix()
            if any(pattern.search(filename) for pattern in PRIVATE_FILE_PATTERNS):
                findings.add((short, filename, "sensitive-filename"))

        for path, line in added_lines(commit):
            for kind in scan_line(line, markers):
                findings.add((short, path or "(unknown)", kind))

    if findings:
        print(
            "ERROR: potentially private or secret data found in outgoing commits.",
            file=sys.stderr,
        )
        print("Matched values are intentionally not printed.", file=sys.stderr)
        for commit, path, kind in sorted(findings):
            print(f"  {commit}  {path}  [{kind}]", file=sys.stderr)
        print(
            "Remove the data from every affected commit before pushing.",
            file=sys.stderr,
        )
        return 1

    print(f"public-repo check: OK ({len(commits)} outgoing commit(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
