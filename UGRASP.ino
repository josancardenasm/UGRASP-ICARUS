
/**********INCLUDES**************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/**********VARIABLES*************/

char NEMEA[100];
char TRAMA[100];


/***********PROTOTIPOS***********/

void getNMEA(void);



void setup() {

  Serial.begin(38400);
  Serial3.begin(38400);
}

void loop() {


  getNMEA();
}


void getNMEA (void){

  unsigned int flag=0;
  char c='0';
  int i=0;

  if (Serial3.available()>0){         //Observo si hay algo en el buffer y lo comparo para ver si es el caracter '$'

    c=Serial3.read();

    if (c=='$'){
      flag=1;
      NEMEA[i]=c;
      i++;
    }
  }

  while (flag==1){

    if (Serial3.available()>0){
      c=Serial3.read();
      NEMEA[i]=c;
      i++;
    }

    if (c=='\r'){

      if (strncmp(NEMEA,"$GPRMC",6)==0){
           memset(TRAMA,0,100);
           strcpy(TRAMA, NEMEA);
           Serial.println(TRAMA);
           
       }

      memset(NEMEA,0,100);
      flag=0;
    }

  }

}
