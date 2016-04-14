function [H] = getColumnDistribution(values)
    [H.f,H.xi] = ksdensity(values);
    H.f = H.f / sum(H.f);
end