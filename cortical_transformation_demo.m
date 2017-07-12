
input_im = imread('owl_1.jpg') ;
[im_h , im_w , im_d] = size(input_im) ;

% Set these parameters to fit your experiment
width_visual_angle = 30 ;  
RETINA_PIXDEG = im_w/width_visual_angle ; 
%%%%Initial fixation % default at the center 
row_im_f = floor(im_h/2) ;
col_im_f = floor(im_w/2) ;
%%%%%%% Examples: 
% width_visual_angle = 60 ; 
% RETINA_PIXDEG = im_w/width_visual_angle ;   
% % letter example
% % row_im_f = 313 ;
% % col_im_f = 356 ;
% % face example 
% row_im_f = 293 ;
% col_im_f = 286 ;

map_h = 480;
map_w = 640;
im_project = zeros(map_h,map_w,im_d);
PIX_MM = 76;
x_sign = int32([ones(1,map_w/2),-ones(1,map_w/2)])  ;
y_sign = 1 ; % change this to 1 if you want the image to flip
mask_fill = double(imread('mask_fill.png'));
SC_frame_3  = double(imread('SC_frame.png'));
SC_frame = SC_frame_3(:,:,1:im_d);
for d = 1:im_d  
    priority_map = double(input_im(:,:,d)) ;
    sal_project = zeros(map_h,map_w) ;
    col = 1:map_w ;
    u = abs( ( col - map_w/2 ) / PIX_MM ) ;
    for row=1:map_h
        v = ( ( map_h / 2 ) - row ) ./ PIX_MM ;
        [R,phi] = coll2vis(u,v); %this function contains the formula with parameters than can be changed
        col_diff = int32(RETINA_PIXDEG*R.*cos(phi));
        row_diff = int32(RETINA_PIXDEG*R.*sin(phi));
        col_im = col_im_f + x_sign .* col_diff;
        row_im = row_im_f + y_sign * row_diff;
        acc_index = (row_im > 0 & row_im < im_h & col_im > 0 & col_im < im_w & ( mask_fill(row,:) < 50 ) );
        sal_project(row,acc_index) = diag(priority_map( row_im(acc_index) , col_im(acc_index) ));
    end
    im_project(:,:,d) = sal_project/max(sal_project(:)) ;
end
im_project_frame = im_project;
im_project_frame(SC_frame ~= 0)= SC_frame(SC_frame ~= 0);

imshow(im_project)
%imshow(im_project_frame)
print(gcf, 'owl_cort','-dpng')

