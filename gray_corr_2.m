function I = gray_corr_2(x, wr, avg)
    gray_table = zeros(256, 2);
    for i = 0 : 255
        gray_table(i+1, 1) = i;
        gray_table(i+1, 2) = length(find(x == i));
    end
    l = 256;
    for i = 1 : 256;
        if sum(gray_table(1:i, 2)) >= wr * 1600
            l = i - 1;
            break;
        end
    end
    index_l = find(gray_table(:, 1) <= l+1);
    N = sum(gray_table(index_l, 2));
    if N == 0
        lr = 256;
    else
        lr = sum((index_l - 1) .* gray_table(index_l, 2)) / N;
    end
    index = find(x > lr);
    x(index) = avg;
    I = x;
end