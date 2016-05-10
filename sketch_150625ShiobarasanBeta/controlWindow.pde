import java.awt.Frame;
import java.awt.BorderLayout;

import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;

Range range;


void controlWindowSetup() {
  cp5 = new ControlP5(this);
  cf = addControlFrame("ControlWindow", 400, 400);
}

//so far I can use this class as if there was processing IDE
public class ControlFrame extends PApplet {
  int w, h;
  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);

    range = cp5.addRange("rangeController")
      .plugTo(parent, "display_number_min")
        .setBroadcast(false)  // disable broadcasting since setRange and setRangeValues will trigger an event
          .setPosition(50, 50)
            .setSize(300, 40)
              .setHandleSize(10)
                .setRange(0, NUMplaces)
                  .setBroadcast(true)   // after the initialization we turn broadcast back on again
                    .setColorForeground(color(255, 40))
                      .setColorBackground(color(0, 0, 255, 40))
                        ;
    cp5.addSlider("K-mean gruop")
      .plugTo(parent, "kmean_number_of_group")
        .setPosition(50, 125)
          .setWidth(300)
            .setValue(5)
              .setRange(1, 50) // values can range from big to small as well
                .setNumberOfTickMarks(50)
                  .setSliderMode(Slider.FLEXIBLE)
                    ;
    cp5.addToggle("ward cluster")
      .plugTo(parent, "wardClusterDrawFlag")
        .setPosition(50, 200)
          .setSize(50, 50)
            ;
    cp5.addToggle("on time")
      .plugTo(parent, "onTimeFlag")
        .setPosition(125, 200)
          .setSize(50, 50)
            ;
    cp5.addBang("delete")
      .setPosition(200, 200)
        .setSize(50, 50)
          .plugTo(parent, "deletePlaces");
    cp5.addBang("save")
      .setPosition(275, 200)
        .setSize(50, 50)
          .plugTo(parent, "saveCurrentPlaces");
    cp5.addToggle("k-mean cluster")
      .plugTo(parent, "kMeanClusterDrawFlag")
        .setPosition(50, 275)
          .setSize(50, 50)
            ;
    cp5.addToggle("distance")
      .plugTo(parent, "distanceDrawFlag")
        .setValue(1)
          .setPosition(125, 275)
            .setSize(50, 50)
              ;
  }

  public void draw() {
    background(0);
  }

  //  private ControlFrame() {
  //  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }

  ControlP5 cp5;

  Object parent;
}

public void deletePlaces() {    
  locationtable = loadTable("locationOriginal.csv", "header");
  saveTable(locationtable, "data/location.csv");
  loadLocationTable();
}


void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("rangeController")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    display_number_min = int(theControlEvent.getController().getArrayValue(0));
    display_number_max = int(theControlEvent.getController().getArrayValue(1));
    println("range update, done.");
  }
}

ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

