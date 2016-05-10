ArrayList<ArrayList<Node>> searchAllPath(Node src, Node dst) { //search all possibl path from "src" node to "dst" node
  ArrayList<ArrayList<Node>> result = new ArrayList<ArrayList<Node>>();
  ArrayList<Node> path = new ArrayList<Node>();

  if (src == null || dst == null) {
    println("Cannot find src or dst. src: " + src + " dst: " + dst);
    return null;
  }

  println("search path from " + src.memberid + " to " + dst.memberid);
  recursivePathSearch(path, src, dst, result);

  for (ArrayList<Node> tempPaths : result) {
    print("path found!! hops: ");
    print(tempPaths.size() + " path: ");
    for (Node printNode : tempPaths) {
      print(printNode.memberid + " ");
    }
    println("");
  }

  return result;
}

void recursivePathSearch(ArrayList<Node> path, Node tempNode, Node dst, ArrayList<ArrayList<Node>> result) {//recursive function to search all path from "src" node to "dst" node. This is like print all component of the tree structure.
  path.add(tempNode);

  if (tempNode == dst) { //if tempNode = destination node, pash search is accomplished 
    //    print(path.size());
    result.add(new ArrayList(path));
    //    println(result.get(result.size() - 1).size());
    //    print("path found!! ");
    //    for (Node printNode : path) {
    //      print(printNode.memberid + " ");
    //    }
    //    println("");
  }

  for (Node tempChild : tempNode.neighborNodes) {
    if (!path.contains(tempChild)) { //when Next node is not arrived
      recursivePathSearch(path, tempChild, dst, result);
    }
  }

  path.remove(path.size() - 1);
}

void drawFewestHopPath(ArrayList<ArrayList<Node>> result) { //draw fewest hop pass from the result dataset 
  if (result == null) {
    println("Cannot find result or result is null.");
    return;
  }

  //firstly calc fewest hop
  int minHop = NUMnodes;
  for (ArrayList<Node> tempPaths : result) {
    if (tempPaths.size() < minHop) minHop = tempPaths.size();
  }
  println("minHop : " + minHop);

  for (ArrayList<Node> tempPaths : result) {
    if (tempPaths.size() == minHop) {
      for (int i = 0; i < tempPaths.size () - 1; i++) {
        stroke(255, 0, 0, 100);
        strokeWeight(5);
        line(tempPaths.get(i).x, tempPaths.get(i).y, tempPaths.get(i + 1).x, tempPaths.get(i + 1).y);
        noStroke();
      }
    }
  }
}

void drawPathDemo() { //demo function to display path. Coordinator and End devices is defined according to the number of neighbor node.
  Node co = new Node("temp", 0, 0, -1);
  ArrayList<Node> ends = new ArrayList<Node>();

  //decides coodinator and end devices <===
  int numOfNeighbor = 0;
  for (int i = 0; i < numberOfAvailableNodes; i++) {
    println(i + " " + nodes[i].neighborNodes.size());
    if (nodes[i].neighborNodes.size() > numOfNeighbor) {//in this algorithm, the node which has most neighbornodes and youngest id is chosen
      numOfNeighbor = nodes[i].neighborNodes.size();
      co = nodes[i];
    }
    if (nodes[i].neighborNodes.size() <= 1) {
      ends.add(nodes[i]);
      nodes[i].nodeType = 2;
    }
  }
  nodes[co.memberid].nodeType = 0;

  println("co.memberid: " + co.memberid);
  print("ends.memberid s: ");  
  for (Node tempNode : ends) {
    print(tempNode.memberid + " ");
  }
  println("");
  // ===> decides coodinator and end devices

  //draw fewest hop path which is colored RED
  for (Node tempNode : ends) {
    drawFewestHopPath(searchAllPath(co, tempNode));
  }
}

