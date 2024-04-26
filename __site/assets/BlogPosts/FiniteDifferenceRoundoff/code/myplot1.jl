# This file was generated, do not modify it. # hide
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