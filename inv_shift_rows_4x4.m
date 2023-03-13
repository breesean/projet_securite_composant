function inv_shift_rows = inv_shift_rows_4x4(matrix)
% inverse shiftrows operation of a 4x4 matrix

inv_shift_rows = matrix;
inv_shift_rows(2,:) = circshift(inv_shift_rows(2,:), [0,1]);
inv_shift_rows(3,:) = circshift(inv_shift_rows(3,:), [0,2]);
inv_shift_rows(4,:) = circshift(inv_shift_rows(4,:), [0,3]);

end
