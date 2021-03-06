import java.util.*;

//for tree structure
int [] orderByDistance;
int wardClusterDrawFlag = 0;
int kMeanClusterDrawFlag = 0;
float [][] lenPlaces;


int display_number_max = 100; //this is bound and controlled by control window
int display_number_min = 0;
int kmean_number_of_group = 5;

ArrayList<Cluster> wardcluster;
ArrayList<Cluster> kmeancluster;

class Cluster {
  ArrayList<Integer>  memberid;
  float center_x, center_y;
  float radius_max;

  Cluster() {
    memberid = new ArrayList<Integer>();
  }

  void addCluster(ArrayList<Integer> _memberid) {
    memberid.addAll(_memberid);
  }
  void addCluster(int _memberid) {
    memberid.add(_memberid);
  }

  //by using memberid arraylist, calculate the center
  void getCenter() {
    center_x = 0;
    center_y = 0;
    for (int i = 0; i < memberid.size (); i++) {
      center_x += places[memberid.get(i)].x;
      center_y += places[memberid.get(i)].y;
    }
    center_x /= memberid.size();
    center_y /= memberid.size();

    radius_max = 0;
    for (int i = 0; i < memberid.size (); i++) {
      if (radius_max < dist(center_x, center_y, places[memberid.get(i)].x, places[memberid.get(i)].y)) radius_max = dist(center_x, center_y, places[memberid.get(i)].x, places[memberid.get(i)].y);
    }
  }
}


void drawCalcWardCluster() {
  //initialize
  int num = numberOfAvailablePlaces;
  wardcluster = new ArrayList<Cluster>();
  for (int i = 0; i < num; i++) {
    wardcluster.add(new Cluster());
    wardcluster.get(i).addCluster(i);
    wardcluster.get(i).getCenter();
  }

  //loop
  while (num > 1) {  
    num = wardcluster.size(); //this also stands for number of layer


    lenPlaces = new float [num][num];
    float tempmin = 10000000;
    int i_tempmin = num;
    int j_tempmin = num;
    for (int j = 0; j < num; j++) {
      for (int i = j+1; i < num; i++) {
        if (i != j) {
          lenPlaces[i][j] = dist(wardcluster.get(i).center_x, wardcluster.get(i).center_y, wardcluster.get(j).center_x, wardcluster.get(j).center_y);
          if (tempmin > lenPlaces[i][j]) {
            tempmin = lenPlaces[i][j];
            i_tempmin = i;
            j_tempmin = j;
          }
        }
      }
    }  
    //println(tempmin + " " + i_tempmin + " " + j_tempmin);

    float oldcenter_i_x = wardcluster.get(i_tempmin).center_x;
    float oldcenter_i_y = wardcluster.get(i_tempmin).center_y;
    float oldcenter_j_x = wardcluster.get(j_tempmin).center_x;
    float oldcenter_j_y = wardcluster.get(j_tempmin).center_y;

    //make or update cluster
    wardcluster.get(j_tempmin).addCluster(wardcluster.get(i_tempmin).memberid);
    wardcluster.get(j_tempmin).getCenter();
    //remove duplicate cluster
    wardcluster.remove(i_tempmin);

    //line drawed between new center and old center  
    stroke(128, 0, 0, 150);
    strokeWeight(3);
    line(wardcluster.get(j_tempmin).center_x, wardcluster.get(j_tempmin).center_y, oldcenter_i_x, oldcenter_i_y);
    line(wardcluster.get(j_tempmin).center_x, wardcluster.get(j_tempmin).center_y, oldcenter_j_x, oldcenter_j_y);
    noStroke();

    //draw new center
    stroke(243, 152, 100);
    strokeWeight(1);
    fill(243, 152, 0, 255);
    ellipse(wardcluster.get(j_tempmin).center_x, wardcluster.get(j_tempmin).center_y, wardcluster.get(j_tempmin).radius_max*0.1, wardcluster.get(j_tempmin).radius_max*0.1);
    noStroke();

    if (display_number_min < num && num < display_number_max) {
      //draw circle around new center
      stroke(243, 152, 100);
      strokeWeight(2);
      fill(243, 152, 0, 10);
      ellipse(wardcluster.get(j_tempmin).center_x, wardcluster.get(j_tempmin).center_y, wardcluster.get(j_tempmin).radius_max*2 + 30, wardcluster.get(j_tempmin).radius_max*2 +30);
      noStroke();
    }

//for debug
    num--;
    print("number:" + num + " ");
    for (int i = 0; i < num; i++) {
      print(wardcluster.get(i).memberid + " ");
    }
    println();
  }
}

