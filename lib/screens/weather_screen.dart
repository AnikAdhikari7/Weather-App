import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/items/additional_info_item.dart';
import 'package:weather_app/items/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/items/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'Kolkata';

  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occured!';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentPressure = currentWeatherData['main']['pressure'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp K',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  currentSky,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // used a gridview to load the hourly forecast instead of this SingleChildScrollView to reduce the loading time

                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for (int i = 1; i < 40; i++)
                  //         HourlyForecastItem(
                  //             time: data['list'][i]['dt'].toString(),
                  //             icon: data['list'][i]['weather'][0]['main'] ==
                  //                         'Clouds' ||
                  //                     data['list'][i]['weather'][0]['main'] ==
                  //                         'Rain'
                  //                 ? Icons.cloud
                  //                 : Icons.sunny,
                  //             temperature:
                  //                 data['list'][i]['main']['temp'].toString()),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(
                    height: 273,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 2];
                        final hourlySky = hourlyForecast['weather'][0]['main'];
                        final hourlyTemp =
                            hourlyForecast['main']['temp'].toString();
                        final hourlyTime =
                            DateTime.parse(hourlyForecast['dt_txt'].toString());

                        return HourlyForecastItem(
                          time: DateFormat.j().format(hourlyTime),
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          temperature: hourlyTemp,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditonalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AdditonalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                      ),
                      AdditonalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
