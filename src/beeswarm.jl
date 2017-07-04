# ---------------------------------------------------------------------------
# Beeswarm plot
@recipe function f(::Type{Val{:beeswarm}}, x, y, z; trim::Bool=false, side::Symbol=:both)
    if !(side in [:both :left :right])
        warn("side (you gave :$side) must be one of :both, :left, or :right")
        side = :both
        info("side set to :$side")
    end
    xsegs, ysegs = Segments(), Segments()
    glabels = sort(collect(unique(x)))
    bw = d[:bar_width]
    bw == nothing && (bw = 0.8)
    for (i,glabel) in enumerate(glabels)
        widths, centers = violin_coords(y[filter(i -> _cycle(x,i) == glabel, 1:length(y))], trim=trim)
        isempty(widths) && continue

        # normalize
        hw = 0.5_cycle(bw, i)
        widths = hw * widths / Plots.ignorenan_maximum(widths)

        # make the violin
        xcenter = Plots.discrete_value!(d[:subplot][:xaxis], glabel)[1]
        if (side==:right)
          xcoords = vcat(widths, zeros(length(widths))) + xcenter
        elseif (side==:left)
          xcoords = vcat(zeros(length(widths)), -reverse(widths)) + xcenter
        else
          xcoords = vcat(widths, -reverse(widths)) + xcenter
        end
        ycoords = vcat(centers, reverse(centers))

        push!(xsegs, xcoords)
        push!(ysegs, ycoords)
    end

    seriestype := :scatter
    x := xsegs.pts
    y := ysegs.pts
    ()
end
Plots.@deps beeswarm scatter
