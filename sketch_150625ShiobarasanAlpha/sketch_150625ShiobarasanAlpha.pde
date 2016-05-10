/*
 2015/June/22
 original -> MyLocationMemory
 matsui tadanori
 for Shiobara san
 GPS -> meter
 reference 
 http://log.nissuk.info/2012/04/2.html
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.marker.*;

import http.requests.*;

import java.lang.Math.*;

UnfoldingMap map;
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;
AbstractMapProvider provider5;
DebugDisplay debugDisplay;

//definition of location
Location yagamiLocation = new Location(35.555622f, 139.65392f);
float templat = 35.555622, templon = 139.65392;

//for Shiobara san
float balancelat = templat;
float balancelon = templon;
//Location balanceLocation = new Location(balancelat, balancelon);
SimplePointMarker balanceMarker;
ScreenPosition balancePos; 

//mouse location
Location location;

//location and relation data
int NUMplaces = 100;
Table locationtable; //table for loading lat & lon from table
Table relationtable;
int relationarray[][] = new int[NUMplaces][NUMplaces];

//Place class for address
Place places[] = new Place[NUMplaces];
int stepin = 0;
int tempstepin = 0;
int numberOfAvailablePlaces = 0;

//keyboard input
String input_str = "";
String input_str1 = "";
String input_str2 = "";
boolean inputmode = false;
int input_strflag = 0;

//
int onTimeFlag = 0;



void setup() {
  size(1200, 900);

  provider1 = new Google.GoogleMapProvider();
  provider2 = new Microsoft.AerialProvider();
  provider3 = new StamenMapProvider.Toner();
  provider4 = new OpenStreetMap.OpenStreetMapProvider();
  provider5 = new ThunderforestProvider.Landscape();

  map = new UnfoldingMap(this, "Shiobarasan!!!", provider1);
  map.zoomAndPanTo(yagamiLocation, 16);
  MapUtils.createDefaultEventDispatcher(this, map);

  //create debug display
  debugDisplay = new DebugDisplay(this, map);

  loadLocationTable();
}

void draw() {
  map.draw();
  debugDisplay.draw();

  //Draw marker
  SimplePointMarker yagamiMarker = new SimplePointMarker(yagamiLocation);
  ScreenPosition yagamiPos = yagamiMarker.getScreenPosition(map); //Get x and y from Latitude and longitude

  //draw marker of locationtable
  for (int i = 0; i < locationtable.getRowCount (); i++) {
    places[i].drawMarker();
  }

  //Get Latitude and longitude from mouseX, mouseY
  location = map.getLocation(mouseX, mouseY);
  fill(255);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);

  //draw help
  drawHelp();

  //calculate center of gravity
  calcCenterOfGravity();
  drawDistanceFromCenterOfGravity();
  drawCenterOfGravity();
  drawAxis();
  drawMousePosition();

  //if onTimeFlag is on, interactive mode
  if (onTimeFlag == 1) {    
    stroke(0, 200, 0, 200);
    strokeWeight(3);
    line(balancePos.x, balancePos.y, mouseX, mouseY);
    noStroke();
    fill(0, 100, 0, 200);
    text("" +  nfc((float)Math.abs(getDistancefromGPSvalue(balancelat, balancelon, location.getLat(), location.getLon())), 2), (balancePos.x + mouseX) / 2, (balancePos.y + mouseY) / 2);
  }

  //draw tree structure
  if (treeDrawFlag == 1) {
    drawCalcCluster();
  }

  //if inputmode = true, overlay the inputmode layer
  if (inputmode) {
    drawInputmode();
  }
}  

void mouseClicked() {
  putNewMarker("" + hour() + minute() + second(), mouseX, mouseY);
  loadLocationTable();
}

void keyPressed() {
  if (inputmode) {//input mode
    switch(key) {
    case 8: //backspace
    case 127: //delete
      input_str = "";
      break;
    case '\n': //input_str end
      int foundflag = 0;
      if (input_str.length() > 0) {
        print(input_str);
        for (int i = 0; i < locationtable.getRowCount (); i++) {
          if (input_str.equals(places[i].address)) foundflag++;
        }
        if (foundflag == 0) {
          getDatafromWeb(input_str); //if input_str is not found in location table, get location by Web
          loadLocationTable();
        }
      }
      if (input_strflag == 0) {
        input_str1 = input_str;
        input_str = "";
        input_strflag = 1;
        break;
      } else if (input_strflag ==1) {
        input_str2 = input_str;

        //if multi input come, save the relation between input_str
        if (input_str1.length() >0 &&input_str2.length() >0) {
        }

        input_str = "";
        input_str1 = "";
        input_str2 = "";
        input_strflag = 0;
        inputmode = false; 
        break;
      }
    default:     
      input_str += key;
      break;
    }
  } else { //inputmode = false : normal mode
    switch(key) {
    case '1':
      map.mapDisplay.setProvider(provider1);
      break;
    case '2':
      map.mapDisplay.setProvider(provider2);
      break;
    case '3':
      map.mapDisplay.setProvider(provider3);
      break;
    case '4':
      map.mapDisplay.setProvider(provider4);
      break;
    case '5':
      map.mapDisplay.setProvider(provider5);
      break;
    case 'r':
      map.zoomAndPanTo(yagamiLocation, 16);
      loadLocationTable();
      break;
    case 'p':
      putNewMarker("" + hour() + minute() + second(), mouseX, mouseY);
      loadLocationTable();
      break;
    case 's':
      saveCurrentPlaces();
      break;
    case 'd'://delete current places and reflesh location table
      locationtable = loadTable("locationOriginal.csv", "header");
      saveTable(locationtable, "data/location.csv");
      loadLocationTable();
      break;
    case 'i':
      inputmode = true;
      break;
    case 'o':
      onTimeFlag = 1 - onTimeFlag;
      break;
    case 't':
      treeDrawFlag = 1 - treeDrawFlag;
      break;
    default: 
      break;
    }
  }
}

void calcCenterOfGravity() {
  float sumbalancelat = 0;
  float sumbalancelon = 0; 
  try {
    for (int i = 0; i< numberOfAvailablePlaces; i++) {
      sumbalancelat += places[i].lat;
      sumbalancelon += places[i].lon;
    }
    balancelat = sumbalancelat / (float)numberOfAvailablePlaces;
    balancelon = sumbalancelon / (float)numberOfAvailablePlaces;
    //    println("numberOfAvailablePlaces:" + numberOfAvailablePlaces + " balancelat:" + balancelat+ " balancelon:" + balancelon);
  }
  catch (NullPointerException e) {
  }
  if (onTimeFlag == 1) {    
    balancelat = (sumbalancelat + location.getLat())/((float)numberOfAvailablePlaces + 1);
    balancelon = (sumbalancelon + location.getLon())/((float)numberOfAvailablePlaces + 1);
  }
  balanceMarker = new SimplePointMarker(new Location(balancelat, balancelon));
  balancePos = balanceMarker.getScreenPosition(map); 
  //save real distance from barycenter
  for (int i = 0; i< numberOfAvailablePlaces; i++) {
    //    println(i + " " + places[i].distanceX + " " + places[i].distanceY);
    places[i].distanceFromBarycenter = Math.abs(getDistancefromGPSvalue(balancelat, balancelon, places[i].lat, places[i].lon));
    places[i].distanceX = getDistancefromGPSvalue(places[i].lat, balancelon, places[i].lat, places[i].lon);
    places[i].distanceY = getDistancefromGPSvalue(balancelat, places[i].lon, places[i].lat, places[i].lon);
  }
}

//calc metric disatncew from GPS latitude and longitude
double getDistancefromGPSvalue(float lat1, float lon1, float lat2, float lon2) {
  return getDistancefromGPSvalue((double) lat1, (double) lon1, (double) lat2, (double) lon2);
}
double getDistancefromGPSvalue(double lat1, double lon1, double lat2, double lon2) {
  double r = 6378137; // radius of Equator[m]
  double sgn = 1;
  lat1 = lat1 * PI / 180;
  lon1 = lon1 * PI / 180;
  lat2 = lat2 * PI / 180;
  lon2 = lon2 * PI / 180;
  if (lat2 - lat1 < 0 || lon2 - lon1 < 0) sgn *= -1; //adjust sgn for coordinate
  return sgn * r * Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1));
}

void drawDistanceFromCenterOfGravity() {
  //draw distance from center of gravity
  for (int i = 0; i < locationtable.getRowCount (); i++) {
    places[i].drawLine(balancePos.x, balancePos.y);
    fill(0, 0, 100, 200);
    text("" + nfc((float)places[i].distanceFromBarycenter, 2), (balancePos.x + places[i].x) / 2, (balancePos.y + places[i].y) / 2);
    text("(" + nfc((float)places[i].distanceX, 2) + "," + nfc((float)places[i].distanceY, 2)+")", places[i].x, places[i].y +30);
  }
}

void drawCenterOfGravity() {
  //draw center of gravity marker
  strokeWeight(12);
  stroke(200, 0, 0, 200);
  strokeCap(SQUARE);
  noFill();
  float s = 30;
  arc(balancePos.x, balancePos.y, s, s, -PI *0.9, -PI *0.1);
  arc(balancePos.x, balancePos.y, s, s, PI *0.1, PI *0.9);
  fill(0);
  text("balance", balancePos.x - textWidth("balance") /2, balancePos.y + 4);
}

void drawAxis() {
  //draw center-of-gravity-origined axis
  strokeWeight(1);
  stroke(255, 0, 0, 200);
  line(balancePos.x, 0, balancePos.x, height);
  line(0, balancePos.y, width, balancePos.y);
}

void drawMousePosition() {
  //draw mouse Position
  strokeWeight(12);
  stroke(0, 200, 0, 200);
  strokeCap(SQUARE);
  noFill();
  float s = 30;
  arc(mouseX, mouseY, s, s, -PI *0.9, -PI *0.1);
  arc(mouseX, mouseY, s, s, PI *0.1, PI *0.9);
  fill(0);
}

void drawInputmode() {
  fill(255, 0, 0, 150);
  rect(0, 0, width, height);
  fill(255);
  textFont(loadFont("ComicSansMS-Bold-32.vlw"));
  text("Input Mode", 10, 30);
  noFill();
  text("Input place: " + input_str, width/2 - textWidth("Input place: " + input_str) / 2, height/2);
  text("input_str1: " + input_str1, width/2 - textWidth("input_str1: " + input_str1) / 2, height/2+32);
  text("input_str2: " + input_str2, width/2 - textWidth("input_str2: " + input_str2) / 2, height/2+32+32);
}

void drawHelp() {
  fill(127, 150);
  textFont(loadFont("ComicSansMS-Bold-32.vlw"));
  text("r : back to yagami\np : put new marker\ns : save current places\nd : delete places\ni : input by keyboard\no : mouse mode\nt : tree draw", 0.70 * width, 0.70 * height);
  textSize(12);
}

