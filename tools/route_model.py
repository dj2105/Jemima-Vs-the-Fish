"""Reference model for Jemima vs the Fish route rules."""

from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum
from typing import Iterable, Sequence


GRID_WIDTH = 4
GRID_HEIGHT = 3
ROUTE_LENGTH = 4


class Move(IntEnum):
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4


@dataclass(frozen=True)
class Point:
    x: int
    y: int

    def __post_init__(self) -> None:
        if not (0 <= self.x < GRID_WIDTH and 0 <= self.y < GRID_HEIGHT):
            raise ValueError(f"Point outside rod grid: {self}")


def apply_move(point: Point, move: Move) -> Point:
    deltas = {
        Move.UP: (0, -1),
        Move.DOWN: (0, 1),
        Move.LEFT: (-1, 0),
        Move.RIGHT: (1, 0),
    }
    dx, dy = deltas[move]
    return Point(point.x + dx, point.y + dy)


def follow_route(start: Point, route: Sequence[Move]) -> tuple[Point, ...]:
    """Return all positions, including the starting square."""
    if len(route) != ROUTE_LENGTH:
        raise ValueError(f"A route must contain {ROUTE_LENGTH} moves")

    positions = [start]
    current = start
    for move in route:
        current = apply_move(current, move)
        positions.append(current)
    return tuple(positions)


def compare_routes(actual: Sequence[Move], prediction: Sequence[Move]) -> tuple[bool, ...]:
    if len(actual) != ROUTE_LENGTH or len(prediction) != ROUTE_LENGTH:
        raise ValueError(f"Both routes must contain {ROUTE_LENGTH} moves")
    return tuple(a == p for a, p in zip(actual, prediction, strict=True))


def longest_match_streak(matches: Iterable[bool]) -> int:
    best = 0
    current = 0
    for matched in matches:
        current = current + 1 if matched else 0
        best = max(best, current)
    return best


def complete_capture(actual: Sequence[Move], prediction: Sequence[Move]) -> bool:
    """Prototype rule: Jemima captures only by matching all four beats."""
    return all(compare_routes(actual, prediction))
