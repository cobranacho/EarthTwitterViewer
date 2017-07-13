/* //<>// //<>//
 *  Project: Data
 *  Student:  James Hu, Sergio Hidalgo, Moo Kyung Sohn
 *  Pasadena  City  College,  Spring  2017  
 *  Instructor  Masood  Kamandy  
 *    
 *  Project  Description:  This is the Project 4
 *
 *  Last  Modified:  May  30,  2017  
 *    
 */

import twitter4j.conf.*; 
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;
import peasy.*;
import g4p_controls.*;

import processing.sound.*;

GTextField txf1, txf2, txf3, txf4;
GTextArea txa;
GButton button;
GTabManager tt;

Twitter twitter;
Query query;
Location twLocal;

YahooWeather yahoo;

processing.data.JSONArray availableTrendsLocations;

String searchString = "";
List<Status> tweets;
ResponseList<Location> locations;

int currentTweet, numOfTrendsDisplay = 25;


// SoundFile click, close;

String queryText;
String labelMessage;
PImage twitterAccountImg;
ArrayList<TextLabel> tlabels;
ArrayList<TextLabel> searchLabels;
ArrayList<TextLabel> dataLabels;
ArrayList<String> twitterMessages;
TextLabel remove, display;
int displayIndex;
boolean tweetOn;

PeasyCam camera;
Stars stars;
Earth earth;
GeoService geolocate;
ISS iss;

float EARTHRADIUS = 3959.0;
float ISSORBIT = 249;
float LABELORBIT = 250;
float SCALAR = 20.0;

float lng, lat, issLng, issLat;
float issRollX, issRollY;
int issTimeStamp;

PVector locationVector, issLocation;

ArrayList<GeoService> geoPositions;

Location d;
Table woeidTable;

