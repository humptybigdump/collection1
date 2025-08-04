from gymnasium import register

from .environment_creation import create_fully_observable_door_key, create_partially_observable_door_key

register(
    id="DoorKey-v1",
    entry_point=create_fully_observable_door_key,
)

register(
    id="PartiallyObservableDoorKey-v1",
    entry_point=create_partially_observable_door_key,
)
