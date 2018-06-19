f = imread('./img/crack_2.jpg');
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

% multi-stucture median filtering
b1 = [0, 0, 0; 1, 1, 1; 0, 0, 0];
g_corr_1 = ordfilt2(g, 2, b1);
g_corr_2 = ordfilt2(g_corr_1, 2, b1');
g_corr_3 = ordfilt2(g_corr_2, 2, eye(3)');
g_corr_4 = ordfilt2(g_corr_3, 2, eye(3));

% imporved average filtering
mask = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;
g_ln = imfilter(g_corr_4, mask);
figure(), imshow(g_ln);

% erobe and dilate
% b_s = [0, 0, 0, 1; 0, 1, 1, 0; 1, 0, 0, 0];
b_s = [0 0 1 0 0; 0 1 1 1 0; 1 1 1 1 1; 0 1 1 1 0; 0 0 1 0 0];
g_dilate = imdilate(g, b_s);
g_erode = imerode(g, b_s);
g_c = g_dilate - g_erode;
figure(), imshow(g_c);
g_c_2 = imclose(g_c, b_s);
figure(), imshow(g_c_2);

% threshold
level = graythresh(g_c_2);
BW = im2bw(g_c_2, level);
figure(), imshow(BW);

% edge
BW2 = edge(g_c_2, 'log');
figure(), imshow(BW2);

% BW2 = ~BW;
% BW2 = bwareaopen(BW2, 100, 8);
% BW3 = edge(BW2, 'log');
% figure(), imshow(~BW2);
% % figure(), imshow(BW3);
