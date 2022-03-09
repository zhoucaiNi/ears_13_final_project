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
