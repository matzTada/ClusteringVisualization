
//calculate meter per pixelby map
Location map00location;
Location mapwidthheightlocation;
float lat00;
float lon00;
float latMWH;
float lonMWH;
double meterOfMapWidth;
double PixelPerMeterByWidth;
double meterOfMapHeight;
double PixelPerMeterByHeight;

double meterPerLat10_6; //meter per lat 6 point after the decimal point (per dd.000001)
double meterPerLon10_6; //meter per lon 6 point after the decimal point (per dd.000001)

//2015/11/3 add
double PixelPerMeterMean;

void calcPixelPerMeterOfMap() {
  //calculate meter per pixelby map
  map00location = new Location(map.getLocation(0, 0));
  mapwidthheightlocation = new Location(map.getLocation(width, height));
  lat00 = map00location.getLat();
  lon00 = map00location.getLon();
  latMWH = mapwidthheightlocation.getLat();
  lonMWH = mapwidthheightlocation.getLon();
//  println("lat00 : " + lat00);
//  println("lon00 : " + lon00);
//  println("latMWH : " + latMWH);
//  println("lonMWH : " + lonMWH);

  meterOfMapWidth = getDistancefromGPSvalue(lat00, lon00, lat00, lonMWH);
//  println("meterOfMapWidth : " + meterOfMapWidth); //from 0 to mapwidth
  PixelPerMeterByWidth = width / meterOfMapWidth;
//  println("PixelPerMeterByWidth : " + PixelPerMeterByWidth);

  meterOfMapHeight = getDistancefromGPSvalue(latMWH, lon00, lat00, lon00);
//  println("meterOfMapHeight : " + meterOfMapHeight); 
  PixelPerMeterByHeight = height / meterOfMapHeight;
//  println("PixelPerMeterByHeight : " + PixelPerMeterByHeight);

PixelPerMeterMean = 0.5 * (PixelPerMeterByWidth + PixelPerMeterByHeight);
//  println("PixelPerMeterMean : " + PixelPerMeterMean);


  meterPerLat10_6 = 0.50 * (
  getDistancefromGPSvalue(latMWH, lon00, latMWH + 0.000001, lon00)
    + getDistancefromGPSvalue(latMWH, lonMWH, latMWH + 0.000001, lonMWH)
    );
//  println("meterPer Lat0.000001 : " + meterPerLat10_6);
  meterPerLon10_6 = 0.50 * (
  getDistancefromGPSvalue(latMWH, lon00, latMWH, lon00 + 0.000001)
    + getDistancefromGPSvalue(latMWH, lonMWH, latMWH, lonMWH + 0.000001)
    );
//  println("meterPer Lon0.000001 : " + meterPerLon10_6);
//
//  println(getDistancefromGPSvalue(latMWH, lon00, latMWH + 0.000001, lon00));
//  println(getDistancefromGPSvalue(latMWH, lonMWH, latMWH + 0.000001, lonMWH));
//
//  println(getDistancefromGPSvalue(latMWH, lon00, latMWH, lon00 + 0.000001));
//  println(getDistancefromGPSvalue(latMWH, lonMWH, latMWH, lonMWH + 0.000001));
}

