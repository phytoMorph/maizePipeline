function [error] = mySwellFit(data,X)
    sim = func(X(1),X(2),1:size(data,2));
    error = norm(sim - data);
end

