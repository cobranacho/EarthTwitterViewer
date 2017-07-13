class YahooWeather {
  String condition;
  String queryString;
  String locationString;
  String temperature;

  processing.data.JSONObject json;

  YahooWeather() {
  }

  String getWeather(String locality, String administrativeArea, String country) {
    if (locality == null) {
      locality = "";
    }
    if (administrativeArea == null) {
      administrativeArea = "";
    }
    if (country == null) {
      country = "";
    }
    locality = locality.replaceAll(" ", "%20");
    administrativeArea = administrativeArea.replaceAll(" ", "%20");
    country = country.replaceAll(" ", "%20");

    locationString ="in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22" + locality + "%2C%20" + administrativeArea + "%2C%20" + country + "%22)";
    queryString = "https://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20" + locationString  + "&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys";

    try {
      json = loadJSONObject(queryString);
      temperature = json.getJSONObject("query").getJSONObject("results").getJSONObject("channel").getJSONObject("item").getJSONObject("condition").getString("temp");
      condition = json.getJSONObject("query").getJSONObject("results").getJSONObject("channel").getJSONObject("item").getJSONObject("condition").getString("text");
    } 
    catch(Exception e) {
      println("Connection Error");
    }


    return (temperature + " " + condition);
  }
}