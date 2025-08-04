from gymnasium.spaces import Discrete
from minigrid.core.grid import Grid
from minigrid.core.world_object import Goal, Door

from environments.custom_minigrid import OneDimensionalMiniGridEnv, CustomActions, CustomKey


class DoorKeyEnv(OneDimensionalMiniGridEnv):

    def __init__(self, max_steps: int = 25, render_mode: str = "human"):
        super().__init__(max_steps, render_mode)
        self.actions = CustomActions
        self.action_space = Discrete(len(self.actions))
        self.reward_range = (-1, 10)

    def _gen_grid(self, width, height):
        self.mission = "Reach the goal as fast as possible."
        self.grid = Grid(width, height)

        # Generate the surrounding walls
        self.grid.wall_rect(0, 0, width, height)

        # Place agent
        self.agent_pos = (2, 1)
        self.agent_dir = 0

        # Place key
        self.put_obj(CustomKey(color="purple"), 1, 1)

        # Place locked door
        self.put_obj(Door(is_locked=True, color="purple"), 3, 1)

        # Place goal
        self.put_obj(Goal(), 4, 1)

    def _reward(self) -> float:
        return -1. + 10. if self.is_success else -1.
