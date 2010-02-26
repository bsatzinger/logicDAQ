//Record 8 bytes of data before printing it
#define BUFFERSIZE 256

//Bits on port B
#define BMASK B00000011
//Bits on port D
#define DMASK B11111100

unsigned char buffer[BUFFERSIZE];
unsigned int index;

void setup()
{
  Serial.begin(115200); //opens serial port, sets data rate to 115200 bps

  //for loop to initialize each pin as an input
  for (int inPin = 2; inPin < 10; inPin++)
  {
    //set as input
    pinMode(inPin, INPUT);

    //set pullup resistor
    //Causes floating inputs to default to 1 (HIGH)
    digitalWrite(inPin, HIGH);
  }

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
          for (index = 0; index < BUFFERSIZE; index++)
          {
            //Read 1 byte of digital data
            buffer[index] = readByte();
            
            //wait 10 ms
            delay(10);
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
    Serial.println(buffer[index], HEX);
  } 
}

//Combine PINB bits 0 and 1 and PIND bits 7 to 2 to give digital pins 2 to 9 in one byte
inline char readByte()
{
  //Mask off the parts of PINB and PIND
  //Unsigned is important because shifting behaves differently
  //for signed and unsigned numbers (the MSB is a sign bit)
  unsigned char B = PINB & BMASK;
  unsigned char D = PIND & DMASK;

  //Combine the two parts
  unsigned char R = B | D;
 
   //Rotate two positions to the right to line it up right
  return (R >> 2) |  (R << 6);
  
  //A char has 8 bits.  The bits are the digital IO pins 9 through 2 on the arduino
  
  //bit 7  bit 6  bit 5  bit 4  bit 3  bit 2  bit 1  bit 0
  //pin9   pin 8  pin 7  pin 6  pin 5  pin 4  pin 3  pin 2
 
}
