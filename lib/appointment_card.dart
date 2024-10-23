import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import "config.dart";
import "main.dart";


class AppointmentCard extends StatefulWidget{
  AppointmentCard({Key? key}) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard>{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                    AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(width: 20, ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 2,),
                      Text('Adderall', style: TextStyle(color: Colors.white, fontSize: 17, ), ),
                    ],
                  ),
                ],
              ),
              Config.spaceSmall,
              //schedule info
              const ScheduleCard(),
              Config.spaceSmall,
              //action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                      },
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {},
                    ),

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ScheduleCard extends StatelessWidget {
  const ScheduleCard ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 176, 189, 248),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.calendar_today,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(width: 5,),
          Text(
            'Sunday, 10/19/2024',
            style: const TextStyle(color: Colors.white),
          ),
          SizedBox(width: 15,),
          Icon(Icons.access_alarm,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(width: 5,),
          Flexible(child:
          Text(
            '3:15 PM',
            style: TextStyle(color: Colors.white),
          ),
          )
        ],
      ),
    );
  }
}