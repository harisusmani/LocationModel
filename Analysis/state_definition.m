state_name={'Home','Sheraz Pizza & Kabob','CVS','K&T Chicken','Pakistan House','University Center','Gates Center for Computer Science','Hunt Library','College of Fine Arts','Scaife Hall','Hamerschlag Hall','Doherty Hall','Carnegie Mellon Cafe'};
state_lat=[40.45262,40.45282,40.45190,40.45178,40.45187,40.44343,40.44353,40.44116,40.44158,40.44173,40.44244,40.44253,40.44257];
state_long=[-79.94877,-79.94933,-79.95160,-79.95254,-79.94909,-79.94202,-79.94461,-79.94377,-79.94291,-79.94717,-79.94665,-79.94451,-79.93994];
state_r=[25,12,30,12,15,80,50,35,45,15,50,70,40];

for i=1:size(state_name,2)
    dstate(i).name=state_name(i);
    dstate(i).lat=state_lat(i);
    dstate(i).long=state_long(i);
    dstate(i).r=state_r(i); %In Meters
end

Max_R=max(state_r);
clear state_name state_lat state_long state_r i

