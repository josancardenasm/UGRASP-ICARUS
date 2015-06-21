
/**********INCLUDES**************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SD.h>

/***********DEFINES**************/

//LEDS
#define LEDV 5
#define LEDA 6
#define LEDR 9

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

//SD
File myFile;              //Manejador para la SD
const int chipSelect_SD_default = 53;
const int chipSelect_SD = chipSelect_SD_default;
int fileExist=0;
char mensaje[200];

/***********PROTOTIPOS***********/

void getNMEA1(void);              //Modo Bloqueante
void getNMEA2(void);              //Modo No bloqueante
void descifrarTrama(void);
void writeFileSD(char *);

/***********APLICACION************/

void setup() {

  delay(5000);

  //GPS
  Serial.begin(38400);
  Serial3.begin(38400);


  Serial.println("Aqui empiezo");

  //LEDS
  pinMode(LEDV, OUTPUT);
  pinMode(LEDA, OUTPUT);
  pinMode(LEDR, OUTPUT);
  digitalWrite(LEDV,LOW);
  digitalWrite(LEDA,LOW);
  digitalWrite(LEDR,LOW);

  //SD (Para ayuda mirar ejemplo Files)
  pinMode(chipSelect_SD_default, OUTPUT);
  digitalWrite(chipSelect_SD_default, HIGH);
  pinMode(chipSelect_SD, OUTPUT);
  digitalWrite(chipSelect_SD, HIGH);
  if (!SD.begin(chipSelect_SD)) {
    Serial.println("initialization failed!");
    digitalWrite(LEDR,HIGH);
  }
  if (SD.exists("log.txt")) {
    Serial.println("example.txt exists.");
  }

}

void loop() {

  // if (Serial3.available()>0){
  //   Serial.write(Serial3.read());
  // }

  getNMEA2();

  if (tiempo==10){

    Serial.println("Han pasado 10 segundos");
    // memset(mensaje,0,200);
    // sprintf(mensaje,"QUE PASA MONSTRO\n");
    // writeFileSD(mensaje);
    tiempo=0;
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
        Serial.println(TRAMA);
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
        Serial.println(TRAMA);
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
  //Serial.print(respuesta);
  writeFileSD(respuesta);
}

void writeFileSD(char *mens){
  myFile = SD.open("log.txt", FILE_WRITE);
  myFile.write(mens);
  myFile.close();
}
