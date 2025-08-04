class BoundaryCondition:
    def __init__(self) -> None:
        pass

    def __repr__(self) -> str:
        return self.__class__.__name__.replace("BoundaryCondition", "") + "()"


class ConnectingBoundaryCondition(BoundaryCondition):
    otherel: int
    """The other element that the boundary condition is shared with."""

    otherf: int
    """The face index on the other element"""

    def __init__(self, otherel, otherf) -> None:
        self.otherel, self.otherf = otherel, otherf
        super().__init__()

    def __repr__(self) -> str:
        return (
            self.__class__.__name__.replace("BoundaryCondition", "")
            + f"({self.otherel}, {self.otherf})"
        )


class InternalBoundaryCondition(ConnectingBoundaryCondition):
    pass


class PeriodicBoundaryCondition(ConnectingBoundaryCondition):
    pass


class DummyPeriodicBoundaryCondition(PeriodicBoundaryCondition):
    def __init__(self) -> None:
        super().__init__(None, None)


class DirichletBoundaryCondition(BoundaryCondition):
    pass


class NeumannBoundaryCondition(BoundaryCondition):
    pass
