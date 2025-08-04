classdef AdditiveNoisePolynomialMeasurementModel < AdditiveNoiseMeasurementModel
  % Scalar polynomial system with additive noise
  %
  % Subclassing AdditiveNoiseMeasurementModel makes comuptation more efficient, 
  % but especially for the UKF much different from what is shown in the SI lecture.  
  %
  % For scalar systems only.
  
  properties
    polynomial   % vector describing measurement function (polynomial coefficients) 
    polynomialD1 % derivative of measurement model
   end %properties
  
  
  methods
    
    function obj = AdditiveNoisePolynomialMeasurementModel(polynomial_coefficients)
      % Constructor for initialization.
      
      % Save the polynomial coefficients
      obj.polynomial   = polynomial_coefficients;
      
      % Calculate derivatives of nonlinear measurement function 
      obj.polynomialD1 = polyder(obj.polynomial);
      
    end %function
    
    
    function measurements = measurementEquation(obj, stateSamples)
      arguments
        obj          (1,1) AdditiveNoisePolynomialMeasurementModel
        stateSamples (1,:) double {mustBeReal} % scalar model
      end
      
      % Evaluate the polynomial
      measurements = polyval(obj.polynomial, stateSamples);
      
    end %function
    
    
    function [stateJacobian, stateHessians] = derivative(obj, nominalState)
      arguments
        obj          (1,1) AdditiveNoisePolynomialMeasurementModel
        nominalState (1,:) double {mustBeReal} % scalar model
      end
      
      % Jacobian / Derivative
      stateJacobian = polyval(obj.polynomialD1, nominalState);
      
    end %function
    
  end %methods
  
end %classdef
