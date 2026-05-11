<a id="T_B7F6286A"></a>

# **Exploring Risk Contagion Using Graph Theory and Markov Chains**

Recent financial crises and periods of market volatility have heightened awareness of risk contagion and systemic risk among financial analysts. As a result, financial professionals are often tasked with constructing and analyzing models that will yield insight into the potential impact of risk on investments, portfolios, and business operations.

Several authors have described the use of advanced mathematical and statistical techniques for quantifying the dependent relationships between investments, foreign exchange rates, industrial sectors, or geographical regions [\[1\]\-\[7\]](#M_5F51990A). Bridging the gap between formal methods and a working code implementation is a key challenge for analysts.

This example shows how MATLAB can be used to analyze aspects of risk contagion using various mathematical tools. Topics covered include:

- Data aggregation, preprocessing, and risk benchmarking
- Quantifying dependent relationships between financial variables
- Visualizing the resulting network of dependencies together with proximity information
- Analyzing periods of risk contagion using hidden Markov models

The MATLAB code used in this article is available for [download](https://mathworks.com/matlabcentral/fileexchange/57046-exploring-risk-contagion-using-graph-theory-and-markov-chains-live-editor-version).

*Copyright 2016\-2026 The MathWorks, Inc.*

<!-- Begin Toc -->

## Table of Contents
&#8195;[**Data aggregation and preprocessing.**](#H_24BF13EA)
 
&#8195;&#8195;[Load the data.](#H_CA977519)
 
&#8195;&#8195;[Construct sector benchmarks.](#H_AAD8278F)
 
&#8195;&#8195;[Visualize the sector benchmarks.](#H_40B3CF76)
 
&#8195;&#8195;[Compute the sector benchmark returns and visualize the resulting series.](#H_67389465)
 
&#8195;[Correlation analysis.](#H_0F29BB71)
 
&#8195;&#8195;[Compute dependencies between variables.](#H_DF04AD72)
 
&#8195;&#8195;[Next, compute and visualize the pairwise correlation coefficients.](#H_806CA30F)
 
&#8195;[Visualizing dependencies using graph theory.](#H_16DE5717)
 
&#8195;&#8195;[Convert correlation coefficients to distances.](#H_6F265766)
 
&#8195;&#8195;[Translate the distance information into graph form.](#H_3453CA88)
 
&#8195;&#8195;[Assess the quality of the embedding.](#H_3ADE4F22)
 
&#8195;[Assessing sector importance using graph centrality measures.](#H_DFB09280)
 
&#8195;&#8195;[Compute various centrality metrics derived from the sector tree.](#H_DB41ACA3)
 
&#8195;&#8195;[Highlight the most central node on the tree by changing the color.](#H_BCB32CBD)
 
&#8195;[Visualizing risk contagion via rolling windows.](#H_F368B7FD)
 
&#8195;&#8195;[We also capture the output as a video stream.](#H_48D07410)
 
&#8195;[Now update the data on a rolling basis.](#H_885DF442)
 
&#8195;&#8195;[Finalize the video file.](#H_D39C94C9)
 
&#8195;[Track the central sector over time.](#H_E69D268A)
 
&#8195;&#8195;[Visualize the variation in the central sector over time.](#H_CC35661D)
 
&#8195;&#8195;[Visualize the distribution of the central nodes over the rolling period.](#H_834B8B27)
 
&#8195;[Quantifying dependencies with alternative distance metrics.](#H_88E6C75B)
 
&#8195;&#8195;[Compute the new pairwise distance matrix.](#H_B2D4C1BB)
 
&#8195;&#8195;[Visualize the ratio of the two distance metrics.](#H_287E3DD6)
 
&#8195;&#8195;[Repeat the analysis above using the new distance matrix.](#H_53D6956F)
 
&#8195;&#8195;[Translate the distance information into graph form.](#H_8EDD32F7)
 
&#8195;&#8195;[Compute various centrality metrics derived from the sector tree.](#H_C5423D28)
 
&#8195;&#8195;[Highlight the most central node on the tree by changing its color.](#H_FD613826)
 
&#8195;[Modeling risk contagion using hidden Markov models.](#H_8A05B288)
 
&#8195;&#8195;[Estimate the underlying transition and emission matrices.](#H_29271543)
 
&#8195;&#8195;[Visualise the transition matrix.](#H_8C398165)
 
&#8195;&#8195;[We now obtain the most likely sequence of states.](#H_B510D8AF)
 
&#8195;&#8195;[Visualise the HMM results.](#H_4C884693)
 
&#8195;[Summary and next steps.](#H_B6B25500)
 
<!-- End Toc -->

<a id="H_24BF13EA"></a>

# **Data aggregation and preprocessing.**

We start with a collection of mid\-cap security prices from various countries recorded over the period January 2008–December 2013. Each security comes with associated metadata such as market capitalization, industrial sector, and country. In this article we will be analysing the contagion between different sectors, but it is easy to study alternative groupings – for example, country of origin. We use the normalized market capitalizations to define individual security weights and then aggregate all securities from each sector using a weighted sum. The result is the benchmark price series defined below.

<a id="H_CA977519"></a>

## Load the data.
```matlab
load("MidCapData.mat")
```

<a id="H_AAD8278F"></a>

## Construct sector benchmarks.

Each sector benchmark is the weighted sum of the prices of the stocks within that sector. The weights are defined using the relative market capitalizations of each stock.

```matlab
marketCapWeights = meta.MarketCap / sum(meta.MarketCap);
sectors = categories(meta.Sector);
prices = midcap.Variables;
for k = numel(sectors):-1:1
    % Logical index for the current sector.
    sectorIdx = meta.Sector == sectors{k};
    % Compute each sector benchmark using a weighted sum.
    sectorBenchmarks(:, k) = ...
        prices(:, sectorIdx) * marketCapWeights(sectorIdx);
end % for
```

<a id="H_40B3CF76"></a>

## Visualize the sector benchmarks.
```matlab
figure
hold on
numSectors = numel(sectors);
plotColors = hsv(numSectors);
for k = 1:numSectors
    plot(midcap.Dates, sectorBenchmarks(:, k), ...
        "Color", plotColors(k, :), "LineWidth", 1.5)
end % for
xlabel("Date")
ylabel("Price ($)")
title("Mid-Cap Stocks: Sector Benchmarks")
subtitle("Benchmark price series for the eight industrial sectors", "FontAngle", "italic")
grid on
legend(sectors, "Location", "best")
```

\includegraphics[width=\maxwidth{56.196688409433015em}]{figure_0.png}

<a id="H_67389465"></a>

## Compute the sector benchmark returns and visualize the resulting series.
```matlab
sectorRets = tick2ret(sectorBenchmarks);
figure
hold on
for k = 1:size(sectorRets, 2)
    plot(midcap.Dates(2:end), sectorRets(:, k), ...
        "Color", plotColors(k, :), "LineWidth", 1.5)
end % for
xlabel("Date")
ylabel("Periodic Return")
title("Mid-Cap Stocks: Sector Returns")
subtitle("Benchmark return series for the eight industrial sectors", "FontAngle", "italic")
grid on
legend(sectors, "Location", "southoutside", "NumColumns", 2)
```

\includegraphics[width=\maxwidth{56.196688409433015em}]{figure_1.png}

<a id="H_0F29BB71"></a>

# Correlation analysis.

One of the simplest ways to study dependencies between variables is to compute the correlation matrix of the data. Using the MATLAB [`plotmatrix`](<matlab: doc plotmatrix>) function and the Statistics and Machine Learning Toolbox™ [`corr`](<matlab: doc corr>) function, we can create informative visualizations that indicate the pairwise relationships present in the sector return series data. Examples of these charts are shown below.

The off-diagonal elements in the plot matrix show the pairwise joint distributions, and the diagonal shows the marginal distributions of each variable on a histogram. The correlation coefficients between the industrial sector returns quantify the relative strength of the pairwise linear relationships shown in the plot matrix. 

To investigate more general monotonic relationships between variables, we could compute Kendall’s $\tau$ or Spearman’s $\rho$ coefficient using the `corr` function.

<a id="H_DF04AD72"></a>

## Compute dependencies between variables.

One basic approach for this is to compute the pairwise correlation between the different sectors' return series. First, we visualize the pairwise joint distributions using the `plotmatrix` function. This provides some insight into the pairwise relationships between the variables, as well as the shape of the marginal variable distributions.

```matlab
figure
[~, ax, bigAx] = plotmatrix(sectorRets, "b.");
title(bigAx, "Pairwise Sector Return Distributions")
```

Remove axis tick labels.

```matlab
set(ax, "XTickLabel", "", "YTickLabel", "")
```

Annotate the chart with the sector names.

```matlab
for k = 1:numel(sectors)
    ylabel(ax(k, 1), sectors{k}, "Rotation", 0, ...
        "HorizontalAlignment", "right")
    xlabel(ax(end, k), sectors{k})
end % for
```

\includegraphics[width=\maxwidth{56.196688409433015em}]{figure_2.png}

This chart shows the empirical pairwise relationships between the sector returns.

<a id="H_806CA30F"></a>

## Next, compute and visualize the pairwise correlation coefficients.

This chart is a [`heatmap`](<matlab: doc heatmap>) showing the pairwise sector linear correlation coefficients, highlighting all correlations above a certain threshold value (0.80).

```matlab
sectorCorr = corr(sectorRets);
```

Define a custom colormap.

```matlab
white = [1, 1, 1];
cmap = [turbo(80); repmat(white, 20, 1)];


figure
heatmap(sectors, sectors, sectorCorr, ...
    "ColorLimits", [0, 1], ...
    "Colormap", cmap)
title("Sector Returns Pairwise Correlation")
```

\includegraphics[width=\maxwidth{56.196688409433015em}]{figure_3.png}

<a id="H_16DE5717"></a>

# Visualizing dependencies using graph theory.

It can be difficult to gain insight into risk contagion directly from a correlation matrix. Applying graph theory is an effective technique for quantifying and visualizing the proximity of variables. To measure proximity, we convert correlation coefficients $C$ into distances using a mapping such as $f(C)=1-C$ or $f(C)=\sqrt{2(1-C)}$.

<a id="H_6F265766"></a>

## Convert correlation coefficients to distances.

Correlation coefficients $C$ do not provide a valid distance metric, because they can be negative. However, it is straightforward to transform them into distances, for example by setting $D=1-C$ (as used by the [`pdist`](<matlab: doc pdist>) function with its `"correlation"` parameter). Another commonly used metric is $D=\sqrt{2(1-C)}$.

```matlab
sectorDist = sqrt(2*(1-sectorCorr));
```

Create a heatmap showing the pairwise correlation distances between the different sectors. Note that as the correlation coefficients have a range of $[-1,1]$, the distance $D$ has a possible range of $[0,2]$.

```matlab
figure
heatmap(sectors, sectors, sectorDist, ...
    "ColorLimits", [0, 2], ...
    "Colormap", turbo())
title("Sector Returns Pairwise Distance Chart")
```

\includegraphics[width=\maxwidth{56.196688409433015em}]{figure_4.png}

<a id="H_3453CA88"></a>
## Translate the distance information into graph form.

Assigning the industrial sectors to the nodes of a network, we then join up the nodes via edges with lengths given by the correlation distance. In [1](https://uk.mathworks.com/matlabcentral/fileexchange/57046-exploring-risk-contagion-using-graph-theory-and-markov-chains-live-editor-version)