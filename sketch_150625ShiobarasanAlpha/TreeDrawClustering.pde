import java.util.*;

//for tree structure
int [] orderByDistance;
int treeDrawFlag = 0;
float [][] lenPlaces;

int display_number_max = NUMplaces;
int display_number_min = 0;
ArrayList<Cluster> cluster;

class Cluster {
  ArrayList<Integer>  memberid;
  float center_x, center_y;
  float radius_max;

  Cluster(int i) {
    memberid = new ArrayList<Integer>();
    memberid.add(i);
  }

  void addCluster(ArrayList<Integer> _memberid) {
    memberid.addAll(_memberid);
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


void drawCalcCluster() {
  //initialize
  int num = numberOfAvailablePlaces;
  cluster = new ArrayList<Cluster>();
  for (int i = 0; i < num; i++) {
    cluster.add(new Cluster(i));
    cluster.get(i).addCluster(new ArrayList<Integer>());
    cluster.get(i).getCenter();
  }

  //loop
  while (num > 2) {  
    num = cluster.size(); //this also stands for number of layer

    print("number:" + num + " ");
    for (int i = 0; i < num; i++) {
      print(cluster.get(i).memberid + " ");
    }
    println();

    lenPlaces = new float [num][num];
    float tempmin = 10000000;
    int i_tempmin = num;
    int j_tempmin = num;
    for (int j = 0; j < num; j++) {
      for (int i = j+1; i < num; i++) {
        if (i != j) {
          lenPlaces[i][j] = dist(cluster.get(i).center_x, cluster.get(i).center_y, cluster.get(j).center_x, cluster.get(j).center_y);
          if (tempmin > lenPlaces[i][j]) {
            tempmin = lenPlaces[i][j];
            i_tempmin = i;
            j_tempmin = j;
          }
        }
      }
    }  
    //println(tempmin + " " + i_tempmin + " " + j_tempmin);

    float oldcenter_i_x = cluster.get(i_tempmin).center_x;
    float oldcenter_i_y = cluster.get(i_tempmin).center_y;
    float oldcenter_j_x = cluster.get(j_tempmin).center_x;
    float oldcenter_j_y = cluster.get(j_tempmin).center_y;

    //make or update cluster
    cluster.get(j_tempmin).addCluster(cluster.get(i_tempmin).memberid);
    cluster.get(j_tempmin).getCenter();
    //remove duplicate cluster
    cluster.remove(i_tempmin);

    //line drawed between new center and old center  
    stroke(128, 0, 0, 150);
    strokeWeight(3);
    line(cluster.get(j_tempmin).center_x, cluster.get(j_tempmin).center_y, oldcenter_i_x, oldcenter_i_y);
    line(cluster.get(j_tempmin).center_x, cluster.get(j_tempmin).center_y, oldcenter_j_x, oldcenter_j_y);
    noStroke();

    //draw new center
    stroke(243, 152, 100);
    strokeWeight(1);
    fill(243, 152, 0, 255);
    ellipse(cluster.get(j_tempmin).center_x, cluster.get(j_tempmin).center_y, cluster.get(j_tempmin).radius_max*0.1, cluster.get(j_tempmin).radius_max*0.1);
    noStroke();

    if (display_number_min < num && num < display_number_max) {
      //draw circle around new center
      stroke(243, 152, 100);
      strokeWeight(2);
      fill(243, 152, 0, 10);
      ellipse(cluster.get(j_tempmin).center_x, cluster.get(j_tempmin).center_y, cluster.get(j_tempmin).radius_max*2 + 30, cluster.get(j_tempmin).radius_max*2 +30);
      noStroke();
    }
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

