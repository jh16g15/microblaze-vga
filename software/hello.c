
//#include "stdint.h"  // for uint32_t etc

int main (void)
{
	volatile int foo;
	
	foo = 0;
	while(1){
		foo++;
	}
}