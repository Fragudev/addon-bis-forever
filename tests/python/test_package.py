"""tools/package.sh: version checks and the version written into the zip."""

import shutil
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "package.sh"


def toc_version(toc_text):
    for line in toc_text.splitlines():
        if line.startswith("## Version: "):
            return line[len("## Version: ") :].strip()
    return None


@unittest.skipUnless(shutil.which("zip") and shutil.which("bash"), "needs bash and zip")
class PackageTest(unittest.TestCase):
    def setUp(self):
        self.work = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.work)
        shutil.copytree(ROOT / "ForeverBiS", self.work / "ForeverBiS")
        self.toc = self.work / "ForeverBiS" / "ForeverBiS.toc"
        self.repo_version = toc_version(self.toc.read_text(encoding="utf-8"))

    def package(self, tag):
        return subprocess.run(["bash", str(SCRIPT), tag], cwd=self.work, capture_output=True, text=True)

    def zipped_toc(self, tag):
        with zipfile.ZipFile(self.work / f"Forever-{tag}.zip") as archive:
            return archive.read("ForeverBiS/ForeverBiS.toc").decode("utf-8")

    def test_beta_tag_must_match_the_toc_version(self):
        tag = self.repo_version.replace("-", "_")
        result = self.package(tag)
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual(self.repo_version, toc_version(self.zipped_toc(tag)))

        wrong = self.package("beta_9.9.9")
        self.assertNotEqual(0, wrong.returncode)
        self.assertIn("does not match tag", wrong.stderr)

    def test_stable_tag_writes_its_version_into_the_zip_only(self):
        result = self.package("v1.0.0")
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("1.0.0", toc_version(self.zipped_toc("v1.0.0")))
        self.assertEqual(self.repo_version, toc_version(self.toc.read_text(encoding="utf-8")))

    def test_rejects_a_malformed_stable_tag(self):
        for tag in ("v1.0", "v1.0.0-rc1", "vx.y.z"):
            result = self.package(tag)
            self.assertNotEqual(0, result.returncode, tag)
            self.assertIn("vX.Y.Z", result.stderr, tag)
            self.assertFalse((self.work / f"Forever-{tag}.zip").exists(), tag)


if __name__ == "__main__":
    unittest.main()
