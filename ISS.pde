class ISS { 
  processing.data.JSONObject jsonISS;
  float longitude, latitude;
  int timestamp;
  
  ArrayList<PVector> ISSPos;

  ISS() {
    ISSPos = new ArrayList<PVector>();
  }

  void update() {
  }

  void display() {
  }

  void loadPositions() {
    
  }
  PVector getPosition() {
    jsonISS = loadJSONObject("http://api.open-notify.org/iss-now.json");
    processing.data.JSONObject position = jsonISS.getJSONObject("iss_position");
    longitude = position.getFloat("longitude");
    latitude = position.getFloat("latitude");

    timestamp = jsonISS.getInt("timestamp");

    return new PVector(longitude, latitude, timestamp);
  }
}