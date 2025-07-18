+++
title = "Machine Precision Effects on Finite Difference Methods"
date = Date(2024, 4, 26)
tags = ["epsilon", "floating", "point", "errors", "numerical", "precision", "finite", "difference"]
+++

\toc

## Approximating Derivatives with Finite Difference Methods
Suppose we have a real-valued function of a single variable $f(x)$, which we can
evaluate for any value of $x$. Suppose we want to compute the derivative of $f$ at a point
$x_0$, but we don't know a general formula for $f'(x)$. We can approximate the
derivative with the following finite difference method:
\[
\label{eq:first_order_finite_difference}
f'(x_0) =  \frac{f(x_0+h) - f(x_0)}{h} + \mathcal{O}(h).
\]

If we ignore the effects of floating point precision, we would choose $h$ to be
as small as possible. Indeed, analytically we have 
\nonumber{$$
f'(x_0) =  \lim_{h \rightarrow 0} \frac{f(x_0+h) - f(x_0)}{h}.
$$}


## Floating Point Issues
Let's try it for $f(x) = e^{2x},$ $x_0 = 1$. In 64-bit floating point precision,
the smallest positive number we can represent is 5e-324.

```julia:./code/ex1
f(x) = exp(2*x)
x0 = 1.0
h = 5e-324
f_derivative_approximation = (f(x0+h) - f(x0))/h
@show f_derivative_approximation
```
\output{./code/ex1}

What gives? We know that $f'(x) = 2e^{2x}$, so we should have $f'(1) = 2e^2 = 14.7781121978613$, but we got
$0$. Well, let's see what happens when we add $x_0$ and $h$.
```julia:./code/ex1
x0 = 1.0
h = 5e-324
@show x0 + h
```
\output{./code/ex1}

We can't represent the number $1 + 5\times 10^{-324}$ in 64-bit floating point
representation. Instead, the value gets rounded off to the nearest number,
which is just $1$. So in our computation we have $f(1+h) = f(1)$, so that
$f(1+h) - f(1) = 0$, and therefore we get $f'(1) = 0$. In fact, we would get
$f'(1) = 0$ for *any* function $f(x)$.

To fix this, let's try the smallest value of $h$ for which $x_0+h \neq x_0$ in
the computer. The function `eps(T)` gives the difference between 1 and the next largest
number of type `T`.
```julia:./code/ex1
h = eps(Float64)
@show h
@show 1+h
```
\output{./code/ex1}

We now have $1+h \neq 1$. Does this fix our issue and give us an accurate
approximation of $f'(1)$? Not quite. 
```julia:./code/ex1
f(x) = exp(2*x)
x0 = 1.0
h = eps(Float64)
f_derivative_approximation = (f(x0+h) - f(x0))/h
f_derivative_analytic = 2*exp(2*x0)
@show h
@show 1+h
@show f_derivative_approximation
@show f_derivative_analytic
```
\output{./code/ex1}

