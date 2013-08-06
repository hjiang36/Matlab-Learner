filename='Image-2013-7-24-19-27-41_1_1.bmp'
raws=imread(filename);
sub_size=128;


cdlx=670;
cdly=728;   
I_lower=double(raws(cdly-sub_size/2:cdly+sub_size/2-1,cdlx-sub_size/2:cdlx+sub_size/2-1));
figure(1);clf
imagesc(I_lower);colormap gray;axis square

% ---- find and process lower circle from I_lower --------------

cdlx=666;
cdly=642;
I_upper=double(raws(cdly-sub_size/2:cdly+sub_size/2-1,cdlx-sub_size/2:cdlx+sub_size/2-1));
figure(2);clf
imagesc(I_upper);colormap gray;axis square

% ---- find and process upper circle from I_upper --------------

