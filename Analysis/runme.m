clc
clear all

%% IMPORT NEW DATA FILE
%   Used: JSON Parser by François Glineur
%   http://www.mathworks.com/matlabcentral/fileexchange/23393-another-json-parser

%fl = fopen('LocationHistory.json', 'r');
%locationHistory = fscanf(fl, '%c');
%data = parse_json(locationHistory);
%save 'data_imp_date-here.mat'


%% Loading Previously Data
%load 'data_imp_2-27-14.mat'

%% Understanding the Data Formatting Used

% Time Stamps are in Unix Time
%   See a way to Convert them into Date and Time
%   Coordinate with a Calendar to find Day of Week

% j=1;
% for n=1:size(data.locations,2)
%     date_time=time_conv(data.locations{1,n}.timestampMs(1:10));
%     start_time='13-Jan-2014 00:00:00'; %Start from MONDAY
%     end_time='17-Feb-2014 00:00:00'; %End on MONDAY
%     if datenum(date_time)>datenum(start_time) && datenum(date_time)<datenum(end_time)
%         idata.locations{1,j}.time=date_time;
%         idata.locations{1,j}.lat=data.locations{1,n}.latitudeE7/10^7;
%         idata.locations{1,j}.long=data.locations{1,n}.longitudeE7/10^7;
%         idata.locations{1,j}.accuracy=data.locations{1,n}.accuracy;
%         j=j+1;
%     end
% end
% 
% save 'data_of_interest.mat'

%Extracting/Loading Data of Interest
load 'data_of_interest.mat'
clear data locationHistory j date_time fl%Not Required Anymore

%% Defining States (Manually) & Assigning with Bounds
% Understanding the 'Accuracy' measure:
% Is it EXACTLY the Radius in Meters of the Circle to be Drawn Around the
%   Point!!

state_definition

others=0;
slack=0.3; %Leniency for Fitting in Points to the States
%Finding States for All Points
for n=1:size(idata.locations,2)
    found=0;
    for i=1:size(dstate,2)
        if distFrom(idata.locations{1,n}.lat, idata.locations{1,n}.long, dstate(i).lat, dstate(i).long) < (idata.locations{1,n}.accuracy*(1+slack*dstate(i).r/Max_R)) && (idata.locations{1,n}.accuracy<=Max_R)
            idata.locations{1,n}.state_no=i;
            idata.locations{1,n}.state=dstate(i).name;
            found=1;
            break;
        else
            idata.locations{1,n}.state_no=-1;
            idata.locations{1,n}.state='OTHER';
        end
    end
    if found==0
        others=others+1;
    end
end

rejected=others/size(idata.locations,2) %TO Adjust Slack
clear others found rejected i

%% Time Spent in State for Each Day in Each Window
% Window Duration is 30 mins
win_duration=30; %Minutes like 60, 30 or 15

% Time Windows x 7 Days x No. of States
TIME_SPENT=zeros((24*60/win_duration),7,size(dstate,2));

