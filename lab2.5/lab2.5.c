#define BUTTON (volatile unsigned int *) 0x10000050
#define BUTTON_MASK (volatile unsigned int *) 0x10000058
#define BUTTON_EDGE (volatile unsigned int *) 0x1000005C
#define HEX_DISPLAY (volatile unsigned int *) 0x10000020

#define TIMER_STATUS	((volatile unsigned int *) 0x10002000)

#define TIMER_CONTROL	((volatile unsigned int *) 0x10002004)

#define TIMER_START_LO	((volatile unsigned int *) 0x10002008)

#define TIMER_START_HI	((volatile unsigned int *) 0x1000200C)

#define TIMER_SNAP_LO	((volatile unsigned int *) 0x10002010)

#define TIMER_SNAP_HI	((volatile unsigned int *) 0x10002014)

#define LEDS	((volatile unsigned int *) 0x10000010)

// Do note ^ this is a parallel port ok? Technically speaking...
// See for more -> https://ftp.intel.com/Public/Pub/fpgaup/pub/Intel_Material/13.0/Computer_Systems/DE0/DE0_Basic_Computer.pdf

void interrupt_handler(void)
{
    unsigned int ipending;
   ipending = NIOS2_READ_IPENDING();

   if ((ipending & 0b1) == 0b1) {
      // when an interrupt comes in, the ipending will stay on until the device turns
      // off it's signal requesting the interrupt, so we need to tell the timer to turn off it's 1st bit which is
      // related to ITO in this interrupt, telling the timer to call again once times up
      *TIMER_STATUS = *TIMER_STATUS & 0b10;

      // here we are flipping a simple LED on the far right
      // there are two ways of doing this:
      // the flip way
      // *LEDS = (~*LEDS) & 0b1;
      // and the XOR way (which the 2.5 lab asks you to do btw)
      *LEDS = *LEDS ^ 0b1;
   }
   
   if ((ipending & 0b10) == 0b10) {
      unsigned int pressed = *BUTTON_EDGE;
      *BUTTON_EDGE = pressed; // fire back to turn them off
      // *LEDS = *LEDS ^ pressed;
      // ^ uncomment this and it should toggle the 2nd and 3rd LEDS per button
      // I just did this to be sure

      // Like in assembly, doing a -1 will cause a wrap around.
      // each hex digit in display holds 0-7 inputs
      // 4 of that is 32-bits of inputs, and since unsigned ints are 32-bits
      // you get the idea :)
      *HEX_DISPLAY = *HEX_DISPLAY ^ (unsigned int)-1;
   }
}

void Init (void)
{
   // This is IRQ 0 -> 1st bit
   *TIMER_START_LO = 0x7840;
   *TIMER_START_HI = 0x017D;
   *TIMER_STATUS = 0b0; // just to clear this up, sanity check
   *TIMER_CONTROL = 0b111;

   // Push buttons are IRQ 1 -> 2nd bit
   *BUTTON_MASK = 0b110; // enable button 2 & 1 for interrupts (not 0)
   // ^ on the actual board, button 0 is used for a different purpose

   NIOS2_WRITE_STATUS(0b1); // enables processor interrupts
   NIOS2_WRITE_IENABLE(0b11); // enables IRQ 0 & 1, our timer & buttons
}


int main (void)
{
    Init ();

   // just as an example of a loop
   int a = 0;
    while (1)
    {
        if (a == 0) {
         a = 1;
      } else {
         a = 0;
      }
    }

    return 0;
}