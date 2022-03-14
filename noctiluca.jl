using DelimitedFiles, StatGeochem, Plots, Statistics, Distributions
include("function.jl")

## Importing data set
dino10_22 = importdataset("Dinoflagellate.csv", ',', importas=:Tuple)
argo_2010 = importdataset("temp2010.csv", ',', importas=:Tuple)

## Getting Columns
phy_taxon = dino10_22.TAXON_NAME
phy_volume = dino10_22.BIOVOLUME_UM3_L
phy_month = dino10_22.SAMPLE_MONTH
phy_day = dino10_22.SAMPLE_DAY

allTaxon = Dict()
intoDict(allTaxon, noctiluca)
allTaxon = sort(allTaxon, byvalue=true, rev=true)

## Filtering phytoplankton

# Dinophysis acuminata - 2141
# Noctiluca scintillans - 1756
# Unid dinoflagellate < 10 Âµm - 1527
# Prorocentrum rhathymum - 1474
# Protoperidinium spp. - 1361
# Tripos carriensis - 577
# Tripos lineatus - 427
# Tripos furca - 571
# Tripos fusus - 531
# Tripos muelleri - 398

top5_list = [
    "Dinophysis acuminata",
    "Noctiluca scintillans",
    "Unid dinoflagellate < 10 Âµm",
    "Prorocentrum rhathymum",
    "Protoperidinium spp.",
    ]

tripos_list = [
    "Tripos carriensis",
    "Tripos lineatus",
    "Tripos furca",
    "Tripos fusus",
    "Tripos muelleri"
]


phytoplankton_taxon = "Tripos muelleri"
phy_indices = []
for i=1:length(noctiluca)
    if noctiluca[i] == phytoplankton_taxon
        push!(phy_indices, i)
    end
end


## getting indices by year and maps it a heat map

sample_year = getByIndex(dino10_22.SAMPLE_YEAR, phy_indices)
indicesByYear = Dict()
intoDictWithArray(indicesByYear, sample_year, phy_indices)
indicesByYear = sort(indicesByYear; byvalue=false)
phyto_map()

##
savefig("$(phytoplankton_taxon)_map.png")
## getting volume by year and time by year

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

##

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

biovolume = getByIndex(dino10_22.BIOVOLUME_UM3_L, phy_indices)
histogram(biovolume)
sample_time = getByIndex(dino10_22.SAMPLE_TIME_UTC, phy_indices)
log10biovolume = log.(biovolume)

plot(log10biovolume)
mean(log10biovolume)
histogram(log10biovolume, bins=20)
extrema(biovolume)

lati,long  = getTwoVariables(dino10_22.LATITUDE, dino10_22.LONGITUDE, phy_indices)
plot(long, lati,
    xlabel="longitude",
    ylabel="latitude",
    # label="$(t)",
    color="blue",
    alpha=0.5,
    seriestype=:scatter)

depth,biovolume  = getTwoVariables(dino10_22.SAMPLE_DEPTH, dino10_22.BIOVOLUME_UM3_L, phy_indices)
plot(depth, log.(biovolume),
    xlabel="depth",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)

lat,biovolume  = getTwoVariables(dino10_22.LATITUDE, dino10_22.BIOVOLUME_UM3_L, phy_indices)
plot(lat, biovolume,
    xlabel="latitude",
    ylabel="biovolume",
    alpha=0.5,
    seriestype=:scatter)

indicesByYear = y
function plotByYear(ind)
    month,biovolume = getTwoVariables(dino10_22.SAMPLE_MONTH, dino10_22.BIOVOLUME_UM3_L, phy_indices)
    plot(month, (biovolume),
        xlabel="month",
        ylabel="biovolume",
        alpha=0.5,
        seriestype=:scatter)
    end


## --- Example: get month vs average volume
function monthVolumePlot(indices, label, t)
    months = 1:12
    sumvolumes = zeros(12)
    N = fill(0, 12)
    for i in indices
        m = Int(phy_month[i])
        v = phy_volume[i]
        if v < 1.5e11
            sumvolumes[m] += isnan(v) ? 0 : v
            N[m] += 1
        end
    end
    volumes = sumvolumes ./ N
    if t == 1
        plot!(months, volumes,label=label)
    else
        plot(months, volumes,label=label)
    end
end
phy_indices
indicesByYear
plot()
monthVolumePlot(phy_indices, "2010-2014")
monthVolumePlot(indicesByYear[2010], "2010", 1)
monthVolumePlot(indicesByYear[2011], "2011", 1)
monthVolumePlot(indicesByYear[2012], "2012", 1)
monthVolumePlot(indicesByYear[2013], "2013", 1)
monthVolumePlot(indicesByYear[2014], "2014", 1)

savefig("$(phytoplankton_taxon)MonthAverageVolumeLog.png")
# monthVolumePlot(indicesByYear[2015], "2015")
##

months = []
sumvolumes = []

for i=1:length(noctilucaBio)
    m = Int(phy_month[i])
    v = phy_volume[i]
    if v < 1.5e11 && !isnan(v) && !isnan(m)
        # sumvolumes[m] += isnan(v) ? 0 : v
        push!(months, m)
        push!(sumvolumes, v)
    end
    # volumes = sumvolumes ./ N
end

months
sumvolumes

plot(months, sumvolumes, seriestype=:scatter)
# plot(phy_month, phy_volume,seriestype=:scatter)
# plot(months, volumes, seriestype=:scatter)


## ---
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

extrema(long)


## Heat Map using bathymetry data

lat = -44:0.1:-18
lon = 135.0:0.1:154

lat = 10:-0.1:-50
lon = 100.0:0.1:160


## Creates a heatmap using bathymetry data and then plots the coordinates of phytoplanktons
function phyto_map()
    plot()
    lati,long  = getTwoVariables(dino10_22.LATITUDE, dino10_22.LONGITUDE, phy_indices)
    lat = -50:0.1:10
    lon = 100:0.1:160
    latm = repeat(lat,1,length(lon))
    lonm = repeat(lon',length(lat),1)
    elevs = find_etopoelev(etopo, latm, lonm)
    reverse_elevs = elevs[end:-1:1,end:-1:1]
    heatmap(elevs)

    lati_converted, long_converted = coordToHeatMap(lati, long, -50, 100)

    plot!(long_converted, lati_converted,
        xlabel="longitude",
        ylabel="latitude",
        label="$(phytoplankton_taxon)",
        color="blue",
        alpha=0.5,
        seriestype=:scatter
        )
end

##
