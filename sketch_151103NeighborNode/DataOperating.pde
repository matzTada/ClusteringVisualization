//2015/11/3 new neighborNodes considering
float neighborRadiusMeter = 400; //m this is for the radio reachable value.
float neighborRadius; //pixel for gui calculation

class Node {
  String address;
  float lat, lon;
  float x, y;
  int numberOfLine;
  double distanceFromBarycenter;
  double distanceX, distanceY;
  int memberid;
  ArrayList<Node> neighborNodes;
  int nodeType; //0 for coordinator, 1 for router, 2 for end device

    //constructa
  Node(String _address, float _lat, float _lon, int _memberid) {
    address = _address;
    lat = _lat;
    lon = _lon;
    numberOfLine = 0;
    memberid = _memberid;
    neighborNodes = new ArrayList<Node>();
    nodeType = 1;
  }

  void drawMarker() {
    SimplePointMarker marker = new SimplePointMarker(new Location(lat, lon));
    ScreenPosition pos = marker.getScreenPosition(map);
    x = pos.x;
    y = pos.y;
    float s = 20 + numberOfLine * 5;

    //2015/11/3 added radio reachable value
    fill(0, 255, 0, 20);
    noStroke();
    ellipse(x, y, 2.0 * neighborRadius, 2.0 * neighborRadius); //convert m value to pixel

    noFill();
    strokeWeight(12);
    strokeCap(SQUARE);
    if (nodeType == 0) stroke(0, 153, 0, 100);
    else if (nodeType == 2) stroke(255, 165, 0, 100);
    else stroke(0, 0, 255, 100);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);
    strokeWeight(9);
    strokeCap(SQUARE);
    stroke(255, 255, 255, 200);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);

    //2015/11/4 added
    String idStr = "";
    for (Node tempNode : neighborNodes) {
      idStr += tempNode.memberid + ",";
    }
    String textStr = address + " #" + memberid + "\n"
      + idStr;
    if (nodeType == 0) fill(0, 153, 0);
    else if (nodeType == 2) fill(255, 165, 0);
    else fill(0, 0, 255);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(textStr, x, y);
  }

  void drawLine(float startx, float starty) {
    stroke(0, 200, 200, 150);
    strokeWeight(3);
    line(startx, starty, x, y);
    noStroke();
  }

  //search neighbor nodes by considering the radius of radio 2015/11/4 
  void searchNeighborNodes() {
    neighborNodes = new ArrayList<Node>();
    for (Node tempNode : nodes) {
      if (tempNode != null && tempNode != this && (getDistancefromGPSvalue(tempNode.lat, tempNode.lon, lat, lon) < neighborRadiusMeter)) {
        //        println(tempNode.memberid + " " + tempNode.lat + " " + tempNode.lon);
        //        println("getDistancefromGPSvalue(tempNode.lat, tempNode.lon, lat, lon): " + getDistancefromGPSvalue(tempNode.lat, tempNode.lon, lat, lon));
        neighborNodes.add(tempNode);
      }
    }
  }

  void drawNeighborLines() {
    stroke(127, 50);
    strokeWeight(4);
    for (Node tempNode : neighborNodes) {
      line(x, y, tempNode.x, tempNode.y);
    }
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

  //redefinition of Nodes
  int i = 0;
  for (TableRow row : locationtable.rows ()) {
    nodes[i] = new Node(row.getString("address"), row.getFloat("latitude"), row.getFloat("longitude"), i);
    //    println(nodes[i].lat + " " + nodes[i].lon);
    i++;
  }
  numberOfAvailableNodes = i;
}

void saveCurrentNodes() {
  relationtable = loadTable("relationOriginal.csv", "header");
  for (int i = 0; i <  numberOfAvailableNodes; i++) { 
    try {
      TableRow newRow = relationtable.addRow();
      newRow.setInt("id", i);
      newRow.setFloat("distanceX", (float)nodes[i].distanceX);
      newRow.setFloat("distanceY", (float)nodes[i].distanceY);
    }
    catch(NullPointerException e) {
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

