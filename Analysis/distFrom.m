function distance= distFrom(lat1, lng1, lat2, lng2)
    % Latitude and Longitude are in Decimal Degrees
    %Ported to MATLAB from:
    %http://stackoverflow.com/questions/837872/calculate-distance-in-meters-when-you-know-longitude-and-latitude-in-java
    %based on the "Haversine Formula"

    earthRadius = 3958.75;
    dLat = toRadians('degrees',lat2-lat1);
    dLng = toRadians('degrees',lng2-lng1);
    a = (sin(dLat/2))^2 + cos(toRadians('degrees',lat1)) * cos(toRadians('degrees',lat2)) * (sin(dLng/2))^2;
    c = 2 * atan(sqrt(a)/sqrt(1-a));
    %c = 2 * atan(sqrt(a));
    dist = earthRadius * c;

    meterConversion = 1609;

    distance= dist * meterConversion;
end