using DelimitedFiles, StatGeochem, Plots, Statistics, Distributions, LsqFit
include("function.jl")

## Importing dataset
argo_2010 = importdataset("temp2010.csv", ',', importas=:Tuple)
etopo = get_etopo("elevation")

## Plotting coordinates
lat = argo_2010.latitude
lon = argo_2010.longitude

# coordinate restrictions
lat_limit = [-44,-18]
lon_limit = [135, 154]

filter_coord_indices = []

# for loop to filter the argo floats to between the coordinate restrictions.
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

# using the indices to make a vector with the actual value
filter_lat = []
filter_lon = []
for i in filter_coord_indices
    push!(filter_lat, lat[i])
    push!(filter_lon, lon[i])
end

## Graphing the temp argos

phyto_map(filter_lat, filter_lon, "temperature_argos (2010)", etopo)

Plots.savefig("filter_temp_argo_2010.png")

## without the heat map
Plots.plot(
    filter_lon,
    filter_lat,
    xlabel="longitude",
    ylabel="latitude",
    seriestype=:scatter
    )

## graphs the average monthly temperature
filter_temp = []

# parsing the time
temp = argo_2010.temp_adjusted
argo_time = argo_2010.juld

# gets the month of the argo_time string

for i=1:length(argo_time)
    argo_time[i] = argo_time[i][6:7]
end

argo_time = parse.(Int64, argo_time)

months = 1:12
sumtemps = zeros(12)
N = fill(0, 12)
for i in filter_coord_indices
    m = Int(argo_time[i])
    v = temp[i]
    sumtemps[m] += isnan(v) ? 0 : v
    N[m] += 1
    end

temps = sumtemps ./ N

Plots.plot(
    months,
    temps,
    label="Monthly Average Temperature (2010)")


## Regression Analyis

linreg_res = []

for i=1:5
    push!(linreg_res, linreg(volumes, top5_average_monthly_volume[i]))
end

# Function to graph the linear regression

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


## Plotting for all the taxon

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

xdata = volumes

## Polynomial regression and plotting
for i=1:5
    ydata = top5_average_monthly_volume[i]
    poly_fit(xdata, ydata, top5_list[i] )
    Plots.savefig("$(top5_list[i])_poly.png")
end
