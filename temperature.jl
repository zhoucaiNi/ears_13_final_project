using DelimitedFiles, StatGeochem, Plots, Statistics, Distributions, LsqFit
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
Plots.savefig("heat_map.png")
plot!(
    long_converted,
    lati_converted,
    # xlabel="longitude",
    # ylabel="latitude",
    label="temperature_argos (2010)",
    seriestype=:scatter
    )
Plots.savefig("filter_temp_argo_2010.png")

Plots.plot(
    filter_lon,
    filter_lat,
    xlabel="longitude",
    ylabel="latitude",
    seriestype=:scatter
    )


lat, lon = coordToHeatMap(lat, lon, -50, 100)
plot!(
    lon,
    lat,
    # xlabel="longitude",
    # ylabel="latitude",
    label="temperature_argos (2010)",
    seriestype=:scatter
    )


## Plotting temperature
filter_temp = []

temp = argo_2010.temp_adjusted
argo_time = argo_2010.juld

for i=1:length(argo_time)
    argo_time[i] = argo_time[i][6:7]
end

argo_time = parse.(Int64, argo_time)

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

Plots.plot(
    months,
    volumes,
    label="Monthly Average Temperature (2010)")

linreg_res = []

for i=1:5
    push!(linreg_res, linreg(volumes, top5_average_monthly_volume[i]))
end

for i=1:5
    println(linreg_res[i])
end

function graphLinearReg(t, label)
    Plots.plot(
        volumes,
        top5_average_monthly_volume[t],
        seriestype=:scatter,
        xlabel = "temperature (celsius)",
        ylabel = "biovolume (µm³/L)",
        label=label
        )

    regression = []
    for i in volumes
        push!(regression,linreg_res[t][1] + (linreg_res[t][2] * i))
    end
    Plots.plot!(
        volumes,
        regression,
        label="linear regression plot ($(linreg_res[t][1]) + $(linreg_res[t][2])x")
end


graphLinearReg(1, top5_list[1])
Plots.savefig("$(top5_list[1])reg.png")

graphLinearReg(2, top5_list[2])
Plots.savefig("$(top5_list[2])reg.png")

graphLinearReg(3, top5_list[3])
Plots.savefig("$(top5_list[3])reg.png")

graphLinearReg(4, top5_list[4])
Plots.savefig("$(top5_list[4])reg.png")

graphLinearReg(5, top5_list[5])
Plots.savefig("$(top5_list[5])reg.png")


# savefig("filter_monthly_temp.png")
xdata = volumes

for i=1:5
    ydata = top5_average_monthly_volume[i]
    poly_fit(xdata, ydata, top5_list[i] )
    Plots.savefig("$(top5_list[i])_poly.png")
end
