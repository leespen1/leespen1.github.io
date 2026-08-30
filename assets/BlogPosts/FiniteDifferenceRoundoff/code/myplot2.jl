# This file was generated, do not modify it. # hide
g1(h) = 1e-16 / h
g2(h) = h

h_vals = [10.0 ^ i for i in -15:0.5:0]
g1_vals = [g1(h) for h in h_vals]
g2_vals = [g2(h) for h in h_vals]

fig = Figure(size=(468, 350))
ax = Axis(fig[1, 1],
    xscale=log10, yscale=log10,
    xlabel=L"h",
    title="Roundoff vs Approximation Errors", titlefont=:regular,
    limits=(1e-15, 1e0, 1e-15, 1e0))
lines!(ax, h_vals, g1_vals, linewidth=2, color=Makie.wong_colors()[1], label="ε / h (Roundoff Error)")
lines!(ax, h_vals, g2_vals, linewidth=2, color=Makie.wong_colors()[2], label="h (Approximation Error)")
Legend(fig[2, 1], ax, framevisible=false, orientation=:horizontal)

save(joinpath(@OUTPUT, "finite_difference_optimization.svg"), fig) #hide