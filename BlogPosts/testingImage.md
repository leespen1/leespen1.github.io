# Test
Testing if I can use Plots to generate an image.
```julia:plot
using Plots
gr()
pl = plot([1,2,3])
savefig(pl, joinpath(@OUTPUT, "MyPlot.png"))
```
\fig{MyPlot}

Did the figure show up?
