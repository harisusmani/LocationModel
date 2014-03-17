function time = time_conv(tstamp)
% Credits to Steve Simon for this way of converting Unix Timestamps to
% Date-Time Strings
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/93932

    % offset (serial date number for 1/1/1970)
    % dnOffset = datenum('01-Jan-1970'); %Time in UTC
    dnOffset = datenum('31-Dec-1969 19:00:00'); %Time in EST

    % assuming it's read in as a string originally
    % tstamp = '1393514272'; %Test Case

    % convert to a number, dived by number of seconds
    % per day, and add offset
    dnNow = str2num(tstamp)/(24*60*60) + dnOffset;

    % date string
    time=datestr(dnNow);
end