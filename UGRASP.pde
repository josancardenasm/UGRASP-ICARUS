
/**********INCLUDES**************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SD.h>
#include <math.h>

/***********DEFINES**************/

//LEDS
#define LEDV 5
#define LEDA 6
#define LEDR 9

#define BUT1 47
#define BUT2 76
#define BUT3 77

#define PWRKEY 86  //pin de apagado y ncendido del GSM


/**********VARIABLES*************/

//GPS
char NMEA[100];           //Buffer para la trama NMEA
char TRAMA[100];          //Buffer para la trama NMEA Capturada
int i=0;
char c='0';
int flag=0;
int tiempo=0;
float hora;         //Hora UTC
float lat;          //Ldatitud
char ilat;          //Indicador norte/sur
float lon;          //Longitud
char ilon;          //Indicador longitud este/oested
int fix;            //Flag de posición fijada
int sat;            //Número de satelites usados
float HDOP;         //No se que es
float alt;          //Altitud
char unit;          //Unidad de altitud

//GSM

int enviarSMSFlag=0;


//SD
File myFile;              //Manejador para la SD
const int chipSelect_SD_default = 53;
const int chipSelect_SD = chipSelect_SD_default;
int fileExist=0;
char mensaje[200];
char ggleMapsMesg[200];

/***********PROTOTIPOS***********/

void getNMEA1(void);              //Modo Bloqueante
void getNMEA2(void);              //Modo No bloqueante
void descifrarTrama(void);
void writeFileSD(char *);
void enviarMensaje (char *);
void check(void);


/***********APLICACION************/

void setup() {

  delay(5000);

  //GPS
  Serial.begin(9600);
  Serial2.begin(9600);
  Serial3.begin(38400);


  Serial2.println("Aqui empiezo");

  //LEDS
  pinMode(LEDV, OUTPUT);
  pinMode(LEDA, OUTPUT);
  pinMode(LEDR, OUTPUT);
  digitalWrite(LEDV,LOW);
  digitalWrite(LEDA,LOW);
  digitalWrite(LEDR,LOW);

  //GSM

  pinMode(PWRKEY,OUTPUT);
  pinMode(BUT1,INPUT);
  pinMode(BUT2,INPUT);
  pinMode(BUT3,INPUT);
  digitalWrite(PWRKEY,HIGH);

  //SD (Para ayuda mirar ejemplo Files)
  pinMode(chipSelect_SD_default, OUTPUT);
  digitalWrite(chipSelect_SD_default, HIGH);
  pinMode(chipSelect_SD, OUTPUT);
  digitalWrite(chipSelect_SD, HIGH);

  //CHequeo de la SD
  if (!SD.begin(chipSelect_SD)) {
    Serial2.println("initialization failed!");
    digitalWrite(LEDR,HIGH);
  }
  if (SD.exists("log.txt")) {
    Serial2.println("example.txt exists.");
  }

}

void loop() {

  //Desciframos trama
  getNMEA2();

  //Enviamos mensaje de texto con coordenadas
  if (tiempo==60){
    Serial2.println("enviarr SMS");

    if(enviarSMSFlag==1){
      enviarMensaje(ggleMapsMesg);
    }
    tiempo=0;
  }

  //chequeamos el buffer del GSM
  check();

  //Encendido del modulo GSM
  if(digitalRead(BUT1)==LOW){
    digitalWrite(LEDA,HIGH);
    digitalWrite(PWRKEY,LOW);
  }else{
    digitalWrite(LEDA,LOW);
    digitalWrite(PWRKEY,HIGH);
  }

  //Activación del envío de sms
  if(digitalRead(BUT2)==0){
    if(enviarSMSFlag==0){
      enviarSMSFlag=1;
      digitalWrite(LEDV,HIGH);
      delay(1000);
    }else{
      enviarSMSFlag=0;
      digitalWrite(LEDV,LOW);
      delay(1000);
    }
  }

}



void getNMEA1 (void){

  unsigned int flag=0;
  char c='0';
  int i=0;

  if (Serial3.available()>0){         //Observo si hay algo en el buffer y lo comparo para ver si es el caracter '$'

  c=Serial3.read();

    if (c=='$'){
      flag=1;
      NMEA[i]=c;
      i++;
    }
  }

  while (flag==1){

    if (Serial3.available()>0){
      c=Serial3.read();
      NMEA[i]=c;
      i++;
    }

    if (c=='\r'){

      if (strncmp(NMEA,"$GPGGA",6)==0){
        memset(TRAMA,0,100);
        strcpy(TRAMA, NMEA);
        //Serial2.println(TRAMA);
        descifrarTrama();
        tiempo++;
      }

      memset(NMEA,0,100);
      flag=0;
    }

  }

}

void getNMEA2 (void){

  if (Serial3.available()>0){
    c=Serial3.read();
    if (c=='$'&&flag==0){
      flag=1;
    }

    if (flag==1){

      NMEA[i]=c;
      i++;

    }

    if (c=='\r'){
      NMEA[i]=c;

      if (strncmp(NMEA,"$GPGGA",6)==0){
        memset(TRAMA,0,100);
        strcpy(TRAMA, NMEA);
        //Serial2.println(TRAMA);
        descifrarTrama();
        tiempo++;
      }

      memset(NMEA,0,100);
      flag=0;
      i=0;
    }


  }


}

void descifrarTrama(void){

  sscanf(TRAMA,"$GPGGA,%f,%f,%c,%f,%c,%i,%i,%f,%f,%c,",&hora,&lat,&ilat,&lon,&ilon,&fix,&sat,&HDOP,&alt,&unit);
  char respuesta[200];
  memset(respuesta,0,200);
  sprintf(respuesta,"%f,%f,%c,%f,%c,%i,%i,%f,%f,%c\n",hora,lat,ilat,lon,ilon,fix,sat,HDOP,alt,unit);
  //Serial.print(respuesta);  //Debug de lo que se escribe en la sd
  writeFileSD(respuesta);

  //Mensaje para localizar el dispositivo
  double latitud, longitud, latpartint, lonpartint, latpartdec, lonpartdec;
  latitud = (double) lat;        //Latitud formato google
  latitud=latitud/100;
  latpartdec=modf(latitud,&latpartint);
  latpartdec=latpartdec*100/60;
  latitud=latpartint+latpartdec;

  longitud = (double) lon;        //Longitud formato google
  longitud=longitud/100;
  lonpartdec=modf(longitud,&lonpartint);
  lonpartdec=lonpartdec*100/60;
  longitud=lonpartint+lonpartdec;
  memset(ggleMapsMesg,0,200);
  sprintf(ggleMapsMesg,"http://maps.google.com/maps?q=%.6f%c,%.6f%c\n\r",latitud,ilat,longitud,ilon);
  //writeFileSD(ggleMapsMesg); //Debug

}

void writeFileSD(char *mens){
  myFile = SD.open("log.txt", FILE_WRITE);
  myFile.write(mens);
  myFile.close();
}

void check (void){

    while (Serial.available()>0){
      Serial2.write(Serial.read());
    }

    while (Serial2.available()>0){
      Serial.write(Serial2.read());
    }

}

void enviarMensaje(char *mensaje){

  Serial.println("AT+CMGF=1");
  check();
  delay(1000);
  Serial.println("AT+CMGS=\"689585469\"");
  check();
  delay(1000);
  Serial.println(mensaje);
  check();
  delay(1000);
  Serial.write(0x1A);
  check();
  delay(1000);
}
