%% illustrate ring operation with gif
% Date: March 8, 2026
N = 7;
frames = 200;   % total frames
fps = 5;       % frames per second

% define intial state of the ring
state = [0 1 0 1 0 1 0];

r_node = 1.3;  % nodes
r_inv  = 1.0;  % inverter center
theta_nodes = linspace(0,2*pi,N+1); theta_nodes(end) = [];
theta_inv   = theta_nodes + pi/N;

% filename = 'ring_oscillator.gif';
% write into video to have better control

% initialize figure
scale_factor = 4;
fig_width = 1080 / scale_factor;   
fig_height = 1080 / scale_factor;

% need to create an invisiable figure to decouple from Mac display
% there will be no display during video, but the figure will be generated
% with set dimension
fig = figure('Color','w','Visible','off');   % invisible figure
ax = axes('Position',[0 0 1 1]); % fills figure completely
axis tight
axis off

v = VideoWriter('ring_oscillator.mp4','MPEG-4');
v.FrameRate = fps;
v.Quality = 100;   % max quality
open(v);
prev_sector = -1;

% parameters for inverter drawing
L_line = 0.2;    % line length
s_tri  = 0.2;    % triangle size
r_dot  = 0.05;   % bubble radius

for k = 1:frames
    cla(ax); hold(ax, 'on');
    hold on; axis equal; axis off;
    xlim([-1.6 1.6]); ylim([-1.6 1.6]);

    % draw ring
    t = linspace(0,2*pi,300);
    plot(r_inv*cos(t), r_inv*sin(t),'k','LineWidth',3)

    % draw nodes
    for i=1:N
        x = r_node*cos(theta_nodes(i));
        y = r_node*sin(theta_nodes(i));
        text(x,y,num2str(state(i)),'HorizontalAlignment','center',...
            'FontSize',24,'FontWeight','bold')
    end

    % draw inverters
    for i=1:N
        x = r_inv*cos(theta_inv(i));
        y = r_inv*sin(theta_inv(i));
        % tangent angle along the ring
        theta = theta_inv(i) + pi/2;
        draw_inverter_ring(x, y, theta, L_line, s_tri, r_dot)
    end

    % moving dot
    theta_dot = 4*pi*(k/frames); % two revolutions
    xd = r_inv*cos(theta_dot);
    yd = r_inv*sin(theta_dot);
    scatter(xd, yd, 200, 'k','filled')

    % detect node crossing
    sector = floor(N*mod(theta_dot,2*pi)/(2*pi));
    if sector ~= prev_sector
        node = mod(sector,N)+1;
        state(node) = ~state(node);
        prev_sector = sector;
    end

    drawnow

    % save to GIF
    % frame = getframe(gcf);
    % im = frame2im(frame);
    % [A,map] = rgb2ind(im,256);
    % if k==1
    %     imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.12);
    % else
    %     imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.12);
    % end

    % save to video
    frame = getframe(ax);
    img = imresize(frame.cdata, [fig_height fig_width]); % explicitly set size
    writeVideo(v,img);

    % --- robust capture using exportgraphics ---
    % tmpfile = [tempname,'.png'];                % temporary file
    % exportgraphics(ax,tmpfile,'BackgroundColor','white','ContentType','image','Resolution',300);
    % img = imread(tmpfile);
    % delete(tmpfile);
    % writeVideo(v,img);
    % img = exportgraphics(ax,'temp.png','BackgroundColor','none','ContentType','image');
    % img = imresize(imread('temp.png'), [vid_height vid_width]); 
    % writeVideo(v,fig);
end

close(v);



function draw_inverter_ring(xc, yc, theta, L_line, s_tri, r_dot)
% Draw inverter along ring tangent
% xc, yc : inverter center
% theta  : tangent angle along ring toward next node
% L_line : line length
% s_tri  : triangle size
% r_dot  : bubble radius

dx = cos(theta); 
dy = sin(theta);

% INPUT LINE (toward previous node)
% x_in = [xc - L_line*dx, xc]; 
% y_in = [yc - L_line*dy, yc];
% plot(x_in, y_in,'k','LineWidth',1.5)

% TRIANGLE (inverter body, along ring)
tri = [-s_tri -s_tri; s_tri 0; -s_tri s_tri];
R = [dx -dy; dy dx];
tri_rot = (R*tri')';
tri_rot(:,1) = tri_rot(:,1) + xc;
tri_rot(:,2) = tri_rot(:,2) + yc;
fill(tri_rot(:,1), tri_rot(:,2),'w','EdgeColor','k','LineWidth',3)

% BUBBLE at the tip of the triangle (output)
% tip of triangle is along +dx,+dy direction from xc,yc
bubble_center_x = xc + dx*s_tri; 
bubble_center_y = yc + dy*s_tri;
t = linspace(0,2*pi,40);
fill(bubble_center_x + r_dot*cos(t), bubble_center_y + r_dot*sin(t), 'w', 'EdgeColor','k','LineWidth',3)

% OUTPUT LINE (toward next node)
% x_out = [bubble_center_x + r_dot*dx, bubble_center_x + r_dot*dx + L_line*dx];
% y_out = [bubble_center_y + r_dot*dy, bubble_center_y + r_dot*dy + L_line*dy];
% plot(x_out, y_out,'k','LineWidth',1.5)
end
