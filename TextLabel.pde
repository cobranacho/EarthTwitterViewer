class TextLabel {
  String label, hashtag, message, userLocation;
  int x, y, z, size, boxX, boxY, textW, centerX, centerY;
  int boxWidth, boxHeight;
  float hue, saturation, brightness;
  int type, retweets;
  boolean clicked, closeMe, mouseHover, mouseOverX;
  PImage img, userImg;
  float lng, lat;
  String weather, time;


  TextLabel(String user, String hashtag_, float lng, float lat, int size_, int retweetCount_, String message_, String userLocation_, PImage img_, String localWeather, String tweetTime_) {
    type = 1;
    x = int(-this.lat) + 8;    
    y = int(random(-10, 10));
    z = int(random(-10, 10));
    label = user;
    size = size_;
    weather = localWeather;
    time = tweetTime_;
    retweets = retweetCount_;
    message = message_;
    hashtag = hashtag_;
    this.lng = lng;
    this.lat = lat;
    userLocation = userLocation_;
    img = img_;

    userImg = img_.copy();
    pushStyle();
    textSize(size);
    textW = int(textWidth(label));
    popStyle();
    boxX = int(x - textW * 0.05); 
    boxY = y - size;
    boxWidth = int(textW * 1.1);
    boxHeight = int(size * 1.3);
    centerX = boxX + boxWidth / 2;
    centerY = boxY + boxHeight / 2;
    hue = hashWord(hashtag);
    saturation = hue;
    brightness = 200;
  }

  TextLabel(String str, int x_, int y_, int z_, int size_, PImage img_) {
    type = 2;
    x = x_;
    y = y_;
    z = z_;
    label = str;
    size = size_;
    img = img_;
    pushStyle();
    textSize(size);
    textW = int(textWidth(label));
    popStyle();
    boxX = int(x - textW * 0.05); 
    boxY = y - size;
    boxWidth = int(textW * 1.1);
    boxHeight = int(size * 1.3);
    centerX = boxX + boxWidth / 2;
    centerY = boxY + boxHeight / 2;
    hue = hashWord(label);
    saturation = hue;
    brightness = 200;
  }

  PVector getLocation() {
    return new PVector(lng, lat, 0);
  }

  int hashWord(String str) {
    int sum = 0;
    for (int i = 0; i < str.length(); i++) {
      char c = str.charAt(i);
      sum += c;
    }
    return sum % 255;
  }

  void scaleText(float scalar) {
    size *= scalar;
  }

  void setLabel(String str) {
    label = str;
  }

  void setClicked(boolean bol) {
    clicked = bol;
    println("Searching trend " + label);
    queryText = label;
    sendQuery();
  }


  void setClose(boolean bol) {
    closeMe = bol;
    println("Closing trend " + label);

    if (dataLabels.size() > 0) {
      ArrayList<TextLabel> toBeRemoved = new ArrayList<TextLabel>();
      for (TextLabel tl : dataLabels) {
        if (this.label == tl.hashtag) {
          toBeRemoved.add(tl);
        }
      }
      for (TextLabel rm : toBeRemoved) {
        dataLabels.remove(rm);
      }
      toBeRemoved.clear();
    }
  }

  color getColor() {
    return color(hue, saturation, 200);
  }

  void update() {
    if (mouseX > boxX && mouseX < boxX + boxWidth && mouseY > boxY && mouseY < boxY + boxHeight && type == 2) {
      mouseHover = true;
      brightness = 240;
    } else {
      mouseHover = false;
      brightness = 200;
    }
    if (mouseX > boxX + boxWidth && mouseX < boxX + boxWidth + boxHeight && mouseY > boxY && mouseY < boxY + boxHeight && type == 2) {
      mouseOverX = true;
    } else {
      mouseOverX = false;
    }   
    display();
  }



  void showTweet() {
    pushMatrix();
    pushStyle();

    translate(width - 245, height - 285);
    colorMode(RGB);
    fill(0, 172, 237);

    rect(0, 0, 230, 265);
    fill(255);
    rect(15, 15, 200, 48);
    image(userImg, 15, 15);
    fill(0);
    textSize(13);
    txa.setText(message);
    txa.setTextEditEnabled(false);
    txa.setVisible(true);

    text(label, 75, 30);
    textSize(14);
    text(hashtag, 15, 85);
    textSize(11);
    text(userLocation, 75, 55);

    textSize(12);
    text("Retweets " + retweets, 15, 235);

    text(time, 15, 250);

    popStyle();
    popMatrix();
  }

  void display() {
    if (!closeMe) {
      if (type == 2) {
        pushStyle();
        colorMode(HSB);
        textSize(size);

        pushMatrix();
        translate(0, 0, z);

        // draw the rect behind text
        fill(color(hue, saturation, brightness));
        rect(boxX, boxY, boxWidth, boxHeight);
        fill(color(hue, saturation, 200)); 

        // draw the close button
        rect(boxX + boxWidth, boxY, boxHeight, boxHeight);

        if (img != null) {
          img.resize(boxHeight, boxHeight);
          image(img, boxX - boxHeight, boxY);
        }
        fill(0);
        stroke(0);
        text(label, x, y);
        line(boxX + boxWidth + boxHeight * 0.2, boxY + boxHeight * 0.2, boxX + boxWidth + boxHeight * 0.8, boxY + boxHeight * 0.8);
        line(boxX + boxWidth + boxHeight * 0.2, boxY + boxHeight * 0.8, boxX + boxWidth + boxHeight * 0.8, boxY + boxHeight * 0.2);

        if (clicked) {
          colorMode(RGB);
          stroke(0, 172, 237);
          strokeWeight(2);
          line(boxX + boxWidth + boxHeight * 1.3, boxY + boxHeight * 0.2, boxX + boxWidth + boxHeight * 1.41, boxY + boxHeight * 0.8);

          line(boxX + boxWidth + boxHeight * 1.41, boxY + boxHeight * 0.8, boxX + boxWidth + boxHeight * 2.2, boxY + boxHeight * 0.2);
        }

        popMatrix();
        popStyle();
      }

      if (type == 1) {

        pushStyle();
        colorMode(HSB);
        textSize(size);

        pushMatrix();
        rotateZ(radians(-this.lat));
        translate(x, y, z);


        // draw the rect behind text
        fill(color(hue, saturation, brightness));
        rect(boxX, boxY, boxWidth, boxHeight);
        fill(color(hue, saturation, 200)); 

        if (img != null) {
          img.resize(boxHeight, boxHeight);
          image(img, boxX - boxHeight, boxY);
        }
        fill(0);
        stroke(0);

        text(label, x, y);

        pushStyle();
        fill(250);
        //text(weather, x + boxWidth + 8, y);
        popStyle();
        if (message.length() < 40) {
          pushStyle();
          fill(250);
          text(message, x - boxHeight, y + boxHeight + 2);
          popStyle();
        }

        // draw the retweet meter


        int meterH = constrain(retweets, 0, 500);
        meterH = int(map(meterH, 0, 500, 0, 80));
        fill(meterH * 3, 200, 200);
        rect(boxX + boxWidth + 2, boxY + boxHeight, 2, -meterH);
        popMatrix();
        popStyle();
      }
    }
  }
}