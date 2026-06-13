#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS_DIR = ROOT / "skills"
EXPECTED_HEADINGS = [
    "## Summary",
    "## Diagram",
    "## Inputs",
    "## References",
    "## Workflow",
    "## Expected Response Format",
]


def line_no(lines: list[str], text: str) -> int:
    for index, line in enumerate(lines, start=1):
        if line == text:
            return index
    return 0


def section(lines: list[str], heading: str) -> list[str]:
    start = line_no(lines, heading)
    if start == 0:
        return []

    result: list[str] = []
    for line in lines[start:]:
        if line.startswith("## "):
            break
        result.append(line)
    return result


def top_level_headings(lines: list[str]) -> tuple[list[str], bool]:
    headings: list[str] = []
    in_code = False

    for line in lines:
        if line.startswith("```"):
            in_code = not in_code
            continue
        if not in_code and line.startswith("## "):
            headings.append(line)

    return headings, in_code


def frontmatter(lines: list[str], path: Path) -> tuple[dict[str, str], list[str]]:
    errors: list[str] = []
    data: dict[str, str] = {}

    if not lines or lines[0] != "---":
        return data, [f"{path}:1 missing opening frontmatter fence"]

    try:
        end = lines[1:].index("---") + 1
    except ValueError:
        return data, [f"{path}:1 missing closing frontmatter fence"]

    for offset, line in enumerate(lines[1:end], start=2):
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            errors.append(f"{path}:{offset} invalid frontmatter line")
            continue

        key, value = line.split(":", 1)
        data[key.strip()] = value.strip()

    return data, errors


def validate_skill(path: Path) -> list[str]:
    rel = path.relative_to(ROOT)
    lines = path.read_text(encoding="utf-8").splitlines()
    errors: list[str] = []

    metadata, frontmatter_errors = frontmatter(lines, rel)
    errors.extend(frontmatter_errors)

    expected_name = path.parent.name
    if metadata.get("name") != expected_name:
        errors.append(f"{rel}: frontmatter name must be {expected_name!r}")

    description = metadata.get("description")
    if not description:
        errors.append(f"{rel}: missing frontmatter description")
    elif not (
        (description.startswith('"') and description.endswith('"'))
        or (description.startswith("'") and description.endswith("'"))
    ):
        errors.append(f"{rel}: frontmatter description must be quoted")

    if metadata.get("disable-model-invocation") != "true":
        errors.append(f"{rel}: frontmatter disable-model-invocation must be true")

    if metadata.get("user-invocable") != "true":
        errors.append(f"{rel}: frontmatter user-invocable must be true")

    headings, in_code = top_level_headings(lines)
    if in_code:
        errors.append(f"{rel}: unclosed fenced code block")
    if headings != EXPECTED_HEADINGS:
        errors.append(
            f"{rel}: top-level headings must be exactly {EXPECTED_HEADINGS}, got {headings}"
        )

    diagram = section(lines, "## Diagram")
    if not any(line == "```mermaid" for line in diagram):
        errors.append(f"{rel}: ## Diagram must contain a mermaid fenced block")

    references = "\n".join(section(lines, "## References"))
    for match in re.finditer(r"`((?:\.\./)?references/[^`]+|(?:\.\./)[^`]+)`", references):
        target = (path.parent / match.group(1)).resolve()
        try:
            target.relative_to(ROOT)
        except ValueError:
            errors.append(f"{rel}: reference escapes repository: {match.group(1)}")
            continue
        if not target.exists():
            errors.append(f"{rel}: missing referenced file {match.group(1)}")

    return errors


def main() -> int:
    errors: list[str] = []

    if not SKILLS_DIR.is_dir():
        print("skills directory not found", file=sys.stderr)
        return 1

    for skill in sorted(SKILLS_DIR.iterdir()):
        if skill.is_dir():
            skill_file = skill / "SKILL.md"
            if not skill_file.exists():
                errors.append(f"{skill.relative_to(ROOT)}: missing SKILL.md")
                continue
            errors.extend(validate_skill(skill_file))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("Validated skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
