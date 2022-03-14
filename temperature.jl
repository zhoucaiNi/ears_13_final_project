using DelimitedFiles, StatGeochem, Plots, Statistics, Distributions
include("function.jl")

## Importing dataset
argo_2010 = importdataset("temp2010.csv", ',', importas=:Tuple)

## Plotting coordinates
lat = argo_2010.latitude
lon = argo_2010.longitude

lat_limit = [-44,-18]
lon_limit = [135, 154]

filter_coord_indices = []

for i=1:length(lat)
    currLat = lat[i]
    currLon = lon[i]

    if currLat > lat_limit[1] && currLat < lat_limit[2] && currLon > lon_limit[1] && currLon < lon_limit[2]
        if find_etopoelev(etopo, currLat, currLon)[1]  > -3000
            push!(filter_coord_indices, i)
        end
    end
end

filter_coord_indices

filter_lat = []
filter_lon = []

for i in filter_coord_indices
    push!(filter_lat, lat[i])
    push!(filter_lon, lon[i])
end

# lati,long  = getTwoVariables(dino10_22.LATITUDE, dino10_22.LONGITUDE, phy_indices)
lati_converted, long_converted = coordToHeatMap(filter_lat, filter_lon, -50, 100)
lat = -50:0.1:10
lon = 100:0.1:160
latm = repeat(lat,1,length(lon))
lonm = repeat(lon',length(lat),1)
elevs = find_etopoelev(etopo, latm, lonm)
heatmap(elevs)
plot!(
    long_converted,
    lati_converted,
    # xlabel="longitude",
    # ylabel="latitude",
    label="temperature_argos (2010)",
    seriestype=:scatter
    )
savefig("filter_temp_argo_2010.png")

filter_lon
filter_lat
plot(
    filter_lon,
    filter_lat,
    xlabel="longitude",
    ylabel="latitude",
    seriestype=:scatter
    )


## Plotting temperature
filter_temp = []

temp = argo_2010.temp_adjusted
argo_time = argo_2010.juld

for i=1:length(argo_time)
    argo_time[i] = parse(Int64, argo_time[i][6:7])
end

argo_time = parse.(Float64, argo_time)


months = 1:12
sumvolumes = zeros(12)
N = fill(0, 12)
for i in filter_coord_indices
    m = Int(argo_time[i])
    v = temp[i]
    sumvolumes[m] += isnan(v) ? 0 : v
    N[m] += 1
    end
end
volumes = sumvolumes ./ N

plot(
    months,
    volumes,
    label="Monthly Average Temperature (2010)")

savefig("filter_monthly_temp.png")
end
