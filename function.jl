using DelimitedFiles, StatGeochem, Plots, PyPlot

function lat_long_graph(name,color)
    lat = data.Latitude
    long = data.Longitude
    time = data.SampleDateUTC

    plank_lat = []
    plank_long = []
    plank_time = []

    for i=1:length(A)
        if cmp(A[i],"$name") == 0
            push!(plank_lat, lat[i])
            push!(plank_long, long[i])
            push!(plank_time, time[i])
        end
    end

    perm = sortperm(plank_time)
    # merge = [plank_lat[perm], plank_long[perm], plank_time[perm]]
    # print(merge)
    # i = 5
    # @gif for i in 1:5
    # t = plank_time[i]
    # plot([plank_long[perm][i]], [plank_lat[perm][i]],
    #     xlabel="longitude",
    #     ylabel="latitude",
    #     # label="$(t)",
    #     color="$color",
    #     alpha=1,
    #     seriestype=:scatter)
    # end
    # savefig("$name.png")
    return plank_lat[perm], plank_long[perm], plank_time[perm]
end

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
        if noctiluca[i] == phytoplankton_taxon
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
