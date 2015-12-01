% Puts the subcarriers in the correct order by moving the four pilots
% (which are at the beginning of h) to their appropriate spots.
function h_ordered = orderSubcarriers(h)
    h_ordered = [h(5:9,:);h(1,:);h(10:22,:);h(2,:);h(23:34,:);h(3,:);h(35:47,:);h(4,:);h(48:52,:)];
end