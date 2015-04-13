%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File generated by IDL2Matlab V2.0.      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testcolor()

  global i2mvs_p % SYSTEM VARIABLES

  x = findgen(10);
  d = dist(25);
  red = d1_array(0,1,1,0,0,1);
  green = d1_array(0,1,0,1,0,1);
  blue = d1_array(0,1,0,0,1,0);
  i2mvs_p.multi = d1_array(0,2,2);
  tvlct(255 .* red,255 .* green,255 .* blue);
  i2mvs_p.color = 4;
  [d] = contourr('I2M_a1', d, 'nlevels', 11, 'color', 2, 'title', 'test contour rouge', 'xtitle', 'axe des x rouge', 'ytitle', 'axe des y rouge', 'I2M_pos', [1]);
  [d] = surfacee('I2M_a1', d, 'color', 3, 'title', 'test surface vert', 'ztitle', 'axe des z vert', 'ytitle', 'axe des y vert', 'xtitle', 'axe des x vert', 'I2M_pos', [1]);
  [d] = shade_surf('I2M_a1', d, 'color', 5, 'title', 'test shade_surf jaune', 'ztitle', 'axe des z jaune', 'ytitle', 'axe des y jaune', 'xtitle', 'axe des x jaune', 'I2M_pos', [1]);
  [x] = plott('I2M_a1', x, 'color', 1, 'title', 'test plot blanc', 'xtitle', 'axe X', 'ytitle', 'axe Y', 'I2M_pos', [1]);
  oplott('I2M_a1', x + 5, 'color', 2);
  xyouts('I2M_a1', 1, 'I2M_a2', 2, 'I2M_a3', 'rouge keyword', 'color', 2);
  xyouts(1,3,'bleu systeme');
  i2mvs_p.color = 5;
  xyouts(1,4,'jaune systeme');
  xyouts('I2M_a1', 1, 'I2M_a2', 5, 'I2M_a3', 'vert keyword', 'color', 3);
  xyouts('I2M_a1', d1_array(5,5), 'I2M_a2', d1_array(1,2), 'I2M_a3', d1_array('bleu keyword','rouge keyword'), 'color', d1_array(4,2));
  testtxt = d1_array('bleu keyword','rouge keyword');
  plotts('I2M_a1', 8, 'I2M_a2', 2, 'color', 2);
  plotts('I2M_a1', d1_array(8,9), 'I2M_a2', d1_array(5,6), 'continue', 1);
  plotts('I2M_a1', 8, 'I2M_a2', 8, 'continue', 1, 'color', 4);
  i2mvs_p.multi = 0;

return;
%% end of function testcolor
