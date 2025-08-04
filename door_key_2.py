# 'Student 1 (Matriculation no. / Matrikelnr.), Student 2 (Matriculation no. / Matrikelnr.),'

from gymnasium.spaces import Discrete
from minigrid.core.grid import Grid

from environments.custom_minigrid import OneDimensionalMiniGridEnv, CustomActions


class DoorKeyEnv(OneDimensionalMiniGridEnv):

    def __init__(self, max_steps: int = 25):
        super().__init__(max_steps)
        self.actions = CustomActions
        self.action_space = Discrete(len(self.actions))
        self.reward_range = (-1, 10)

    def _reward(self) -> float:
        return -1. + 10. if self.is_success else -1.

    def _gen_grid(self, width, height):
        self.mission = "Reach the goal as fast as possible."
        self.grid = Grid(width, height)

        # Generate the surrounding walls
        self.grid.wall_rect(0, 0, width, height)

        # TODO: Implement the rest of this method
        raise NotImplementedError
