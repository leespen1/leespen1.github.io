# This file was generated, do not modify it. # hide
f(x) = exp(2*x)
x0 = 1.0
h = 5e-324
f_derivative_approximation = (f(x0+h) - f(x0))/h
@show f_derivative_approximation