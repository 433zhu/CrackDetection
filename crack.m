f = imread('./img/crack_1.jpg');
g = rgb2gray(f);
n = 40;
[H, W] = size(g);
H = floor(H / n) * n;
W = floor(W / n) * n;
g = g(1:H, 1:W);
figure, imshow(g);

% mask = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;
% g = imfilter(g, mask);

I = mat2cell(g, n * ones(1, H / n), n * ones(1, W / n));

g_r = cellfun(@mean, cellfun(@mean, I, 'UniformOutput', false));
g_avg = mean(g_r(:));
g_avg_cell = num2cell(round(g_avg) * ones(size(g_r)));
g_min = min(g_r(:));
wr = 0.3 * ones(size(g_r));
index = find(g_r < g_avg);
wr(index) = exp(-abs(g_avg - g_r(index)) / (2 * (g_avg - g_min))) * 0.3;
wr_cell = num2cell(wr);
% lr = cellfun(@find_l, I, wr_cell, 'UniformOutput', false);
% I_corr = cellfun(@gray_corr, I, lr, g_avg_cell, 'UniformOutput', false);
I_corr = cellfun(@gray_corr_2, I, wr_cell, g_avg_cell, 'UniformOutput', false);
g_corr = cell2mat(I_corr);
figure(), imshow(g_corr);

mask = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;
g_ln = imfilter(g_corr, mask);
figure(), imshow(g_ln);

level = graythresh(g_corr);
BW = im2bw(g_corr, level);
figure(), imshow(BW);
