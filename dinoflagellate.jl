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
phy_year = dino10_22.SAMPLE_YEAR
phy_lon = dino10_22.LONGITUDE
phy_lat = dino10_22.LATITUDE
etopo = get_etopo("elevation")

allTaxon = Dict()
intoDict(allTaxon, phy_taxon)
allTaxon = sort(allTaxon, byvalue=true, rev=true)

## Filtering the coordinates
lat_limit = [-44,-18]
lon_limit = [135, 154]

dino_filter_coord_indices = []

for i=1:length(phy_lat)
    currLat = phy_lat[i]
    currLon = phy_lon[i]

    if currLat > lat_limit[1] && currLat < lat_limit[2] && currLon > lon_limit[1] && currLon < lon_limit[2]
        push!(dino_filter_coord_indices, i)
    end
end

dino_filter_lat = []
dino_filter_lon = []
dino_filter_taxon = []

for i in dino_filter_coord_indices
    push!(dino_filter_lat, phy_lat[i])
    push!(dino_filter_lon, phy_lon[i])
    push!(dino_filter_taxon, phy_taxon[i])
end


dino_filter_lat
dino_filter_lon
dino_filter_taxon

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

top5_average_monthly_volume = []

# for taxon in tripos_list
phytoplankton_taxon = tripos_list[2]
phytoplankton_taxon = top5_list[5]

phy_indices = getIndices(phytoplankton_taxon, dino_filter_taxon)

new_lat, new_lon = getTwoVariables(dino_filter_lat, dino_filter_lon, phy_indices)

phyto_map(new_lat, new_lon ,phytoplankton_taxon,etopo)
# savefig("filter_$(phytoplankton_taxon)_map.png")
## getting indices by year and maps it a heat map

indicesByYear = getIndicesByYear(phy_year, phy_indices)
top5_average_monthly_volume = []
for i=1:5
    phytoplankton_taxon = top5_list[i]
    res_volume = monthVolumePlot(indicesByYear[2010], "$(phytoplankton_taxon) (2010)", 1)
    push!(top5_average_monthly_volume, res_volume)
end

top5_average_monthly_volume
Plots.savefig("filter_$(phytoplankton_taxon)_monthlyVolume.png")

for taxon in tripos_list
    phytoplankton_taxon = taxon
    phy_indices = getIndices(phytoplankton_taxon, phy_taxon)
    phyto_map(new_lat, new_lon, phytoplankton_taxon ,etopo)
    Plots.savefig("$(phytoplankton_taxon)_map.png")
end
