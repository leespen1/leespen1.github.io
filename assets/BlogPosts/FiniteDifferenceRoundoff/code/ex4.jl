# This file was generated, do not modify it. # hide
f(x) = exp(2*x)
x0 = 1.0
h = eps(Float64)
f_derivative_approximation = (f(x0+h) - f(x0))/h
f_derivative_analytic = 2*exp(2*x0)
@show h
@show 1+h
@show f_derivative_approximation
@show f_derivative_analytic