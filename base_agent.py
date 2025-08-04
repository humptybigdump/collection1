import abc


class Agent(abc.ABC):

    @abc.abstractmethod
    def choose(self, observation):
        raise NotImplementedError
