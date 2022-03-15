using DelimitedFiles, StatGeochem, Plots, Polynomials

# turns a set into a dictionary
function intoDict(d, set)
    for i=1:length(set)
        if set[i] != "" || set[i] != NaN
            value = get(d,set[i],0)
            if value == 0
                d[set[i]] = 1
            else
                d[set[i]] = value + 1
            end
        end
end
end

# turns a dictionary with indices
function intoDictWithArray(d, set, indices)
    for i=1:length(set)
        if set[i] != "" || set[i] != NaN
            value = get(d,set[i],0)
            if value == 0
                d[set[i]] = []
                push!(d[set[i]], indices[i])
            else
                push!(d[set[i]], indices[i])
            end
        end
end
end


# get a vector with values using the indices
function getByIndex(array, index)
    res = []
    if (typeof(array[1])) == typeof("String")
        for i in index
            if array[i] != ""
            push!(res,array[i])
        end
        end
    else
    for i in index
        if !isnan(array[i])
        push!(res,array[i])
    end
    end
end
    return res
end

# get two variables
function getTwoVariables(latArray, longArray, index)
    lat = []
    long = []
    for i in index
        if !isnan(latArray[i]) && !isnan(longArray[i])
        push!(lat,latArray[i])
        push!(long, longArray[i])
        end
    end
    return lat, long
end

## Converts lat and long values into values that matches the coordinates in a heat map
function coordToHeatMap(latitude, longitude, latitude_start, longitude_start)
    lati_converted = []
    long_converted = []

    for i=1:length(latitude)
    push!(lati_converted, abs(latitude[i] - latitude_start) / 0.1)
    push!(long_converted, abs(longitude[i] - longitude_start)/ 0.1)
    # push!(lati_converted, abs(lati[i] - rand(-44:-18) )/0.1)
    # push!(long_converted, abs(long[i] - rand(100:160) )/0.1)
    end
    return lati_converted, long_converted
end

## returns all the indices with the taxon_name
function getIndices(taxon_name, allTaxon)
    phytoplankton_taxon = taxon_name
    phy_indices = []
    for i=1:length(allTaxon)
        if allTaxon[i] == phytoplankton_taxon
            push!(phy_indices, i)
        end
    end
    return phy_indices
end

##
function getIndicesByYear(allSampleYear, indices)
    sample_year = getByIndex(allSampleYear, indices)
    indicesByYear = Dict()
    intoDictWithArray(indicesByYear, sample_year, indices)
    indicesByYear = sort(indicesByYear; byvalue=false)
    return indicesByYear
end

##
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
    return volumes
end

## Creates a heatmap using bathymetry data and then plots the coordinates of phytoplanktons
function phyto_map(latitude, longitude, label, etopo)
    # lati,long  = getTwoVariables(dino10_22.LATITUDE, dino10_22.LONGITUDE, phy_indices)
    lat = -50:0.1:10
    lon = 100:0.1:160
    latm = repeat(lat,1,length(lon))
    lonm = repeat(lon',length(lat),1)
    elevs = find_etopoelev(etopo, latm, lonm)
    heatmap(elevs)

    lati_converted, long_converted = coordToHeatMap(latitude, longitude, -50, 100)

    plot!(long_converted, lati_converted,
        label="$(label)",
        color="blue",
        alpha=0.5,
        seriestype=:scatter
        )
end


# Linear regression
function nlin_fit(model, xdata, ydata, p0)

    nlinfit = curve_fit(model, xdata, ydata, p0)
    pfit = nlinfit.param
    print(pfit)
    xlin = range(xdata[1], xdata[end], length=200)

    Plots.scatter(xdata, ydata, markersize=3, legend=:topright, label="data")
    Plots.plot!(xlin, model(xlin, [p0[1], p0[2]]), label="initial model")
    Plots.plot!(xlin, model(xlin, [pfit[1], pfit[2]]), linestyle=:dash, label="fitted model", dpi=200)

    xaxis!("x")
    yaxis!("y")
    title!("nonlinear fit")

end

# Polynomial regression
function poly_fit(xdata, ydata,label)

    pfit1 = Polynomials.fit(xdata, ydata, 1)
    pfit2 = Polynomials.fit(xdata, ydata, 2)
    pfit3 = Polynomials.fit(xdata, ydata, 3)
    pfit4 = Polynomials.fit(xdata, ydata, 4)

    xlin = range(xdata[1], xdata[end], length=300)

    # plotting
    Plots.scatter(xdata, ydata, markersize=3, legend=:topright, label=label)
    plot!(xlin, pfit1.(xlin), linestyle=:dash, label="f(x) = x")
    plot!(xlin, pfit2.(xlin), label="f(x) = x²")
    plot!(xlin, pfit3.(xlin), label="f(x) = x³", dpi=200)
    plot!(xlin, pfit4.(xlin), label="f(x) = x⁴", dpi=200)

    xaxis!("x")
    yaxis!("y")
    title!("poly fit")

end