void setup() {
  size(1440, 800, P3D);

  // Initialize search interface controls
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);

  txa = new GTextArea(this, width - 230, height - 190, 200, 120);
  txa.setVisible(false);

  txf1 = new GTextField(this, width - 230, 30, 200, 20);
  txf1.tag = "locality";
  txf1.setPromptText(" Enter Locality");

  txf2 = new GTextField(this, width - 230, txf1.getY() + 30, 200, 20);
  txf2.tag = "adminArea";
  txf2.setPromptText(" Enter Administrative Area");

  txf3 = new GTextField(this, width - 230, txf2.getY() + 30, 200, 20);
  txf3.tag = "country";
  txf3.setPromptText(" Enter Country");

  txf4 = new GTextField(this, width - 230, txf3.getY() + 60, 200, 20);
  txf4.tag = "topic";
  txf4.setPromptText(" Enter topic");

  button = new GButton(this, width - 175, txf4.getY() + 35, 100, 20);
  button.tag = "search";
  button.setText("Search");

  tt = new GTabManager();
  tt.addControls(txf1, txf2, txf3);

  yahoo = new YahooWeather();
  geolocate = new GeoService();

  //click = new SoundFile(this, "click.mp3");
  //close = new SoundFile(this, "hover.mp3");
  tlabels = new ArrayList<TextLabel>();
  dataLabels = new ArrayList<TextLabel>();
  searchLabels = new ArrayList<TextLabel>();

  twitterAccountImg = loadImage("bird.png");

  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("e1NHcJ57OHP5AgueUigYJzNtE");
  cb.setOAuthConsumerSecret("L5QLA5elIOv0CgGGU96u6PiRBJ7Gt3QZQRqekIQ6fIE0SSQxS8");
  cb.setOAuthAccessToken("854085592103108608-PNgIQqPsLUmjZdDrB1rWuhtgSWAw3zL");
  cb.setOAuthAccessTokenSecret("qYll1OL5IdrQxxexdwpOGfVFH1wcceBUWu91HvO3hF6Mo");

  twitter = new TwitterFactory(cb.build()).getInstance();
  availableTrendsLocations = new processing.data.JSONArray();

  //woeidTable = new Table();
  //woeidTable.addColumn("woeid");
  //woeidTable.addColumn("locality");
  //woeidTable.addColumn("lng");
  //woeidTable.addColumn("lat");

  try {

    // Grab the Twitter available Trends location and save in csv to save bandwidth
    // locations = twitter.getAvailableTrends();

    //for (Location location : locations) {
    //  geolocate = new GeoService(location.getName());
    //  TableRow newRow = woeidTable.addRow();
    //  newRow.setInt("woeid", location.getWoeid());
    //  newRow.setString("locality", location.getName());
    //  newRow.setFloat("lng", geolocate.getLocaton().x);
    //  newRow.setFloat("lat", geolocate.getLocaton().y);
    //}
    // saveTable(woeidTable, "data/woeid.csv");

    // get world trending topic
    Trends trends = twitter.getPlaceTrends(1);

    for (int i = 0; i < numOfTrendsDisplay; i += 1) {
      labelMessage = trends.getTrends()[i].getName();
      println(labelMessage);

      tlabels.add( new TextLabel(labelMessage, 50, 90 + 25 * i, 0, 16, twitterAccountImg));
    }
  }  
  catch (TwitterException te) {
    println("Failed to search tweets: " + te.getMessage());
  }

  camera = new PeasyCam(this, 0, 0, 0, EARTHRADIUS / SCALAR + 280);
  camera.setMinimumDistance(EARTHRADIUS / SCALAR + 280);
  camera.setMaximumDistance(EARTHRADIUS / SCALAR + 280);

  camera.rotateY(-PI / 2);  // rotate default camera to be over 0 degree longitude at Greenwich UK
  // camera.setLeftDragHandler(null);
  camera.setSuppressRollRotationMode();

  stars = new Stars(600);
  earth = new Earth();
  iss = new ISS();

  geoPositions = new ArrayList<GeoService>();


  // geolocate = new GeoService(18.424055, -33.9248);

  //geolocate = new GeoService(location);

  //locationVector = geolocate.getLocaton();
  //lng = locationVector.x;
  //lat = locationVector.y;

  //println(location + " - " + "lonngittude: " + lng + " Latitude: " + lat);

  lng = 0.0;
  lat = 0.0;

  // test data
  //issLng = 121.565414;  // Taipei Taiwan
  //issLat = 25.032969;
  issLat = 51.48258;  // Greenwish UK
  issLng = -0.0076589;
  //issLat = 34.147785;  // Pasadena CA
  //issLng = -118.144516;
  //issLat = 15.299327;    // Goa India
  //issLng = 74.12399;
  //issLat = -33.9248;    // Capetown SA
  //issLng = 18.424055;

  issLocation = iss.getPosition();
  issLng =  issLocation.x;
  issLat = issLocation.y;
  issTimeStamp = int(issLocation.z);
  println("Current ISS location - " + "Lonngitude: " + issLng + " Latitude: " + issLat + " Timestamp: " + issTimeStamp);
}


void queryTwitter(Float longitude, float latitude) {

  GeoLocation geo = new GeoLocation(latitude, longitude);
  String tempLocal = "";
  try {
    twLocal = twitter.getClosestTrends(geo).get(0);
    Trends localTrends = twitter.getPlaceTrends(twLocal.getWoeid());
    
   
    labelMessage = localTrends.getTrends()[0].getName();
    tempLocal = twLocal.getPlaceName();
  } 
  catch (TwitterException e) {
    println("Communication Error");
  }


  println("Top trend near " + tempLocal + " is " + labelMessage);
  queryTwitter(labelMessage);
  searchLabels.add( new TextLabel(labelMessage, width - labelMessage.length() * 10 - 60, int(height / 2.4 + 25 * searchLabels.size()), 0, 16, twitterAccountImg));
}
void queryTwitter(String locality, String administrativeArea, String country) {

  geolocate.search(locality, administrativeArea, country);

  GeoLocation geo = new GeoLocation(geolocate.latitude, geolocate.longitude);

  try {
    twLocal = twitter.getClosestTrends(geo).get(0);
    Trends localTrends = twitter.getPlaceTrends(twLocal.getWoeid());

    labelMessage = localTrends.getTrends()[0].getName();
  } 
  catch (TwitterException e) {
    println("Communication Error");
  }


  println("Top trend near " + locality + " is " + labelMessage);
  queryTwitter(labelMessage);
  searchLabels.add( new TextLabel(labelMessage, width - labelMessage.length() * 10 - 60, int(height / 2.4 + 25 * searchLabels.size()), 0, 16, twitterAccountImg));
}

