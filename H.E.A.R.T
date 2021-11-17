// RemoteXY select connection mode and include library  
#define REMOTEXY_MODE__ESP8266_HARDSERIAL_CLOUD

#include <RemoteXY.h> //library for Application
#include <SoftwareSerial.h> //library for software serial connection
#include <TinyGPS++.h> //library for GPS connection

// RemoteXY connection settings  
#define REMOTEXY_SERIAL Serial 
#define REMOTEXY_SERIAL_SPEED 9600 //this is the speed rate 
#define REMOTEXY_WIFI_SSID "Kukuri" //wifi name
#define REMOTEXY_WIFI_PASSWORD "19693966815888751119" //wifi password
#define REMOTEXY_CLOUD_SERVER "cloud.remotexy.com" //cloud server sitename
#define REMOTEXY_CLOUD_PORT 6376  //port number of cloud server connection
#define REMOTEXY_CLOUD_TOKEN "fdeba1dc103056043e043829b9579804" //unique token for the board to provide connection between the board and the cloud server


// RemoteXY configurate and tells the mobile app about how to build the graphical interface.  
#pragma pack(push, 1) 
uint8_t RemoteXY_CONF[] = 
  { 255,1,0,24,0,98,0,13,2,1,
  2,1,3,21,22,11,94,26,31,31,
  79,78,0,79,70,70,0,66,130,41,
  21,13,10,36,95,129,0,10,5,43,
  6,1,73,110,116,114,117,115,105,111,
  110,32,84,104,101,102,116,0,68,51,
  3,44,57,45,24,52,135,94,76,111,
  110,103,105,116,117,100,101,0,76,97,
  116,105,116,117,100,101,0,65,108,116,
  105,116,117,100,101,0,67,5,3,92,
  20,5,2,26,11 }; 
   
// this structure defines all the variables and events of your control interface  
struct { 

    // input variables
  uint8_t switch_1; // =1 if switch ON and =0 if OFF 

    // output variables
  int8_t Distance; // =0..100 level position 
  float onlineGraph_1_var1; //latitude variable of GPS
  float onlineGraph_1_var2; //longitude variable of GPS
  float onlineGraph_1_var3; //altitude variable of GPS 

    // other variable
  uint8_t connect_flag;  // =1 if wire connected, else =0 

} RemoteXY; 
#pragma pack(pop) 

#define PIN_SWITCH_1 5 //declaration of led that is controlled by application (REMOTEXY)
int trigger_pin = 11; //the trigger pin that sends waves for the ultrasonic
int echo_pin = 10; //the echo pin that recieves waves for ultrasonic sensor
int time; //time variable for radio wave
int distance; //distance variable for radio wave calculation of ultrasonic sensor
int led = 13; //species digital pin 13 as the led
int buzzer = 8; //species digital pin 8 as the buzzer

TinyGPSPlus gps; //declaration of the gps variable from the TinyGPS++ library included
SoftwareSerial SoftSerial (6,7); //6 -> RX , 7-> TX, on the Adruino board 

void setup()  
{ 
  RemoteXY_Init ();  //initiates the application
  pinMode(led ,OUTPUT); //modes the led as an output
  pinMode (PIN_SWITCH_1, OUTPUT); //modes the pin switch as an output
  SoftSerial.begin(9600); //the rate of transfer of data on the board
  pinMode(trigger_pin, OUTPUT); //modes the trigger pin as an output 
  pinMode(echo_pin, INPUT); //modes the echo pin as an input
  pinMode(buzzer, OUTPUT); //modes the buzzer as an output  
} 

void loop()   
{  
  RemoteXY_Handler (); //handles the requests of the code
   
  digitalWrite(PIN_SWITCH_1, (RemoteXY.switch_1==0)?LOW:HIGH); //switches the LED on or off depending on application input
  
  while(SoftSerial.available() > 0)
   gps.encode(SoftSerial.read()); //reads the GPS coordinates from the GPS module
  RemoteXY.onlineGraph_1_var1 = int (gps.location.lat()); //this provides the latitude of the GPS
  RemoteXY.onlineGraph_1_var2 = int (gps.location.lng()); //this provides the longitude of the GPS
  RemoteXY.onlineGraph_1_var3 = int (gps.altitude.meters()); //this provides the altitude of the GPS

  digitalWrite(trigger_pin, HIGH); //This sends out the ultrasonic wave
  delayMicroseconds (10);
  digitalWrite(trigger_pin,LOW); //This stops sending out the ultrasonic wave
  delayMicroseconds(10);
  time = pulseIn(echo_pin, HIGH); //This takes time as a variable in which we calcute at which time the wave bounced back
  distance = (time * 0.034) /2; //This calculates the distance it took for the wave to bounce back on a object, and how far that object is

  RemoteXY.Distance = (int)(distance); //sends the distance calculated to the application

 // if(distance <= 20) {
   // digitalWrite(led,HIGH);
    //digitalWrite(buzzer, HIGH);
    //RemoteXY
 // }
  //else {
    //digitalWrite(led, LOW);
    //digitalWrite(buzzer, LOW);
  //}  
  // do not call delay()  
}
