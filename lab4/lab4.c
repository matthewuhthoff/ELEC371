#include "nios2_control.h"

/* place additional #define macros here */
#define TIMER_STATUS2	((volatile unsigned int *) 0x10004040)

#define TIMER_CONTROL2	((volatile unsigned int *) 0x10004044)

#define TIMER_START_LO2	((volatile unsigned int *) 0x10004048)

#define TIMER_START_HI2	((volatile unsigned int *) 0x1000404C)

#define TIMER_SNAP_LO2	((volatile unsigned int *) 0x10004050)

#define TIMER_SNAP_HI2	((volatile unsigned int *) 0x10004054)

	

#define TIMER_STATUS3	((volatile unsigned int *) 0x10004060)

#define TIMER_CONTROL3	((volatile unsigned int *) 0x10004064)

#define TIMER_START_LO3	((volatile unsigned int *) 0x10004068)

#define TIMER_START_HI3	((volatile unsigned int *) 0x1000406C)

#define TIMER_SNAP_LO3	((volatile unsigned int *) 0x10004070)

#define TIMER_SNAP_HI3	((volatile unsigned int *) 0x10004074)



#define LEDS	((volatile unsigned int *) 0x10000010)

#define HEX_DISPLAY	((volatile unsigned int *) 0x10000020)

#define SWITCHES ((volatile unsigned int *) 0x10000040)



/* define global program variables here */
volatile int timer_2_flag = 0;
volatile int timer_3_flag = 0;
int counter = 0;
int led_array[] = {
	0x201,
	0x84,
	0x30,
	0x48,
	0x102
};

unsigned int hex_table[] =
{
0x3F, 0x06, 0x5B, 0x4F,
0x66, 0x6D, 0x7D, 0x07,
0x7F, 0x6F, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00
};

/* place additional functions here */

void show_Hex(int which_display, int value){
   unsigned int hex = hex_table[value];
   hex = hex << (which_display * 8);
   
   if(which_display == 0) {
	*HEX_DISPLAY = *HEX_DISPLAY & 0xFFF0;
   }
   if(which_display == 1) {
	*HEX_DISPLAY = *HEX_DISPLAY & 0xFF0F;
   }
   if(which_display == 2) {
	*HEX_DISPLAY = *HEX_DISPLAY & 0xF0FF;
   }
   if(which_display == 3) {
	*HEX_DISPLAY = *HEX_DISPLAY & 0x0FFF;
   }
   
   *HEX_DISPLAY = *HEX_DISPLAY | hex;
   
}


/*-----------------------------------------------------------------*/

/* this routine is called from the_exception() in exception_handler.c */

void interrupt_handler(void)
{
	unsigned int ipending;

	/* read current value in ipending register */
    ipending = NIOS2_READ_IPENDING();

	/* do one or more checks for different sources using ipending value */
	if (ipending & 0x8000) {
		timer_2_flag = 1;
		*TIMER_STATUS2 = 0;
	} else if (ipending & 0x10000){
		timer_3_flag = 1;
		*TIMER_STATUS3 = 0;
	}
	/* remember to clear interrupt sources */
	
}

/*-----------------------------------------------------------------*/

void Init (void)
{
	/* initialize software variables */
	
	/* set up each hardware interface */
   *TIMER_START_LO2 = 0x9680;
   *TIMER_START_HI2 = 0x0098;
   *TIMER_STATUS2 = 0;
   *TIMER_CONTROL2 = 7;


   *TIMER_START_LO3 = 0xBC20;
   *TIMER_START_HI3 = 0x00BE;
   *TIMER_STATUS3 = 0;
   *TIMER_CONTROL3 = 7;
   
	/* set up ienable */
   NIOS2_WRITE_IENABLE(0x18000);

	/* enable global recognition of interrupts in procr. status reg. */
   NIOS2_WRITE_STATUS(1);

   InitADC(2, 2);

   PrintString("\n");
   PrintString("ELEC 371 Lab 4 by Matt, Duncan, Lauren");
   PrintString("\n");
   PrintString("0x6E");

}

/*-----------------------------------------------------------------*/

int main (void)
{
	Init ();	/* perform software/hardware initialization */
	unsigned int adc;
	while (1)
	{
		if (timer_2_flag){
			timer_2_flag = 0;
			*LEDS = led_array[counter];
			counter += 1;
			counter = counter % 5;
			
			adc = ADConvert();
			adc *= 100;
			adc /= 256;
			int tens = adc % 10;
			int ones = adc - tens;
			show_Hex(1, tens);
			show_Hex(0, ones);
		}
		if (timer_3_flag){
			timer_3_flag = 0;
			unsigned int switch_value = *SWITCHES;
			switch_value = switch_value & 0x380;
			switch_value = switch_value >> 7;
			show_Hex(3, switch_value);
		}
	}

	return 0;	/* never reached, but main() must return a value */
}
