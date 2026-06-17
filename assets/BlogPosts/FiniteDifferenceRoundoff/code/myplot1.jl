# This file was generated, do not modify it. # hide
f(x) = exp(2*x)
fprime_central_diff(x, h) = (f(x+h) - f(x-h)) / (2*h)

x0 = 1.0
fprime_analytic = 2*exp(2*x0)

h_vals = [10.0 ^ i for i in -15:0.5:0]
fprime_central_diff_vals = [fprime_central_diff(x0, h) for h in h_vals]

fprime_central_diff_errors = abs.(fprime_central_diff_vals .- fprime_analytic)
fprime_central_diff_relative_errors = fprime_central_diff_errors ./ fprime_analytic

fig = Figure(size=(468, 350))
ax = Axis(fig[1, 1],
    xscale=log10, yscale=log10,
    xlabel=L"h", ylabel="Relative Error",
    title=L"Central Difference Approximation of $f(x) = e^{2x}$",
    limits=(1e-15, 1e0, 1e-15, 1e0))
vlines!(ax, [10.0 ^ (-16/3)], linewidth=2, linestyle=:dash, color=Makie.wong_colors()[2], label="h = epsilon")
hlines!(ax, [10.0 ^ (-10.7)], linewidth=2, linestyle=:dash, color=Makie.wong_colors()[3], label="Error")
lines!(ax, h_vals, fprime_central_diff_relative_errors, linewidth=2, color=Makie.wong_colors()[1], label="Relative Error")
Legend(fig[2, 1], ax, framevisible=false, orientation=:horizontal)

save(joinpath(@OUTPUT, "central_difference_error.svg"), fig) #hide