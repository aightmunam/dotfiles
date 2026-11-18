"""Tests for ai/bin/pr-body-lint (stdlib unittest only)."""
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPT = str(HERE.parent / "bin" / "pr-body-lint")

TERSE = """\
Hand-written note above the block stays out of the check, however long and wordy it happens to be in this paragraph.

<!-- pr:start -->
## Summary

Survey photos are now stored in GCS.

- The app PUTs the bytes straight to GCS.
- URLs are signed with IAM `signBlob`. No private key.

## Flow

```text
POST /projects/{id}/files -> 201 {id, upload_url, expires_at}
  a long code line is fine because code blocks are not prose and carry exact routes, bodies and status codes
```

## Merge danger

- **Door:** two-way. The migration only adds `project_files`.
- **Rollback:** revert.
- **Prod:**
  - Fill the two new imgproxy secrets before the deploy.
<!-- pr:end -->
"""


def run(body):
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "body.md"
        path.write_text(body, encoding="utf-8")
        r = subprocess.run([SCRIPT, str(path)], capture_output=True, text=True)
    return r, str(path)


class PrBodyLintTest(unittest.TestCase):
    def test_terse_body_exits_0(self):
        r, _ = run(TERSE)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(r.stdout, "")

    def test_intro_line_before_block_or_list_is_allowed(self):
        anchor = "No private key.\n"
        body = TERSE.replace(
            anchor,
            anchor + "\nConceptual upload flow:\n\n```text\nA -> B\n```\n"
            "\nAlso changed:\n\n- A NUL in a path id gives 422.\n",
        )
        r, _ = run(body)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_intro_line_directly_before_list_is_allowed(self):
        anchor = "No private key.\n"
        body = TERSE.replace(
            anchor, anchor + "\nAlso changed:\n- A NUL gives 422.\n\nMore prose.\n"
        )
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertNotIn("Also changed:", r.stdout)
        self.assertIn("More prose.", r.stdout)

    def test_long_intro_line_is_prose(self):
        anchor = "No private key.\n"
        intro = "This " + "word " * 12 + "flow:"
        body = TERSE.replace(anchor, anchor + "\n" + intro + "\n\n```text\nA\n```\n")
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)

    def test_intro_line_before_prose_is_prose(self):
        anchor = "No private key.\n"
        body = TERSE.replace(anchor, anchor + "\nAlso:\n\nMore prose here.\n")
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("Also:", r.stdout)

    def test_second_paragraph_exits_1(self):
        body = TERSE.replace(
            "## Flow",
            "The upload URL pins the content type, so GCS refuses a wrong type.\n\n## Flow",
        )
        r, path = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("prose paragraph", r.stdout)
        self.assertIn("The upload URL pins", r.stdout)
        self.assertTrue(all(l.startswith(path + ":") for l in r.stdout.splitlines()))

    def test_bold_field_outside_bullet_exits_1(self):
        body = TERSE.replace("- **Rollback:** revert.", "**Rollback:** revert.")
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("**Rollback:**", r.stdout)

    def test_long_lead_exits_1(self):
        lead = "Survey photos are now stored in GCS. " + "word " * 25
        body = TERSE.replace("Survey photos are now stored in GCS.", lead.strip())
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("lead", r.stdout)

    def test_long_bullet_exits_1(self):
        bullet = "- " + "word " * 26
        body = TERSE.replace("- The app PUTs the bytes straight to GCS.", bullet.strip())
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("bullet has 26 words", r.stdout)

    def test_wrapped_bullet_counts_as_one(self):
        body = TERSE.replace(
            "- The app PUTs the bytes straight to GCS.",
            "- The app PUTs the bytes\n  straight to GCS " + "word " * 20,
        )
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("bullet has", r.stdout)

    def test_no_markers_checks_whole_body(self):
        body = "## Summary\n\nOne line.\n\nA second paragraph of prose.\n"
        r, _ = run(body)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("A second paragraph", r.stdout)

    def test_missing_file_exits_2(self):
        r = subprocess.run(
            [SCRIPT, "/nonexistent/body.md"], capture_output=True, text=True
        )
        self.assertEqual(r.returncode, 2, r.stdout + r.stderr)

    def test_no_args_prints_usage_and_exits_2(self):
        r = subprocess.run([SCRIPT], capture_output=True, text=True)
        self.assertEqual(r.returncode, 2)
        self.assertIn("usage: pr-body-lint FILE", r.stderr)


if __name__ == "__main__":
    unittest.main()
