function I = gray_corr(x, l, avg)
    gray_table = zeros(256, 2);
    for i = 0 : 255
        gray_table(i+1, 1) = i;
        gray_table(i+1, 2) = length(find(x == i));
    end
    addsum = 0;
    for k = 0 : l
        addsum = addsum + k * gray_table(k+1, 2);
    end
    lr = addsum / sum(gray_table(1:l+1, 2));
    index = find(x > lr);
    x(index) = avg;
    I = x;
end