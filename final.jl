using DelimitedFiles, StatGeochem, Plots, Vega, PyPlot
include("function.jl")

data = importdataset("phytoplankton.csv", ',', importas=:tuple)

A = data.caab_code
# family_name = Set(A)
d = Dict()
intoDict(d, A)
d

d = sort(d; byvalue=true, rev=true)

x = collect(keys(d))
y = collect(values(d))

print(x)

sum_y = sum(y[1:length(y)-10])
top_10_plankton = x[length(x)-9: length(x)]
top_10_number = y[length(y)-9: length(y)]

# Graphing Pie Chart
push!(top_10_plankton,"other(65)")
append!(top_10_number, sum_y)
pie(top_10_plankton,top_10_number, title="phytoplankton diversity", autopct="%.2f" ,shadow=true,legend = :outerleft)
savefig("pie.png")

## Getting year Records

year = data.Year
y = Dict()
intoDict(y, year)
y = sort(y; byvalue=false)
print(y)

x = collect(keys(y))
y = collect(values(y))
plot(x,y)

# ETC

timed = lat_long_graph("Thalassionemataceae", "Purple")

lat, long, UTC = lat_long_graph("Rhizosoleniaceae", "Orange")

anim = @animate for i in 1:length(lat)
    scatter([long[i]], [lat[i]], ms=5, lab="",
    xlim=(0,200), ylim=(-100,0))
end

gif(anim, fps=50)



# lat_long_graph("Ceratiaceae", "Red")
# lat_long_graph("Chaetocerotaceae", "Blue")
# lat_long_graph("Bacillariaceae", "Green")
plot!(legend = :bottomright)

savefig("top5.png")

println("g")
