from abc import ABC
from enum import IntEnum
from typing import SupportsFloat, Any

import numpy as np
import pygame
from gymnasium import spaces
from gymnasium.core import ActType, ObsType
from minigrid.core.mission import MissionSpace
from minigrid.core.world_object import Key
from minigrid.minigrid_env import MiniGridEnv

from environments.constants import IMAGE_OBS_COMPONENT, JUST_PICKED_UP_KEY_OBS_COMPONENT, \
    AGENT_POSITION_OBS_COMPONENT, HOLDS_KEY_OBS_COMPONENT


class OneDimensionalMiniGridEnv(MiniGridEnv, ABC):
    """
    This custom minigrid environments is for 1D ("corridor") environments.

    The available actions in standard minigrid environments differ from what is specified in the tutorial.
    For example, in standard minigrid environments, agents do not `move left` / `move right`.
    Instead, they turn (`left` / `right`) and then move `forward`.
    Moreover, in our environments, the agent can only move in one dimension (left / right).
    We overwrite the standard environments behavior here, to reflect our specification.

    We also modify the environment's render() method in such a way that rectangular environments (such as our corridor)
    are displayed properly.
    """

    def __init__(self, max_steps: int = 25, render_mode: str = "human"):
        super().__init__(
            mission_space=MissionSpace(
                mission_func=lambda: "Reach the goal as fast as possible.",
            ),
            width=6,
            height=3,
            max_steps=max_steps,
            see_through_walls=True,
            agent_pov=False,
            highlight=False,
            render_mode=render_mode,
        )
        self.just_picked_up_key = False
        self.screen_width = 640
        self.screen_height = 320
        self.is_success = False

        self.actions = CustomActions
        self.action_space = spaces.Discrete(3)

        self.observation_space = spaces.Dict(
            {
                IMAGE_OBS_COMPONENT: self.observation_space.get(IMAGE_OBS_COMPONENT),
                JUST_PICKED_UP_KEY_OBS_COMPONENT: spaces.Discrete(2),
                HOLDS_KEY_OBS_COMPONENT: spaces.Discrete(2),
                AGENT_POSITION_OBS_COMPONENT: spaces.Discrete(4),
            }
        )

    MiniGridEnv.metadata.update(
        {"render_fps": 5}
    )

    def reset(self, seed=None, options=None):
        self.is_success = False
        return super().reset(seed=seed, options=options)

    def step(
            self, action: ActType
    ) -> tuple[ObsType, SupportsFloat, bool, bool, dict[str, Any]]:

        if action is None:  # perform None-action
            return self.gen_obs(), 0.0, False, False, {}

        self._increase_step_count()
        self._reset_just_picked_up_key_flag()

        terminated = self._perform_action(action)
        truncated = self._check_max_timesteps_reached()

        self._maybe_render()

        observation = self.gen_obs()

        return observation, self._reward(), terminated, truncated, {}

    def _increase_step_count(self):
        self.step_count += 1

    def _reset_just_picked_up_key_flag(self):
        self.just_picked_up_key = False

    def _perform_action(self, action):
        terminated = False
        if action in (self.actions.left, self.actions.right):
            terminated = self._perform_move(action)
        elif action == self.actions.pickup:
            self._perform_pickup()
        else:
            raise ValueError(f"Unknown action: {action}")
        return terminated

    def _perform_move(self, action):
        fwd_pos, fwd_cell = self._get_forward_pos_and_cell(action)
        self._maybe_open_door(fwd_cell, fwd_pos)
        self._maybe_move(fwd_cell, fwd_pos)
        terminated = self._check_if_terminated(fwd_cell)
        return terminated

    def _get_forward_pos_and_cell(self, action):
        self._update_agent_direction(action)
        fwd_pos = self.front_pos  # Get the position in front of the agent
        fwd_cell = self.grid.get(*fwd_pos)  # Get the contents of the cell in front of the agent
        return fwd_pos, fwd_cell

    def _update_agent_direction(self, action):
        # Turn agent left, if it wants to move left
        if action == self.actions.left:
            self.agent_dir = 2  # TODO: where is defined that 2 = left?
        # Turn agent right, if it wants to move right
        else:
            self.agent_dir = 0  # TODO: where is defined that 0 = right?

    def _maybe_open_door(self, fwd_cell, fwd_pos):
        # Agent automatically tries to open doors (`toggle`) if it moves into door cells,
        # possibly with a key, if it carries one
        if fwd_cell is not None and fwd_cell.type == "door":
            fwd_cell.toggle(self, fwd_pos)

    def _maybe_move(self, fwd_cell, fwd_pos):
        # Agent can move into occupied cells if it can overlap with the object that occupies the cell (e.g. a door)
        if fwd_cell is None or fwd_cell.can_overlap():
            self.agent_pos = tuple(fwd_pos)

    def _check_if_terminated(self, fwd_cell):
        return self._terminated_with_success(fwd_cell) or self._terminated_with_failure(fwd_cell)

    def _terminated_with_success(self, fwd_cell) -> bool:
        terminated = False
        if fwd_cell is not None and fwd_cell.type == "goal":
            terminated = True
            self.is_success = True
        return terminated

    @staticmethod
    def _terminated_with_failure(fwd_cell) -> bool:
        terminated = False
        if fwd_cell is not None and fwd_cell.type == "lava":
            terminated = True
        return terminated

    def _perform_pickup(self):
        current_cell = self.grid.get(*self.agent_pos)
        if current_cell and current_cell.can_pickup():
            if self.carrying is None:
                self.carrying = current_cell
                self.carrying.cur_pos = np.array([-1, -1])
                self.grid.set(*self.agent_pos, None)
                self.just_picked_up_key = True

    def _check_max_timesteps_reached(self):
        truncated = False
        if self.step_count >= self.max_steps:
            truncated = True
        return truncated

    def _maybe_render(self):
        if self.render_mode == "human":
            self.render()

    def render(self):
        """Makes it possible to render rectangular images instead of just square images
        via self.screen_width and self.screen_height instead of self.screen_size."""

        img = self.get_frame(self.highlight, self.tile_size, self.agent_pov)

        if self.render_mode == "human":
            img = np.transpose(img, axes=(1, 0, 2))
            if self.render_size is None:
                self.render_size = img.shape[:2]
            if self.window is None:
                pygame.init()
                pygame.display.init()
                self.window = pygame.display.set_mode(
                    (self.screen_width, self.screen_height)
                )
                pygame.display.set_caption("minigrid")
            if self.clock is None:
                self.clock = pygame.time.Clock()
            surf = pygame.surfarray.make_surface(img)

            # Create background with mission description
            offset = surf.get_size()[0] * 0.1
            # offset = 32 if self.agent_pov else 64
            bg = pygame.Surface(
                (int(surf.get_size()[0] + offset), int(surf.get_size()[1] + offset))
            )
            bg.convert()
            bg.fill((255, 255, 255))
            bg.blit(surf, (offset / 2, 0))

            bg = pygame.transform.smoothscale(bg, (self.screen_width, self.screen_height))

            font_size = 22
            text = self.mission
            font = pygame.freetype.SysFont(pygame.font.get_default_font(), font_size)
            text_rect = font.get_rect(text, size=font_size)
            text_rect.center = bg.get_rect().center
            text_rect.y = bg.get_height() - font_size * 1.5
            font.render_to(bg, text_rect, text, size=font_size)

            self.window.blit(bg, (0, 0))
            pygame.event.pump()
            self.clock.tick(self.metadata["render_fps"])
            pygame.display.flip()

        elif self.render_mode == "rgb_array":
            return img

    def gen_obs(self):
        obs = super().gen_obs()
        self._remove_unnecessary_observation_components(obs)
        self._add_observation_components(obs)
        return obs

    @staticmethod
    def _remove_unnecessary_observation_components(obs):
        del obs["direction"]
        del obs["mission"]

    def _add_observation_components(self, obs):
        obs[HOLDS_KEY_OBS_COMPONENT] = self._holds_key()
        obs[AGENT_POSITION_OBS_COMPONENT] = self._get_agent_position()
        obs[JUST_PICKED_UP_KEY_OBS_COMPONENT] = self.just_picked_up_key

    def _get_agent_position(self):
        return self.agent_pos[0] - 1  # we do not count the wall in position 0

    def _holds_key(self):
        return self.carrying.type == "key" if self.carrying else False

    def put_agent(self, i, j):
        assert 0 <= i < self.width
        assert 0 <= j < self.height
        self.agent_pos = np.array((i, j))


class CustomActions(IntEnum):
    right = 0
    left = 1
    pickup = 2


class CustomKey(Key):
    """
    This custom key object allows the agents to be on the same cell as the key. Agent and key can "overlap".

    The standard "pickup" behavior in minigrid is that the agents faces the object from an adjacent cell and then
    performs the "pickup" action. Agent's cannot enter a cell that contains an object (such as a key).
    Our specification of "pickup" differs from this: We have no notion of agents direction and the agents can only pick
    up an object when it is in the same cell. For this, the two must be able to overlap.
    """

    def can_overlap(self) -> bool:
        return True
