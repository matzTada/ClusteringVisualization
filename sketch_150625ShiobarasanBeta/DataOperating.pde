class Place {
  String address;
  float lat, lon;
  float x, y;
  int numberOfLine;
  double distanceFromBarycenter;
  double distanceX, distanceY;
  int memberid;

  //constructa
  Place(String _address, float _lat, float _lon, int _memberid) {
    address = _address;
    lat = _lat;
    lon = _lon;
    numberOfLine = 0;
    memberid = _memberid;
  }
 
  void drawMarker() {
    SimplePointMarker marker = new SimplePointMarker(new Location(lat, lon));
    ScreenPosition pos = marker.getScreenPosition(map);
    x = pos.x;
    y = pos.y;
    float s = 20 + numberOfLine * 5;
    noFill();
    strokeWeight(12);
    strokeCap(SQUARE);
    stroke(0, 0, 255, 100);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);
    strokeWeight(9);
    strokeCap(SQUARE);
    stroke(255, 255, 255, 200);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);
    fill(0, 0, 255);
    textSize(15);
    text(address + " #" + memberid, x - textWidth(address+ " #" + memberid) / 2, y + 4);
  }

  void drawLine(float startx, float starty) {
    stroke(0, 200, 200, 150);
    strokeWeight(3);
    line(startx, starty, x, y);
    noStroke();
  }
}

void putNewMarker(String address, float x, float y) {
  Location templocation = map.getLocation(x, y);
  TableRow newRow = locationtable.addRow();
  newRow.setString("address", address);
  newRow.setFloat("latitude", templocation.getLat());
  newRow.setFloat("longitude", templocation.getLon());
  newRow.setString("date", year() + "/" + month() + "/" + day() + "_" +hour() + ":" +minute() + ":" +second());
  saveTable(locationtable, "data/location.csv");
}

void loadLocationTable() {
  locationtable = loadTable("location.csv", "header");
  println("---Location Table--- #rows=" + locationtable.getRowCount());
  for (TableRow row : locationtable.rows ()) {
    print(row.getString("address") + " ") ;
    print(row.getFloat("latitude") + " ");
    print(row.getFloat("longitude") + " ");
    println(row.getString("date"));
  }

  //redefinition of Places
  int i = 0;
  for (TableRow row : locationtable.rows ()) {
    places[i] = new Place(row.getString("address"), row.getFloat("latitude"), row.getFloat("longitude"), i);
//    println(places[i].lat + " " + places[i].lon);
    i++;
  }
  numberOfAvailablePlaces = i;
}

void saveCurrentPlaces() {
  relationtable = loadTable("relationOriginal.csv", "header");
  for (int i = 0; i <  numberOfAvailablePlaces; i++) { 
    try{
    TableRow newRow = relationtable.addRow();
    newRow.setInt("id", i);
    newRow.setFloat("distanceX", (float)places[i].distanceX);
    newRow.setFloat("distanceY", (float)places[i].distanceY);
    }catch(NullPointerException e){
    }
  }

  println("---Relation Table--- #rows=" + relationtable.getRowCount());  
  for (TableRow row : relationtable.rows ()) {
    print(row.getInt("id") + " ");
    print(row.getFloat("distanceX") + " ");
    println(row.getFloat("distanceY"));
  }
  saveTable(relationtable, "data/relation.csv");
}


