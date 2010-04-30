//Record 8 bytes of data before printing it
#define BUFFERSIZE 256

//Bits on port B
//#define BMASK B00000011
//Bits on port D
//#define DMASK B11111100

unsigned char Dbuffer[BUFFERSIZE];
unsigned char Bbuffer[BUFFERSIZE];
unsigned char Cbuffer[BUFFERSIZE];

unsigned int index;

unsigned char output = 0;

unsigned char timer2start = 253;
int recordingTrace = 0;

void setup()
{
  Serial.begin(115200); //opens serial port, sets data rate to 115200 bps

  //for loop to initialize each pin as an input.  pins 2-11 (d2-d7 and b1-b3) are inputs (10)
  for (int inPin = 2; inPin <= 11; inPin++)
  {
    //set as input
    pinMode(inPin, INPUT);

    //set pullup resistor
    //Causes floating inputs to default to 1 (HIGH)
    digitalWrite(inPin, HIGH);
  }
  
  for (int outPin = 12; outPin <= 19; outPin++)
  {
    //set as outputs, with default value low
     pinMode(outPin, OUTPUT);
      digitalWrite(outPin, LOW); 
  }

  SetupTimer2();

  index = 0;

  //I'm not sure if this is a better way, but these pins can be
  //set as inputs by directly setting the DDR for example:
  //DDRD &= B00000011;  //DDRD contains digital pins 0 through 7
  //INPUT = 0, OUTPUT = 1; uses logical AND 
  //so Tx and Rx pins aren't altered
  //DDRB &= B11111100;  //DDRB holds digital pins 8 through 13
}

void loop() //loop to read digital pins 0-13
{
  int inByte;
  
  if (Serial.available() > 0)
  {
      inByte = Serial.read();
    
    
      if (inByte == 't')
      {
             //Fill up the buffer
          /*for (index = 0; index < BUFFERSIZE; index++)
          {
            //Read 1 byte of digital data
            Dbuffer[index] = PIND;
            Bbuffer[index] = PINB;
            Cbuffer[index] = PINC;
            
            //if (index % 5 == 0)
            //{
               updateOutput(); 
            //}
            
            delay(1);
          }
        */
        
        index = 0;
        recordingTrace = 1;
        
        while (recordingTrace == 1)
        {
           delay(1); 
        }
        
          //Print out the buffer
          printBuffer();
      }
  }
  
}

void printBuffer()
{
  //Print the size of the buffer
  Serial.println(BUFFERSIZE, DEC);

  //Print each byte from the buffer in hexadecimal on a new line
  for (index = 0; index < BUFFERSIZE; index++)
  {
    Serial.println(Dbuffer[index], HEX);
    Serial.println(Bbuffer[index], HEX);
    Serial.println(Cbuffer[index], HEX);
  } 
}

void SetupTimer2(void)
{
  
  TCCR2A = 0;

  //256 prescaling
  TCCR2B = 1<<CS22 | 1<<CS21 | 0<<CS20; 

  //Timer2 Overflow Interrupt Enable   
  TIMSK2 = 1<<TOIE2;

  //load the timer for its first cycle
  TCNT2=timer2start; 
}

ISR(TIMER2_OVF_vect)
{
  //Disable interrupts
  cli();
  
  //Currently recording trace?
  if(recordingTrace == 1)
  {
      
      if (index > (BUFFERSIZE - 1))
      {
         //Done recording the trace
         recordingTrace = 0;
      }
      else
      {
 
          Dbuffer[index] = PIND;
            Bbuffer[index] = PINB;
            Cbuffer[index] = PINC;
            
            //if (index % 5 == 0)
            //{
               updateOutput(); 
            //}

        index++;
      }  
  }
  
  
  //Reset the counter for the next period
  TCNT2=timer2start;    //TCNT2 = timr2start - TCNT2 might compensate for the (variable) ISR time

  //Enable interrupts
  sei();
}

//update the output
void updateOutput()
{
    if (output > 0b00111111)
    {
       output = 0; 
    }
    
    
    PORTC = output & 0b00111111;
    output++;
}