void drawCalcKMeanCluster() {
  //initialize
  int numcluster = kmean_number_of_group;

  kmeancluster = new ArrayList<Cluster>();
  ArrayList<Float> tempclusterx = new ArrayList<Float>();
  ArrayList<Float> tempclustery = new ArrayList<Float>();

  for (int i = 0; i < numcluster; i++) {
    kmeancluster.add(new Cluster());
  } //first make numcluster cluster
  for (int i = numcluster; i < numberOfAvailablePlaces; i++) {
    kmeancluster.get(i % numcluster).addCluster(i);
  }
  for (int i = 0; i < numcluster; i++) { 
    kmeancluster.get(i).getCenter();
    tempclusterx.add(kmeancluster.get(i).center_x);
    tempclustery.add(kmeancluster.get(i).center_y);
  } //first make numcluster cluster

  //loop
  int count = 0;
  while (count++ < numcluster) {  
    //initialize
    kmeancluster.clear();
    for (int i = 0; i < numcluster; i++) {
      kmeancluster.add(new Cluster());
    } //first make numcluster cluster

      //find nearest center and make cluster
    for (int i = 0; i < numberOfAvailablePlaces; i++) { // for all places 
      float tempdist = dist(places[i].x, places[i].y, tempclusterx.get(0), tempclustery.get(0)); // distance between places and cluster 0's center
      int tempclusterid = 0;
      for (int j = 1; j < numcluster; j++) {//look up nearest center
        if (tempdist > dist(places[i].x, places[i].y, tempclusterx.get(j), tempclustery.get(j))) { //can find nearest center
          tempdist = dist(places[i].x, places[i].y, tempclusterx.get(j), tempclustery.get(j)); 
          tempclusterid = j;
        }
      }
      kmeancluster.get(tempclusterid).addCluster(i);
    }

    //calculate center
    tempclusterx.clear();
    tempclustery.clear();
    for (int i = 0; i < numcluster; i++) { 
      kmeancluster.get(i).getCenter();
      tempclusterx.add(kmeancluster.get(i).center_x);
      tempclustery.add(kmeancluster.get(i).center_y);
    }

    //for debug
    for (int i = 0; i < numcluster; i++) {
      print(kmeancluster.get(i).memberid + " ");
    }
    println();
  }



  //draw result
  for (int i = 0; i < numcluster; i++) {
    //draw line between center and member places
    for (int j = 0; j < kmeancluster.get (i).memberid.size(); j++) {
      stroke(0, 100, 0, 150);
      strokeWeight(3);
      line(places[kmeancluster.get(i).memberid.get(j)].x, places[kmeancluster.get(i).memberid.get(j)].y, kmeancluster.get(i).center_x, kmeancluster.get(i).center_y);
      noStroke();
    }

    //draw new center
    stroke(0, 100, 0);
    strokeWeight(1);
    fill(0, 255, 200);
    ellipse(kmeancluster.get(i).center_x, kmeancluster.get(i).center_y, 20, 20);
    noStroke();
  }
}

void drawBinaryTree() {
  sortByDistance();
  line(balancePos.x, balancePos.y, places[orderByDistance[0]].x, places[orderByDistance[0]].y );
  line(balancePos.x, balancePos.y, places[orderByDistance[1]].x, places[orderByDistance[1]].y );
  drawBinaryTreeFragment(0);
  drawBinaryTreeFragment(1);
}

void sortByDistance() {
  orderByDistance = new int [numberOfAvailablePlaces];//for save indicator of places[]
  for (int i=0; i < numberOfAvailablePlaces; i++) {
    orderByDistance[i] = i;
  }
  //id[] represent ascending order by distanceFromBarycenter 
  for (int i=0; i < numberOfAvailablePlaces; i++) {
    for (int j=numberOfAvailablePlaces-1; j > i; j--) {
      if (places[orderByDistance[j-1]].distanceFromBarycenter > places[orderByDistance[j]].distanceFromBarycenter) {
        int t=orderByDistance[j];
        orderByDistance[j]=orderByDistance[j-1];
        orderByDistance[j-1]=t;
      }
    }
  }
  for (int i=0; i<numberOfAvailablePlaces; i++) {
    println(i + " " + orderByDistance[i] + " " + places[orderByDistance[i]].distanceFromBarycenter);
  }
}

void drawBinaryTreeFragment(int n) {
  try {
    stroke(167, 87, 168);
    strokeWeight(2);
    line(places[orderByDistance[n]].x, places[orderByDistance[n]].y, places[orderByDistance[2 * n + 2]].x, places[orderByDistance[2 * n + 2]].y );
    line(places[orderByDistance[n]].x, places[orderByDistance[n]].y, places[orderByDistance[2 * n + 3]].x, places[orderByDistance[2 * n + 3]].y );
    noStroke();

    stroke(243, 152, 100);
    strokeWeight(1);
    fill(243, 152, 0, 10);
    ellipse(places[orderByDistance[n]].x, places[orderByDistance[n]].y, 
    2*dist(places[orderByDistance[n]].x, places[orderByDistance[n]].y, places[orderByDistance[2 * n + 3]].x, places[orderByDistance[2 * n + 3]].y), 2*dist(places[orderByDistance[n]].x, places[orderByDistance[n]].y, places[orderByDistance[2 * n + 3]].x, places[orderByDistance[2 * n + 3]].y));
    noStroke();

    drawBinaryTreeFragment(2 * n + 2); //recursive binary tree
    drawBinaryTreeFragment(2 * n + 3); //recursive binary tree
  } 
  catch(ArrayIndexOutOfBoundsException e) {
  }
}

