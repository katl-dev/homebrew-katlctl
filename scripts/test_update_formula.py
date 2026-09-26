import importlib.util
import unittest
from pathlib import Path


spec = importlib.util.spec_from_file_location(
    "update_formula", Path(__file__).with_name("update-formula.py")
)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


def release(tag, prerelease):
    return {"tag_name": tag, "prerelease": prerelease, "draft": False}


class ChannelSelectionTest(unittest.TestCase):
    def test_beta_advances_to_newer_stable(self):
        stable, beta = updater.select_channels([
            release("v2026.9.0-beta.16", True),
            release("v2026.9.0", False),
            release("v2026.8.0", False),
        ])

        self.assertEqual(stable["tag_name"], "v2026.9.0")
        self.assertEqual(beta["tag_name"], "v2026.9.0")

    def test_stable_ignores_newer_beta(self):
        stable, beta = updater.select_channels([
            release("v2026.10.0-beta.2", True),
            release("v2026.9.0", False),
            release("v2026.10.0-beta.1", True),
        ])

        self.assertEqual(stable["tag_name"], "v2026.9.0")
        self.assertEqual(beta["tag_name"], "v2026.10.0-beta.2")

    def test_no_stable_release(self):
        stable, beta = updater.select_channels([
            release("v2026.9.0-rc.1", True),
            release("v2026.9.0-beta.16", True),
            release("v2026.9.0-beta.15", True),
        ])

        self.assertIsNone(stable)
        self.assertEqual(beta["tag_name"], "v2026.9.0-beta.16")

    def test_formulas_share_katlctl_command(self):
        for name, class_name in (("stable", "Stable"), ("beta", "Beta")):
            with self.subTest(name=name):
                formula = updater.render(name, "2026.9.0", {"linux-amd64": "a" * 64})

                self.assertIn(f"class {class_name} < Formula", formula)
                self.assertIn('bin.install Dir["katlctl-*"].fetch(0) => "katlctl"', formula)
                other = "beta" if name == "stable" else "stable"
                self.assertIn(f'conflicts_with "katl-dev/katlctl/{other}"', formula)

    def test_exact_beta_release(self):
        formula = updater.render("beta@2026.9.0-beta.16", "2026.9.0-beta.16",
                                 {"linux-amd64": "a" * 64})

        self.assertIn("class BetaAT202690Beta16 < Formula", formula)
        self.assertIn('version "2026.9.0-beta.16"', formula)
        self.assertIn('bin.install Dir["katlctl-*"].fetch(0) => "katlctl"', formula)

    def test_pins_respect_channel_and_starting_release(self):
        names = [name for name, _ in updater.pinned_formulas([
            release("v2026.9.0-beta.15", True),
            release("v2026.9.0-beta.16", True),
            release("v2026.9.0-beta.17", True),
            release("v2026.9.0", False),
            release("v2026.10.0-rc.1", True),
        ])]

        self.assertEqual(names, [
            "beta@2026.9.0-beta.16",
            "beta@2026.9.0-beta.17",
            "stable@2026.9.0",
            "beta@2026.9.0",
        ])


if __name__ == "__main__":
    unittest.main()
