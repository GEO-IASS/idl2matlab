%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File generated by IDL2Matlab v1.1. %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testorientation()

  global i2mvs_p % SYSTEM VARIABLES

  x = findgen(10);
  i2mvs_p.multi = d1_array(3,2,0,2,1);
  [x] = plott('I2M_a1', x, 'I2M_pos', [1]);
  xyouts('I2M_a1', 2, 'I2M_a2', 5, 'I2M_a3', 'orientation = 35', 'orientation', 35);
  xyouts('I2M_a1', 5, 'I2M_a2', 2, 'I2M_a3', 'orientation = -60', 'orientation', -60);
  xyouts('I2M_a1', 7, 'I2M_a2', 1, 'I2M_a3', 'orientation = 0', 'orientation', 0);
  plott(2 .* x);
  xyouts('I2M_a1', 1, 'I2M_a2', 7, 'I2M_a3', 'orientation = 180', 'orientation', 180);
  i2mvs_p.multi = 0;

return;
% end of function testorientation