f = imread('./img/crack_6.jpg');
g = rgb2gray(f);
n = 40;
[H, W] = size(g);
H = floor(H / n) * n;
W = floor(W / n) * n;
f = imcrop(f, [0, 0, W, H]);
figure(), imshow(f), title('原图');
g = g(1:H, 1:W);
figure, imshow(g), title('灰度图');

% mask = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;
% g = imfilter(g, mask);

% 对图像进行分块, 进行预处理
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
figure(), imshow(g_corr), title('预处理后的图像');

% multi-stucture median filtering
b1 = [0, 0, 0; 1, 1, 1; 0, 0, 0];
g_corr_1 = ordfilt2(g_corr, 2, b1);
g_corr_2 = ordfilt2(g_corr_1, 2, b1');
g_corr_3 = ordfilt2(g_corr_2, 2, eye(3)');
g_corr_4 = ordfilt2(g_corr_3, 2, eye(3));
figure(), imshow(g_corr_4), title('中值滤波');

% imporved average filtering
% mask = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;
% g_ln = imfilter(g_corr_4, mask);
% figure(), imshow(g_ln);

% erobe and dilate
% b_s = [0, 0, 0, 1; 0, 1, 1, 0; 1, 0, 0, 0];
% b_s = [0 0 1 0 0; 0 1 1 1 0; 1 1 1 1 1; 0 1 1 1 0; 0 0 1 0 0];
% g_dilate = imdilate(g_corr, b_s);
% g_erode = imerode(g, b_s);
% g_c = g_dilate - g_erode;
% figure(), imshow(g_c);
% g_c_2 = imclose(g_c, b_s);
% figure(), imshow(g_c_2);

% threshold
% level = graythresh(g_c_2);
% BW = im2bw(g_c_2, level);
% figure(), imshow(BW);

se = strel('disk', 5);
se2 = strel('disk', 5);
go = imopen(g_corr_4, se);
g1 = imsubtract(g_corr_4, go);
gc = imclose(g_corr_4, se2);
gb = imbothat(g_corr_4, se2);
g_add = imadd(g_corr_4, imtophat(g_corr_4, se2));
g2 = imsubtract(imadd(g_corr_4, imtophat(g_corr_4, se2)), gb);%增强对比度
figure();
subplot(221), imshow(go), title('开');
subplot(222), imshow(g1), title('tophat');
subplot(223), imshow(gc),title('闭操作');
subplot(224), imshow(gb),title('bothat');
figure(), imshow(g2), title('对比度增强');
% edge
BW2 = edge(g2, 'canny', 0.3);
% BW2 = edge(g_c_2, 'log');
figure(), imshow(BW2), title('canny边缘检测');

se_f = strel('diamond', 4);
crack = imclose(BW2, se_f);
figure(), imshow(crack), title('闭操作');

final = f;
crack = uint8(crack);
final(:, :, 1) = final(:, :, 1) + crack*256;
figure(), imshow(final), title('完成图');