void queryTwitter(String hashtag) {
  //twitter = TwitterFactory.getSingleton();
  query = new Query(hashtag);
  query.setCount(10);

  try {
    QueryResult result = twitter.search(query);
    tweets = result.getTweets();
    for (Status tw : tweets) {
      String userLocation = tw.getUser().getLocation();

      if (userLocation != " ") {
        String language = tw.getUser().getLang();

        String user = "@"+ tw.getUser().getScreenName();
        String message = tw.getText();
        String [] temp = message.split(": ");
        message = temp[0];
        temp = message.split("http");
        message = temp[0];
        int retweetCount = tw.getRetweetCount();
        String tweetTime = tw.getCreatedAt().toString();
        PImage userImage = loadImage(tw.getUser().getProfileImageURL());

        println("user: " + user);
        println("url: " + tw.getUser().getProfileImageURL());
        println("retweets: " + retweetCount);
        println("message: " + message);
        println("Language: " + language);
        println("time: " + tweetTime);
        println("location: " + userLocation);

        geolocate.search(userLocation);
        String localWeather = yahoo.getWeather(geolocate.locality, geolocate.administrativeArea, geolocate.country);
        float lng = geolocate.getLocaton().x;
        float lat = geolocate.getLocaton().y;

        println("lng: " + lng, "lat: " + lat);

        if (lng != 500.0) {
          dataLabels.add(new TextLabel(user, hashtag, lng, lat, 6, retweetCount, message, userLocation, userImage, localWeather, tweetTime));
        }
      }
      println("\n");
    }
  } 
  catch (TwitterException te) {
    println("Connection Error");
  }
}

void sendQuery() {
  queryTwitter(queryText);
}

