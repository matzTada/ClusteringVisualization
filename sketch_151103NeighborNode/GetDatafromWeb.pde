void getDatafromWeb(String search_word) {
  search_word = search_word.trim(); //trim spaces
  String[] searchwords = search_word.split(" ");
  search_word = "";
  for (int i = 0; i < searchwords.length; i++) {
    search_word += searchwords[i];
    search_word += "+"; //put "+" betwenn word to search in web
  }

  //GET XML format data from www.geocoding.jp/api
  GetRequest get = new GetRequest("http://www.geocoding.jp/api/?v=1.1&q=" + search_word);
  get.send();
  String str_responce = get.getContent();
  println("Reponse Content: " + str_responce);

  //extract values of latitude and longitude. string analysis directry... oops
  //if there error happens indexOf("<error>") return not -1
  if (str_responce.indexOf("<error>") == -1) { 
    String address = str_responce.substring(str_responce.indexOf("<address>") + 9, str_responce.indexOf("</address>"));
    float latitude = Float.parseFloat(str_responce.substring(str_responce.indexOf("<lat>") + 5, str_responce.indexOf("</lat>")));
    float longitude = Float.parseFloat(str_responce.substring(str_responce.indexOf("<lng>") + 5, str_responce.indexOf("</lng>")));
    println("---new data from GET HTTP request---");
    println("addreess : " + address);
    println("latitude : " + latitude + " longitude : " + longitude);

    //rewrite table
    TableRow newRow = locationtable.addRow();
    newRow.setString("address", address);
    newRow.setFloat("latitude", latitude);
    newRow.setFloat("longitude", longitude);
    newRow.setString("date", year() + "/" + month() + "/" + day() + "_" +hour() + ":" +minute() + ":" +second());
    saveTable(locationtable, "data/location.csv");
  } else {
    println("--------------------------------------");
    println("----oops!! can't get data from web----");
    println("--------------------------------------");
  }
}