## Choosing an Ideal $h$
We are in the ballpark of the analytic value of $f'(1)$, but our approximation
is off by quite a bit (we don't even have 2 digits of accuracy). What went
wrong? Well, just as $1+5\times 10^{-324}$ is
rounded off to $1$, each of the floating point operations involved in computing
`(f(x0+h) - f(x0))/h` might have some small floating point errors. But even a
small floating point error can result in a large loss of relative precision.

We saw above that machine precision is $\epsilon_M \approx 2 \times 10^{-16}$.
Roughly speaking, this means we have about 16 digits of precision in any number
we represent. Consequently, any number $c$ which we represent may actually be off by
an amount around $c\times\epsilon_M$. We can observe this by increasing the
precision of our floating point numbers:
```julia:./code/ex1
using Quadmath
@show Float64(1.1)
@show Float128(Float64(1.1))
```
\output{./code/ex1}

We see that the 64-bit version of $1.1$ actually stores a number closer to 
$1.1 + 8\times 10^{-17}$. This may not seem like a very big deal since the
error is very small. But one case where the roundoff error becomes a big deal is
in the subtraction of nearly equal numbers. Consider the two nearly equal
numbers $a = 3.3 + 3\times 10^{-16}$ and $b = 3.3$. Analytically, we should have
$a - b = 3\times 10^{-16}$. But let's try performing that computation with
64-bit floating point numbers:
```julia:./code/ex1
a = 3.3000000000000003
b = 3.3
@show a-b
```
\output{./code/ex1}

We expected $a-b = 3\times 10^{-16}$, but we got 
$a-b \approx 4.4 \times 10^{-16}$. Although the error is small compared to $a$
and $b$, it is significant compared to the analytic value of $a-b$. We went from
having 16 digits of precision in $a$ and $b$ to having not even one digit of
precision in $a-b$. This may seem like an extreme example, but we can see
similar effects for something less extreme:
```julia:./code/ex1
a = 3.30003
b = 3.3
@show a-b
```
\output{./code/ex1}
$a$ and $b$ are no longer quite so close, and we have 11 digits of precision in
$a-b$. There is still a noticeable loss of precision, although it is not as
catastrophic as before.

In our finite difference computation, we run the risk of catastrophic loss of
precision when we perform the subtraction $f(x_0+h) - f(x_0)$. Because we take
$h$ to be small, these two numbers may be very close. Let's say the error in the
subtraction is roughly $\epsilon_M f(x_0)$. Then when we try
to perform the finite difference approximation
\eqref{eq:first_order_finite_difference}, what we are actually computing is 
more like
\begin{align*}
f'(x_0) &\approx \frac{f(x_0+h) - f(x_0) + \epsilon_M f(x_0)}{h} + \mathcal{O}(h) \\ 
&= \frac{f(x_0+h) - f(x_0)}{h} + f(x_0)\frac{\epsilon_M}{h} + \mathcal{O}(h).
\end{align*}
The error in our approximation is 
$$
\label{eq:error_eqn}
\textrm{Error} = f'(x_0) - \frac{f(x_0+h) - f(x_0) }{h} = f(x_0)\frac{\epsilon_M}{h} +
\mathcal{O}(h),
$$
where the $f(x_0)\epsilon_M/h$ term is due to floating point errors, and the
$\mathcal{O}(h)$ is the truncation error in our approximation formula.

On the one hand, we want to make $h$ small so that $\mathcal{O}(h)$ is small.
But on the other hand, the smaller we make $h$, the larger we make
$f(x_0)\epsilon_M/h$. To minimize the error in our computation of $f'(x_0)$, we need to
choose $h$ which makes both terms as small as possible. 

We don't know the coefficients in 
\nonumber{$$
\mathcal{O}(h) = C_1 h + C_2 h^2 + C_3 h^3 + \dots.
$$}
If we did know the coefficients, we would have a more accurate approximation
formula. But, for $h \ll 1$, we can at least ignore the higher order terms 
$C_2 h^2, C_3 h^3 \rightarrow 0$ since they decrease much faster than $C_1 h$ as
$h \rightarrow 0$.
Our goal is to make $f(x_0)\epsilon_M/h + C_1 h$ as close to zero as possible.
We don't know the value of $C_1$ (if we did we could perform a higher order
approximation). So instead, let's just ignore the constants $f(x_0)$ and $C_1$,
and set them both equal to 1 (equivalently, we are assuming that $C_1$ is
roughly the same size as $f(x_0)$). These is a very hand-wavey decision, but
without knowing $C_1$ there is not much we can do.

Assuming
$\epsilon, h > 0$, then we are trying to solve
$$
\label{eq:minimize}
\min_h \frac{\epsilon_M}{h} + h.
$$
We can take the derivative with respect to $h$ and set the result equal to zero
to find a critical point:
\begin{align*}
0 &= \frac{d}{dh} \left(\frac{\epsilon}{h} + h\right)  = -\frac{\epsilon}{h^2} + 1 \\
0 &= -\epsilon + h^2 \\
h &= \sqrt{\epsilon}
\end{align*}

Let's assume $\epsilon \approx \epsilon_M$, where $\epsilon_M$ is the machine
precision, as returned by `eps(Float64)`. That is, $\epsilon \approx 10^{-16}$,
giving us
\nonumber{$$
h_{\textrm{ideal}} = 10^{-8}.
$$}
Plugging $h_{\textrm{ideal}}$ back into equation \eqref{eq:error_eqn}, we see that we expect the error to be on the
order of $\epsilon/h + h \approx 10^{-8}$


## Checking Results
These are all rough calculations, so let's check them with a numerical
experiment. Let's compute $f'(x_0)$ using our finite difference approximation
with several values of $h$, and check the relative error in the computed value
compared to the analytic solution.

```julia:myplot1
using Plots
pgfplotsx()
using LaTeXStrings

f(x) = exp(2*x)
fprime_finite_diff(x, h) = (f(x+h) - f(x)) / h

x0 = 1.0
fprime_analytic = 2*exp(2*x0)

h_vals = [10.0 ^ i for i in -15:0.5:-1]
fprime_finite_diff_vals = [fprime_finite_diff(x0, h) for h in h_vals]

fprime_finite_diff_errors = abs.(fprime_finite_diff_vals .- fprime_analytic)
fprime_finite_diff_relative_errors = fprime_finite_diff_errors ./ fprime_analytic

pl = plot(h_vals, fprime_finite_diff_relative_errors,
          xscale=:log10, yscale=:log10, label="Relative Error",
          xlabel=L"h", ylabel="Relative Error",
          title = raw"\bf Finite Difference Approximation of exp(2x)",
          lw=2.5, tickfontsize=18, guidefontsize=24, legendfontsize=18,
          ylims=(1e-15, 1e0), xlims=(1e-15, 1e0),
          yticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          xticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          titlefontsize=24)
vline!(pl, [1e-8], label=raw"h=1e-8")
hline!(pl, [1e-8], label="Error=1e-8")

savefig(pl, joinpath(@OUTPUT, "finite_difference_error.png")) #hide
```
\fig{finite_difference_error}

