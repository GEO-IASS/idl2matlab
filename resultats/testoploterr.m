%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File generated by IDL2Matlab V2.0.      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testoploterr()

  a = findgen(100);
  y = 3 .* a + 11;
  z = 2 .* a + 14;
  [a, z, y] = plotterr('I2M_a1', a, 'I2M_a2', z, 'I2M_a3', y, 'I2M_pos', [1, 2, 3]);
  
  %[a, z, y] = oplotterr('I2M_a1', a, 'I2M_a2', z, 'I2M_a3', y, 'I2M_pos', [1, 2, 3]);
  %[a, z] = oplotterr('I2M_a1', a, 'I2M_a2', sin(y), 'I2M_a3', z, 'I2M_pos', [1, 3]);
  %[a, z] = oplotterr('I2M_a1', a, 'I2M_a2', z, 'I2M_pos', [1, 2]);
  
  %[a, z] = oplotterr('I2M_a1', a, 'I2M_a2', z, 'I2M_a3', 5, 'I2M_pos', [1, 2]);
  [a, y] = oplotterr('I2M_a1', a, 'I2M_a2', a .* sin(z), 'I2M_a3', y, 'I2M_a4', 5, 'I2M_pos', [1, 3]);
  %[a, z, y] = oplotterr('I2M_a1', a, 'I2M_a2', z, 'I2M_a3', y, 'I2M_a4', 2, 'I2M_pos', [1, 2, 3]);

return;
% end of function testoploterr
