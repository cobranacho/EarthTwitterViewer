 //<>//
class GeoService {
  String API_KEY = "AIzaSyBhYc5skJMrUqsM5sRKBA1-zjFsuaol45Q";
  String httpsRequest;
  String geoCodeRequest;
  String locality, administrativeArea, country ;
  float longitude = 500, latitude;
  String formatedLocation;
  boolean validLocation;

  PVector locationVector;

  processing.data.JSONObject json;

  GeoService() {
  }

  GeoService(float longitude_, float latitude_) {

    longitude = longitude_;
    latitude = latitude_;
    locality = "";
    administrativeArea = "";
    country = "";
    geoCodeRequest = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + latitude + "," + longitude;
    println(geoCodeRequest);
    getLocationJSON();
  }


  void search(String locality) {
    if (locality != "") {

      for (int x = 0; x < locality.length(); x++) {
        if (locality.charAt(x) == 32) {
          locality = locality.replace(' ', '+');
        }
        formatedLocation = locality;
      }
    }
    if (formatedLocation != null) {

      formatRequest();
      getLatnLng();
    }
  }

  void search(String locality, String administrativeArea, String country) {
    for (int x = 0; x < locality.length(); x++) {
      if (locality.charAt(x) == 32) {
        locality = locality.replace(' ', '+');
      }
    }
    for (int x = 0; x < administrativeArea.length(); x++) {
      if (administrativeArea.charAt(x) == 32) {
        administrativeArea= administrativeArea.replace(' ', '+');
      }
    }
    for (int x = 0; x < country.length(); x++) {
      if (country.charAt(x) == 32) {
        country= country.replace(' ', '+');
      }
    }
    
    formatedLocation = locality + "," + administrativeArea + "," + country;
    
    formatRequest();
    getLatnLng();
  }
  GeoService(String locality) {

    if (locality != "") {

      for (int x = 0; x < locality.length(); x++) {
        if (locality.charAt(x) == 32) {
          locality = locality.replace(' ', '+');
        }
        formatedLocation = locality;
      }
    }
    if (formatedLocation != null) {
      println(formatedLocation);
      formatRequest();
      getLatnLng();
    }
  }

  String getLocality() {
    return locality;
  }

  String getAdministrativeArea() {
    return administrativeArea;
  }
  String getCounry() {

    return country;
  }
  PVector getLocaton() {
    return new PVector(longitude, latitude);
  }

  void formatRequest() {
    httpsRequest = "https://maps.googleapis.com/maps/api/geocode/json?address=" + formatedLocation + "&key=" + API_KEY;
    println(httpsRequest);
  }

  void getLocationJSON() {
    try {
      json = loadJSONObject(geoCodeRequest);
      validLocation = true;
      processing.data.JSONArray results = json.getJSONArray("results");

      processing.data.JSONArray address_components = results.getJSONObject(0).getJSONArray("address_components");
      for (int i = 0; i < address_components.size(); i++) {
        processing.data.JSONArray temp = address_components.getJSONObject(i).getJSONArray("types");    

        if (temp.getString(0).equals("locality")) {
          locality = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("short_name");
        }
        if (temp.getString(0).equals("administrative_area_level_1")) {
          administrativeArea = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("short_name");
        }
        if (temp.getString(0).equals("country")) {
          country = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("long_name");
        }
      }

      println(locality, administrativeArea, country);
    } 
    catch (Exception e) {
      validLocation = false;
      println("Invalid Query");
    }
  }

  void getLatnLng() {
    try {
      json = loadJSONObject(httpsRequest);
      processing.data.JSONArray results = json.getJSONArray("results");

      longitude = results.getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getFloat("lng");
      latitude = results.getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getFloat("lat");

      processing.data.JSONArray address_components = results.getJSONObject(0).getJSONArray("address_components");
      for (int i = 0; i < address_components.size(); i++) {
        processing.data.JSONArray temp = address_components.getJSONObject(i).getJSONArray("types");    

        if (temp.getString(0).equals("locality")) {
          locality = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("short_name");
        }
        if (temp.getString(0).equals("administrative_area_level_1")) {
          administrativeArea = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("short_name");
        }
        if (temp.getString(0).equals("country")) {
          country = results.getJSONObject(0).getJSONArray("address_components").getJSONObject(i).getString("long_name");
        }
      }
    } 
    catch (Exception e) {
      longitude = 500;
      latitude = 500;
    }
  }
}