Indeed, we see that the error is minimized around $h=10^{-8}$, and that the  the
relative error in our approximation at $h=10^{-8}$ is roughly $10^{-8}$, as we
predicted. This is a big improvement over our result when choosing $h$ to be
machine precision, for which the relative error was over $10^{-1}$. In other
words, we went from over 10% error to only 0.0000001% error.

In conclusion, by analyzing the effects of floating point errors in our
computation, we have successfuly obtained a much more accurate finite difference
approximation of $f'(x_0)$ than the one we obtained by simply taking $h$ to be
very small.

## A Simpler Optimization Method
I used calculus to find a critical point of \eqref{eq:minimize}. If we wanted to
be less fancy about finding the minimum, we could have simply plotted each of the terms
in that equation on a log-log scale and found the point where they intersect.
```julia:myplot1
g1(h) = 1e-16 / h
g2(h) = h

h_vals = [10.0 ^ i for i in -15:0.5:-1]
g1_vals = [g1(h) for h in h_vals]
g2_vals = [g2(h) for h in h_vals]

pl = plot(h_vals, g1_vals,
          xscale=:log10, yscale=:log10, 
          xlabel=L"h",
          title = raw"\bf Roundoff vs Approximation Errors",
          label=raw"\epsilon / h (Roundoff Error)",
          lw=2.5, tickfontsize=18, guidefontsize=24, legendfontsize=18,
          ylims=(1e-15, 1e0), xlims=(1e-15, 1e0),
          yticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          xticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          titlefontsize=24)
          
plot!(pl, h_vals, g2_vals, label="h (Approximation Error)")

savefig(pl, joinpath(@OUTPUT, "finite_difference_optimization.png")) #hide
```
\fig{finite_difference_optimization}

We can see that the lines intersect near $h=10^{-8}$, and that the roundoff and
approximation terms both have a value around $10^{-8}$ (which will add up to 
$2 \times 10^{-8}$). This is consistent with our original prediction.

## Higher Accuracy With Second Order Central Difference
What if we decide $10^{-8}$ relative precision is not enough? We can use a
higher-order method to obtain a more accurate result, but then our ideal
value for $h$ will change. Let's consider the second-order central difference
method

\nonumber{$$
f'(x) =  \frac{f(x+h) - f(x-h)}{2h} + \mathcal{O}(h^2).
$$}

Accounting for roundoff errors and ignoring constant factors as we did before,
we get
\nonumber{$$
\textrm{Error} \approx \frac{\epsilon_M}{h} + h^2,
$$}
which can be minimized by choosing
\nonumber{$$
    h_{\textrm{ideal}} = \epsilon_M^{1/3} \approx 10^{-5.3} \implies
    \textrm{Error} \approx 10^{-10.7}.
$$}
```julia:myplot1
f(x) = exp(2*x)
fprime_central_diff(x, h) = (f(x+h) - f(x-h)) / (2*h)

x0 = 1.0
fprime_analytic = 2*exp(2*x0)

h_vals = [10.0 ^ i for i in -15:0.5:-1]
fprime_central_diff_vals = [fprime_central_diff(x0, h) for h in h_vals]

fprime_central_diff_errors = abs.(fprime_central_diff_vals .- fprime_analytic)
fprime_central_diff_relative_errors = fprime_central_diff_errors ./ fprime_analytic

pl2 = plot(h_vals, fprime_central_diff_relative_errors,
          xscale=:log10, yscale=:log10, label="Relative Error",
          xlabel=L"h", ylabel="Relative Error",
          title = raw"\bf Central Difference Approximation of exp(2x)",
          lw=2.5, tickfontsize=18, guidefontsize=24, legendfontsize=18,
          ylims=(1e-15, 1e0), xlims=(1e-15, 1e0),
          yticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          xticks=[1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e0],
          titlefontsize=24)
vline!(pl2, [10.0 ^ (-16/3)], label="h = epsilon")
hline!(pl2, [10.0 ^ (-10.7)], label="Error")

savefig(pl2, joinpath(@OUTPUT, "central_difference_error.png")) #hide
```
\fig{central_difference_error}

We see that our predictions were correct, and we can now approximate $f'(x_0)$
to a relative precision of $\approx 10^{10.7}$, which is more precision than
what we could do with the first-order method.