void draw() {
  background(0);

  rotateZ(radians(-23.49));  // earth tilt

  //if (frameCount % 300 == 0) {
  //  issLocation = iss.getPosition();
  //  issLng =  issLocssation.x;
  //  issLat = issLocation.y;
  //  println(issLng, issLat);
  //}

  // Earth's natural rotation
  //if (frameCount % 60 == 0) {
  //  lng += 360.0 / (24.0 * 60.0 * 60.0);
  //}
  if (keyPressed) {
    if (key == 's') {
      println(lng);
      lng += 0.5;
      if (lng >= 360.0) {
        lng = 0.0;
      }
    } 
    //else if (key == 'w') {
    //  println(lat);
    //  lat -= 0.2;
    //  lat = constrain(lat, -45, 45);
    //} 
    //else if (key == 'x') {
    //  println(lat);
    //  lat += 0.2;
    //  lat = constrain(lat, -45, 45);
    //}
  }

  camera.beginHUD();
  fill(250);
  textSize(24);
  text("Global Trending Hastags", 20, 50, 0);

  text("Keyboard Control", 20, height - 60, 0);
  textSize(18);
  text("s key to spin earth", 40, height - 30, 0);



  for (TextLabel st : searchLabels) {
    if (st.closeMe) {
      remove = st;
    }
  }

  if (remove != null) {
    searchLabels.remove(remove);
  }

  for (TextLabel search : searchLabels) {
    pushMatrix();
    search.clicked = true;
    search.update();
    popMatrix();
  }

  for (TextLabel tt : tlabels) {
    if (tt.closeMe) {
      remove = tt;
    }
  }

  if (remove != null) {
    tlabels.remove(remove);
  }

  for (TextLabel t : tlabels) {
    t.update();
  }

  pushMatrix();
  translate(width / 2, height / 2);
  stars.drawStars();
  popMatrix();



  fill(0, 172, 237);
  rect(width - 245, 10, 230, 210);
  fill(0);
  textSize(14);
  text("OR", width - 142, txf3.getY() + 44);


  pushMatrix();
  if (tweetOn) {
    display = dataLabels.get(displayIndex);
    display.showTweet();
  }
  popMatrix();

  camera.endHUD();


  // draw Earth
  pushMatrix();
  earth.display(lng, lat);
  popMatrix();

  // draw ISS
  pushMatrix();
  issRollX = cos(radians(issLat)) * (EARTHRADIUS / SCALAR + ISSORBIT / SCALAR);
  // println("rollX " + issRollX);
  issRollY = sin(radians(issLat)) * -(EARTHRADIUS / SCALAR + ISSORBIT / SCALAR);
  // println("rollY " + issRollY);
  rotateY(radians(180 + issLng + lng));

  translate(issRollX, issRollY, 0);
  fill(0, 0, 255);


  box(10);
  popMatrix();

  // draw the dataLabels
  if (dataLabels.size() > 0) {
    for (TextLabel dl : dataLabels) {
      float labelRollX = cos(radians(dl.lat)) * (EARTHRADIUS / SCALAR - 1) ;
      float labelRollY = sin(radians(dl.lat)) * -(EARTHRADIUS / SCALAR - 1);
      pushMatrix();
      rotateY(radians(180 + dl.lng + lng));

      translate(labelRollX, labelRollY, 0);

      fill(255, 10, 10);

      sphere(2);

      fill(255);
      textSize(6);

      rotateY(radians(100));
      pushMatrix();
      rotateX(radians(dl.lat));

      text(dl.userLocation, 4, 0, 8);
      String weatherCondition [] = dl.weather.split(" ");
      int tempDegree = int(weatherCondition[0]);
      tempDegree = constrain(tempDegree, 0, 100);
      tempDegree = int(map(tempDegree, 0, 100, 0, 255));
      colorMode(RGB);
      fill(tempDegree, 200, 255-tempDegree);
      text(dl.weather, 4, 6, 8);
      fill(250);
      popMatrix();

      rotateY(radians(-90));

      dl.update();
      popMatrix();
    }
  }

  // draw arc between labels
  if (dataLabels.size() > 1) {
    TextLabel previous = dataLabels.get(0);



    for (int i = 1; i < dataLabels.size(); i++) {
      //  pushMatrix();

      String previousTag = previous.hashtag;
      float previousLng = previous.lng;
      float previousLat = previous.lat;

      TextLabel current = dataLabels.get(i);
      String currentTag = current.hashtag;

      if (currentTag == previousTag) {

        float currentLng = current.lng;
        float currentLat = current.lat;

        float currentRollX = cos(radians(currentLat)) * (EARTHRADIUS / SCALAR);
        float currentRollY = sin(radians(currentLat)) * -(EARTHRADIUS / SCALAR);

        float previousRollX = cos(radians(previousLat)) * (EARTHRADIUS / SCALAR );
        float previousRollY = sin(radians(previousLat)) * -(EARTHRADIUS / SCALAR);

        //println(currentRollX, currentRollY, previousRollX, previousRollY);
        //println(currentLng, previousLng);

        PVector currentPos = new PVector(currentRollX, currentRollY, currentLng);
        PVector previousPos = new PVector(previousRollX, previousRollY, previousLng);

        float dist = PVector.dist(currentPos, previousPos);

        pushMatrix();
        pushStyle();
        colorMode(HSB);
        stroke(color(current.hue, current.saturation, current.brightness));

        rotateY(radians(180 + currentLng + lng));

        translate(currentRollX, currentRollY, 30);

        beginShape();
        noFill();
        //vertex(0, 0, 0);
        //vertex(currentPos.x, currentPos.y, currentPos.z);
        //bezierVertex(0, 0 - dist / 1.5, 0, previousPos.x, previousPos.y - dist / 1.5, previousPos.z, previousPos.x, previousPos.y, previousPos.z);
        //endShape();

        //  line(0, 0, 0, previousRollX - currentRollX, previousRollY - currentRollY, 430);


        strokeWeight(3);

        popStyle();
        popMatrix();
      }
      previous = current;
    }
  }
}