day_index={'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};

for n=size(idata.locations,2)-1:-1:1
    day=datestr(idata.locations{1,n}.time,'ddd');
    for b=1:7 %b is Index for Day
        if sum(day==char(day_index(b)))==3
            break
        end
    end
    
    %Find time differences from start of day, take mod of it
    time_h=hour(idata.locations{1,n}.time);
    time_m=minute(idata.locations{1,n}.time);
    total_mins=time_h*60+time_m;
    a=floor(total_mins/win_duration)+1;
    
    c=idata.locations{1,n}.state_no;
    
    if c~=-1
        if c==idata.locations{1,n+1}.state_no %No State Change/Transition
            TIME_SPENT(a,b,c)=TIME_SPENT(a,b,c)+minute(datenum(idata.locations{1,n}.time)-datenum(idata.locations{1,n+1}.time));
        end
    end
    
end

TIME_SPENT_P=zeros((24*60/win_duration),7,size(dstate,2));
% Converting to Probabilities
for a=1:size(TIME_SPENT,1)
    for b=1:size(TIME_SPENT,2)
        X=TIME_SPENT(a,b,:)./sum(TIME_SPENT(a,b,:));
        if ~isnan(X)
            TIME_SPENT_P(a,b,:)=X;
        end
    end
end
clear X a b c time_h time_m total_mins n day

%% State Transition Table for Markov Chain

% trans_duration=5; %Minutes
% 
% %Calculate for every 5 mins, normalize. Then Sum up and Normalize Again.
% 
% TRANS_TABLE=zeros((24*60/trans_duration),7,size(dstate,2),size(dstate,2));
% prev_known_state=1;
% for n=size(idata.locations,2)-1:-1:1
%     day=datestr(idata.locations{1,n}.time,'ddd');
%     for b=1:7 %b is Index for Day
%         if sum(day==char(day_index(b)))==3
%             break
%         end
%     end
%     
%     %Find time differences from start of day, take mod of it
%     time_h=hour(idata.locations{1,n}.time);
%     time_m=minute(idata.locations{1,n}.time);
%     total_mins=time_h*60+time_m;
%     a=floor(total_mins/trans_duration)+1;
%     
%     cur_state=idata.locations{1,n}.state_no;
%     prev_state=idata.locations{1,n+1}.state_no;
%     if prev_state~=-1
%         prev_known_state=prev_state;
%     end
%     if cur_state~=-1
%         if 1 %cur_state~=prev_known_state %No State Change/Transition
%             TRANS_TABLE(a,b,prev_known_state,cur_state)=TRANS_TABLE(a,b,prev_known_state,cur_state)+1;
%         end
%     end
%     
% end
% 
% TRANS_TABLE_P=zeros((24*60/trans_duration),7,size(dstate,2),size(dstate,2));
% % Converting to Probabilities
% for a=1:size(TRANS_TABLE,1)
%     for b=1:size(TRANS_TABLE,2)
%         for c=1:size(dstate,2)
%             X=TRANS_TABLE(a,b,c,:)./sum(TRANS_TABLE(a,b,c,:));
%             if ~isnan(X)
%                 TRANS_TABLE_P(a,b,c,:)=X;
%             end
%         end
%     end
% end
% clear X a b c time_h time_m total_mins prev_state cur_state prev_known_state n day
% 
% %SUMMING and Normalizing Again - "Under Development"
% sum_windows=36;
% TRANS_TABLE_SUM=zeros((24*60/trans_duration)/sum_windows,7,size(dstate,2),size(dstate,2));
% a=0;
% for b=1:size(TRANS_TABLE_P,2)
%     for c=1:size(TRANS_TABLE_P,3)
%         for d=1:size(TRANS_TABLE_P,4)
%             TRANS_TABLE_SUM(a+1,b,c,d)=sum(TRANS_TABLE_P((a*sum_windows)+1:(a*sum_windows+sum_windows),b,c,d));
%             a=a+1;
%         end
%     end
% end

%% Exporting Data for D3 MAP Tool in CSV

%Defining a CVS Sheet with (24*60/win_duration)*size(dstate,2) Rows and
%7+Lat+Lon+R Columns

PROB_DATA=zeros((24*60/win_duration)*size(dstate,2),10);

for n=1:size(dstate,2)
    PROB_DATA(((24*60/win_duration)*(n-1))+1:((24*60/win_duration)*n),1:7)=TIME_SPENT_P(:,:,n);
    PROB_DATA(((24*60/win_duration)*(n-1))+1:((24*60/win_duration)*n),8)=dstate(n).lat;
    PROB_DATA(((24*60/win_duration)*(n-1))+1:((24*60/win_duration)*n),9)=dstate(n).long;
    PROB_DATA(((24*60/win_duration)*(n-1))+1:((24*60/win_duration)*n),10)=dstate(n).r;
end

%csvwrite('prob_data2.csv',PROB_DATA);
csvwrite_with_headers('prob_data.csv',PROB_DATA,{'Mon','Tue','Wed','Thu','Fri','Sat','Sun','lat','long','rad'});
