function informationDistance = infodist(X, Y)
%INFODIST Compute the information distance between two random variables
%$X$ and $Y$.
%
% The information distance is computed using kernel-smoothing joint density
% estimation. The output is a real, nonnegative scalar value representing
% the information distance between the inputs $X$ and $Y$.
%
% The information distance $d_{X, Y}$ is given by
% $d_{X, Y} = 1 - \sqrt{1-e^{-2I_{X, Y}}}$, where $I_{X, Y}$ is the mutual
% information between $X$ and $Y$.
%
% The mutual information $I_{X, Y}$ is given by
% $I_{X, Y}=H_X+H_Y-H_{X, Y}$,
% where:
%
% * $H_X$ is the entropy of $X$,
% * $H_Y$ is the entropy of $Y$, and
% * $H_{X, Y}$ is the mutual entropy of $X$ and $Y$.
%
% The entropies are defined as follows.
%
% * $H_X=-\int_{\mathbb{R}}f_X(x)\log f_X(x)dx$, where $f_X$ is the
% probability density function of $X$,
% * $H_Y=-\int_{\mathbb{R}}f_Y(x)\log f_Y(x)dx$, where $f_Y$ is the
% probability density function of $Y$,
% * $H_{X, Y}=-\int_{\mathbb{R}^2}f_{X, Y}(x, y)\log f_{X, Y}(x, y)dxdy$,
% where $f_{X, Y}$ is the joint probability density function of $X$ and
% $Y$.

% Copyright 2016-2026 The MathWorks, Inc.

arguments (Input)
    X(:, 1) double
    Y(:, 1) double
end % arguments (Input)

arguments (Output)
    informationDistance(1, 1) double {mustBeNonnegative, mustBeFinite}
end % arguments (Output)

% Define sample points for the joint density estimation.
x = linspace(min(X), max(X), 250);
y = linspace(min(Y), max(Y), 250);

% Create a grid of sample points.
[Xgrid, Ygrid] = meshgrid(x, y);
pts = [Xgrid(:), Ygrid(:)];

% Estimate the values of the joint probability density function.
fXY = ksdensity([X, Y], pts);
fXY = reshape(fXY, size(Xgrid));

% Estimate the values of the marginal densities.
fX = ksdensity(X, x);
fY = ksdensity(Y, y);

% Compute the integrands, replacing NaNs with zeros if necessary.
integrandXY = fXY .* log(fXY);
integrandXY(isnan(integrandXY)) = 0;
integrandX = fX .* log(fX);
integrandX(isnan(integrandX)) = 0;
integrandY = fY .* log(fY);
integrandY(isnan(integrandY)) = 0;

% Perform the numerical integration to compute the entropies.
HXY =  (-1) * trapz(y, trapz(x, integrandXY, 2));
HX  =  (-1) * trapz(x, integrandX);
HY  =  (-1) * trapz(y, integrandY);

% Compute the mutual information.
IXY = max(HX + HY - HXY, 0);

% Compute the information distance.
informationDistance = 1 - sqrt(1 - exp(-2*IXY));

end % infodist