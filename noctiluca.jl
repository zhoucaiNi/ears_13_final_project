using DelimitedFiles, StatGeochem, Plots, Statistics, Distributions
include("function.jl")

dino10_22 = importdataset("Dinoflagellate.csv", ',', importas=:Tuple)
argo_2010 = importdataset("temp2010.csv", ',', importas=:Tuple)

noctiluca = dino10_22.TAXON_NAME
noctilucaBio = dino10_22.BIOVOLUME_UM3_L
noctilucaMonth = dino10_22.SAMPLE_MONTH
noctilucaDay = dino10_22.SAMPLE_DAY

noct_indices = []

noct_indices = []
for i=1:length(noctiluca)
    if noctiluca[i] == "Dinophysis acuminata"
        push!(noct_indices, i)
    end
end

noct_indices

sample_year = getByIndex(dino10_22.SAMPLE_YEAR, noct_indices)
sample_year
y = Dict()
intoDictWithArray(y, sample_year, noct_indices)
y
y = sort(y; byvalue=false)
# print(y)

valueByYear = Dict()
timeOfSamples = Dict()

for key in keys(y)
    valueByYear[key] = []
    timeOfSamples[key] = []
    for index in y[key]
        if !isnan(noctilucaBio[index]) && !isnan(noctilucaMonth[index]) && !isnan(noctilucaDay[index])
            push!(valueByYear[key], noctilucaBio[index])
            push!(timeOfSamples[key], noctilucaMonth[index] * 30 + noctilucaDay[index] )
        end
    end
end

valueByYear = sort(valueByYear; byvalue=false)
timeOfSamples = sort(timeOfSamples; byvalue=false)


meanByYear = []

for i=2010:2015
    push!(meanByYear, mean(valueByYear[i]))
end

plot([2010:2015],meanByYear)

phyto_key = collect(keys(valueByYear))
phyto_value = collect(values(valueByYear))

y
noct_indices
plot()
plot(timeOfSamples[2010],valueByYear[2010], label="2010", seriestype=:scatter)
plot!(timeOfSamples[2011],valueByYear[2011], label="2011",seriestype=:scatter)
plot!(timeOfSamples[2012],valueByYear[2012], label="2012",seriestype=:scatter)
plot!(timeOfSamples[2013],valueByYear[2013], label="2013",seriestype=:scatter)
plot!(timeOfSamples[2014],valueByYear[2014], label="2014",seriestype=:scatter)
plot!(timeOfSamples[2015],valueByYear[2015],seriestype=:scatter,
    label="2015",
    legend=:topright)

timeOfSamples[2011]
valueByYear[2011]

histogram(log.(valueByYear[2010]), bins=10, alpha=0.5,label="2010")
histogram!(log.(valueByYear[2011]), bins=10, alpha=0.5,label="2011")
histogram!(log.(valueByYear[2012]), bins=10, alpha=0.5,label="2012")
histogram!(log.(valueByYear[2013]), bins=10, alpha=0.5,label="2013")
histogram!(log.(valueByYear[2014]), bins=10, alpha=0.5,label="2014",)
histogram!(log.(valueByYear[2015]), bins=10, alpha=0.5,label="2015",)

biovolume = getByIndex(dino10_22.BIOVOLUME_UM3_L, noct_indices)
histogram(biovolume)
sample_time = getByIndex(dino10_22.SAMPLE_TIME_UTC, noct_indices)
log10biovolume = log.(biovolume)

plot(log10biovolume)
mean(log10biovolume)
histogram(log10biovolume, bins=20)
extrema(biovolume)

plot(long, lat,
    xlabel="longitude",
    ylabel="latitude",
    # label="$(t)",
    color="blue",
    alpha=0.5,
    seriestype=:scatter)

depth,biovolume  = getTwoVariables(dino10_22.SAMPLE_DEPTH, dino10_22.BIOVOLUME_UM3_L, noct_indices)
plot(depth, log.(biovolume),
    xlabel="depth",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)

lat,biovolume  = getTwoVariables(dino10_22.LATITUDE, dino10_22.BIOVOLUME_UM3_L, noct_indices)
plot(lat, log.(biovolume),
    xlabel="latitude",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)

month,biovolume = getTwoVariables(dino10_22.SAMPLE_MONTH, dino10_22.BIOVOLUME_UM3_L, noct_indices)
plot(month, (biovolume),
    xlabel="month",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)

plot(argo_2010.latitude, argo_2010.temp,
    alpha=0.5,
    seriestype=:scatter)

plot(argo_2010.temp, biovolume,
    xlabel="temp",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)


histogram(log.(biovolume),
        xlabel="biovolume",
        ylabel="")

savefig("latBiovolume.png")
