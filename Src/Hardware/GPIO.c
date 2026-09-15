#include "GPIO.h"

void MyGPIO_Init(void)
{
    GPIO_InitTypeDef gpio_init = {0};

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);

    gpio_init.GPIO_Pin = GPIO_Pin_13;
    gpio_init.GPIO_Mode = GPIO_Mode_Out_PP;
    gpio_init.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOC, &gpio_init);
    //默认状态是亮，因此在进入下面的代码之前调试时是亮的，也就是低电平点亮
    /* The common Blue Pill LED on PC13 is active low. */
    GPIO_SetBits(GPIOC, GPIO_Pin_13);
}
