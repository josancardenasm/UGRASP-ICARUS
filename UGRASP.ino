
/**********INCLUDES**************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/**********VARIABLES*************/

char NMEA[100];
char TRAMA[100];
int i=0;
char c='0';
int flag=0;
int tiempo=0;


/***********PROTOTIPOS***********/

void getNMEA1(void);
void getNMEA2(void);
void descifrarTrama(void);

void setup() {

  Serial.begin(38400);
  Serial3.begin(38400);
  delay(5000);
  Serial.println("Aqui empiezo");
}

void loop() {

  // if (Serial3.available()>0){
  //   Serial.write(Serial3.read());
  // }

  getNMEA2();

  if (tiempo==10){

    Serial.println("Han pasado 10 segundos");
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

      if (strncmp(NMEA,"$GPRMC",6)==0){
        memset(TRAMA,0,100);
        strcpy(TRAMA, NMEA);
        Serial.println(TRAMA);
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

      if (strncmp(NMEA,"$GPRMC",6)==0){
        memset(TRAMA,0,100);
        strcpy(TRAMA, NMEA);
        Serial.println(TRAMA);
        tiempo++;
      }

      memset(NMEA,0,100);
      flag=0;
      i=0;
    }


  }


}

void descifrarTrama(void){
  sscanf();
  //imprimir el mensaje que se va a guardar en la sd

}
