function  mat=bytarr(varargin)
%function bytarr(d1, d2, ...)
%******** ******
%**
ln=length(varargin);
if ln == 1; sz=i2msizz(varargin{1}); else for i=ln:-1:1; sz(i)=varargin{i}; end; end;
%mat=uint8(zeros(sz));
 mat=      zeros(sz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