void mouseClicked() {
  float clickLng = 0.0, clickLat = 0.0;

  for (TextLabel st : searchLabels) {
    if (st.mouseHover) {
      // close.play();
      st.setClicked(true);
    }
    if (st.mouseOverX) {
      // click.play();
      st.setClose(true);
    }
  }

  for (TextLabel t : tlabels) {
    if (t.mouseHover) {
      // close.play();
      t.setClicked(true);
    }
    if (t.mouseOverX) {
      // click.play();
      t.setClose(true);
    }
  }
  PVector clickLocation = new PVector(mouseX, mouseY);
  float distFromCenter = clickLocation.dist(new PVector(width / 2, height / 2));
  distFromCenter = map(distFromCenter, 0, 314.95, 0, EARTHRADIUS / SCALAR);

  float xOffset, angleOffsetX, yOffset, angleOffsetY;

  xOffset = abs(width / 2 - mouseX) / 314.95;

  angleOffsetX = 90 - acos(xOffset) / PI * 180;


  yOffset = abs(height / 2 - mouseY) / 314.95;
  angleOffsetY = 90 - acos(yOffset) / PI * 180;

  if (distFromCenter < EARTHRADIUS / SCALAR) {
    if (mouseX < width / 2 && mouseY <= height / 2) {
      clickLng = (-lng - angleOffsetX);
      clickLat = angleOffsetY;
    } else if (mouseX >= width / 2 && mouseY <= height / 2) {
      clickLng = (-lng + angleOffsetX);
      clickLat = angleOffsetY;
    } else if (mouseX < width / 2 && mouseY > height / 2) {
      clickLng = (-lng - angleOffsetX);
      clickLat = -angleOffsetY;
    } else {
      clickLng = (-lng + angleOffsetX);
      clickLat = - angleOffsetY;
    }
  }

 // println("click lng: " + clickLng + " lat: " + clickLat);
  if (clickLat != 0 && clickLng != 0) {
    // queryTwitter(clickLat, clickLng);
  }
}

void handleTextEvents(GEditableTextControl textControl, GEvent event) {

  if (event.toString() == "GETS_FOCUS") {
    if (textControl.tag == "topic") {
      txf1.setText("");
      txf2.setText("");
      txf3.setText("");
    } else {
      txf4.setText("");
    }
  }
}

void handleButtonEvents(GButton button, GEvent event) {

  String tmpLocality = txf1.getText();
  String tmpAdmin = txf2.getText();
  String tmpCountry = txf3.getText();
  String tmpTopic = txf4.getText();

  if (tmpTopic.isEmpty() == false) {
    queryTwitter(tmpTopic);
    searchLabels.add( new TextLabel(tmpTopic, width - tmpTopic.length() * 10 - 60, int(height / 2.4 + 25 * searchLabels.size()), 0, 16, twitterAccountImg));
  } else if (tmpLocality.isEmpty() == false || tmpAdmin.isEmpty() == false || tmpCountry.isEmpty() == false) {
    queryTwitter(tmpLocality, tmpAdmin, tmpCountry);
  }
}

void keyPressed() {

  if (key == TAB && !dataLabels.isEmpty()) {
    tweetOn = true;



    //println(t.lat, t.lng);
    //camera.lookAt(t.lng, t.lat, -100);
    //camera.setYawRotationMode();
    //camera.setDistance(10);
    //  camera.rotateY(PI / 8);


    if (dataLabels.iterator().hasNext()) {
      displayIndex += 1;
    } else {
      displayIndex = 0;
    }
  }

  if (key == 'r') {
    camera.reset();
    camera.setActive(true);
  }
}

void displayTweet(TextLabel t) {
  pushMatrix();
  pushStyle();
  camera.beginHUD();
  translate(width - 300, height - 200);
  image(t.img, 20, 20);
  rect(0, 0, 250, 180);
  camera.endHUD();
  popStyle();
  popMatrix();
}