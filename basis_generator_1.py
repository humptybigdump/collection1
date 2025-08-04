from abc import ABC, abstractmethod
import numpy as np
import matplotlib.pyplot as plt


class BasisGenerator(ABC):

    def __init__(self, phase_generator, num_basis: int = 10):

        self.num_basis = num_basis
        self.phase_generator = phase_generator

    @abstractmethod
    def basis(self, time):
        pass

    def basis_multi_dof(self, time, num_dof):
        basis_single_dof = self.basis(time)

        basis_multi_dof = np.zeros((basis_single_dof.shape[0] * num_dof, basis_single_dof.shape[1] * num_dof))

        for i in range(num_dof):
            row_indices = slice(i * basis_single_dof.shape[0], (i + 1) * basis_single_dof.shape[0])
            column_indices = slice(i * basis_single_dof.shape[1], (i + 1) * basis_single_dof.shape[1])

            basis_multi_dof[row_indices, column_indices] = basis_single_dof

        return basis_multi_dof


class NormalizedRBFBasisGenerator(BasisGenerator):

    def __init__(self, phase_generator, num_basis=10,
                 basis_bandwidth_factor: int = 3,
                 num_basis_outside: int = 0,
                 ):
        BasisGenerator.__init__(self, phase_generator, num_basis)

        self.basis_bandwidth_factor = basis_bandwidth_factor
        self.n_basis_outside = num_basis_outside

        basis_dist = phase_generator.tau / (self.num_basis - 2 * self.n_basis_outside - 1)

        time_points = np.linspace(-self.n_basis_outside * basis_dist,
                                  phase_generator.tau + self.n_basis_outside * basis_dist,
                                  self.num_basis)

        self.centers = self.phase_generator.phase(time_points)

        tmp_bandwidth = np.hstack((self.centers[1:] - self.centers[0:-1],
                                   self.centers[-1] - self.centers[- 2]))

        # The centers should not overlap too much (makes w almost random due to aliasing effect). Empirically chosen
        self.bandwidth = self.basis_bandwidth_factor / (tmp_bandwidth ** 2)

        self._time = None
        self._basis = None
        self._basis_der = None

    def basis(self, time):

        if isinstance(time, (float, int)):
            time = np.array([time])

        phase = self.phase_generator.phase(time)

        diff_sqr = (phase[:, None] - self.centers[None, :]) ** 2 * self.bandwidth[None, :]
        basis = np.exp(- diff_sqr / 2)

        sum_b = np.sum(basis, axis=1)
        basis = basis / sum_b[:, None]
        return basis
        # return np.array(basis).transpose()

    def basis_and_der(self, time):
        if np.all(time == self._time):
            return self._basis, self._basis_der
        else:
            phase = self.phase_generator.phase(time)

            diffs = phase[:, None] - self.centers[None, :]

            basis = np.exp(- diffs ** 2 * self.bandwidth[None, :] / 2)
            db_dz = - diffs * self.bandwidth[None, :] * basis

            sum_b = np.sum(basis, axis=1)[:, None]
            sum_db_dz = np.sum(db_dz, axis=1)[:, None]

            basis_der = (db_dz * sum_b - basis * sum_db_dz) / sum_b ** 2
            basis = basis / sum_b

            self._time = time
            self._basis = basis
            self._basis_der = basis_der

            return basis, basis_der

    def basis_and_der_multi_dof(self, time, num_dof):
        basis_single_dof, basis_der_single_dof = self.basis_and_der(time)

        basis_multi_dof = np.zeros((basis_single_dof.shape[0] * num_dof, basis_single_dof.shape[1] * num_dof))
        basis_der_multi_dof = np.zeros((basis_der_single_dof.shape[0] * num_dof, basis_der_single_dof.shape[1] * num_dof))

        for i in range(num_dof):
            row_indices = slice(i * basis_single_dof.shape[0], (i + 1) * basis_single_dof.shape[0])
            column_indices = slice(i * basis_single_dof.shape[1], (i + 1) * basis_single_dof.shape[1])

            basis_multi_dof[row_indices, column_indices] = basis_single_dof
            basis_der_multi_dof[row_indices, column_indices] = basis_der_single_dof

        return basis_multi_dof, basis_der_multi_dof

    def plot_single_dof(self, time):
        basis, basis_der = self.basis_and_der(time)
        fig, ax = plt.subplots(1, 2, figsize=(15, 5))
        ax[0].plot(time, basis)
        ax[0].set_xlabel('time')
        ax[0].set_ylabel('basis')
        ax[0].set_title('Basis')

        ax[1].plot(time, basis_der)
        ax[1].set_xlabel('time')
        ax[1].set_ylabel('basis derivative')
        ax[1].set_title('Basis derivative')
        plt.show()
