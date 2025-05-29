import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Weatherapp extends StatefulWidget {
  const Weatherapp({super.key});

  @override
  State<Weatherapp> createState() => _WeatherappState();
}

class _WeatherappState extends State<Weatherapp> {
  String apiKey = '75ad8899843caf42cd0b0fbbad15f46c';

  // Karachi default
  String selectedCity = 'Karachi';
  String temprature = '';
  String humidity = '';
  String feelslike = '';
  String windSpeed = '';
  String pressure = '';
  String iconCode = '';
  String weatherConditions = '';

  // Search
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> searchedCitiesWeather = [];

  @override
  void initState() {
    super.initState();
    getWeather(selectedCity);
  }

  Future<void> getWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temprature = data['main']['temp'].toString();
        humidity = data['main']['humidity'].toString();
        feelslike = data['main']['feels_like'].toString();
        windSpeed = data['wind']['speed'].toString();
        pressure = data['main']['pressure'].toString();
        iconCode = data['weather'][0]['icon'];
        weatherConditions = data['weather'][0]['main'].toString();
      });
    }
  }

  Future<void> getSearchedWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        // Prevent duplicates
        if (!searchedCitiesWeather.any((entry) =>
            entry['city']!.toLowerCase() == city.trim().toLowerCase())) {
          searchedCitiesWeather.add({
            'city': city,
            'temp': data['main']['temp'].toString(),
            'humidity': data['main']['humidity'].toString(),
            'feelslike': data['main']['feels_like'].toString(),
            'wind': data['wind']['speed'].toString(),
            'condition': data['weather'][0]['main'].toString(),
          });
        }
      });
    }
  }

  Widget weatherCard(String city, String temp, String humidity, String feels,
      String wind, String condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Container(
        height: 135,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(getImageForCondition(condition)),fit:BoxFit.cover),
          
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.cyan],
          ),
          
          borderRadius: BorderRadius.circular(20),
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text("Humidity: $humidity%",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  Text("Feels like: $feels",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  Text("Condition: $condition",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Text('$temp °C',
                      style: TextStyle(color: Colors.white, fontSize: 25)),
                  SizedBox(height: 30),
                  Text("Wind: $wind km/h",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getImageForCondition (String condition){
    switch(condition.toLowerCase()){
      case 'clear':return "assets/images/clear.jpg";
      case 'clouds':return "assets/images/clouds.jpg";
      case 'dust':return "assets/images/dust.jpg";
      case 'haze':return "assets/images/haze.jpg";
      case 'rain':return "assets/images/rain.jpg";
      case 'smoke':return "assets/images/smoke.jpg";
      case 'thunderstrom':return "assets/images/thunderstrom.jpg";
      default: return "assets/images/clear.jpg";
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Weather',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: searchController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    getSearchedWeather(value.trim());
                    searchController.clear();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for a city or airport',hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                  contentPadding: EdgeInsets.only(top: 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(40)),
                  prefixIcon: Icon(Icons.search,color: const Color.fromARGB(255, 255, 255, 255),),
                ),
              ),
            ),

            // Karachi weather card
            weatherCard(selectedCity, temprature, humidity, feelslike,
                windSpeed, weatherConditions),

            // Searched city weather cards
            ...searchedCitiesWeather.map((entry) {
  return Dismissible(
    key: Key(entry['city']!), // unique key
    direction: DismissDirection.endToStart, // swipe left to delete
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (direction) {
      setState(() {
        searchedCitiesWeather.remove(entry);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${entry['city']} deleted")),
      );
    },
    child: weatherCard(
      entry['city']!,
      entry['temp']!,
      entry['humidity']!,
      entry['feelslike']!,
      entry['wind']!,
      entry['condition']!,
    ),
  );
}).toList(),

          ],
        ),
      ),
    );
  }
}
