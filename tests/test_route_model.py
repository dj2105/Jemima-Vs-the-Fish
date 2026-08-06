import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from route_model import (  # noqa: E402
    Move,
    Point,
    compare_routes,
    complete_capture,
    follow_route,
    longest_match_streak,
)


class RouteModelTests(unittest.TestCase):
    def test_route_reaches_expected_end(self) -> None:
        route = (Move.RIGHT, Move.RIGHT, Move.DOWN, Move.LEFT)
        positions = follow_route(Point(0, 0), route)
        self.assertEqual(positions[-1], Point(1, 1))

    def test_route_cannot_leave_grid(self) -> None:
        with self.assertRaises(ValueError):
            follow_route(Point(0, 0), (Move.LEFT, Move.RIGHT, Move.RIGHT, Move.RIGHT))

    def test_matching_is_per_beat(self) -> None:
        actual = (Move.RIGHT, Move.DOWN, Move.LEFT, Move.UP)
        prediction = (Move.RIGHT, Move.LEFT, Move.LEFT, Move.UP)
        self.assertEqual(compare_routes(actual, prediction), (True, False, True, True))

    def test_longest_streak(self) -> None:
        self.assertEqual(longest_match_streak((True, False, True, True)), 2)

    def test_complete_capture_requires_all_matches(self) -> None:
        route = (Move.RIGHT, Move.DOWN, Move.LEFT, Move.UP)
        self.assertTrue(complete_capture(route, route))
        self.assertFalse(
            complete_capture(route, (Move.RIGHT, Move.DOWN, Move.UP, Move.LEFT))
        )


if __name__ == "__main__":
    unittest.main()
