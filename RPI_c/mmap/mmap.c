/*
 * RPI SenseHATH LED control with I2C
 * LED2472G is controlled via chip ATTINY88 via I2C at addr 0x46 with the Pi
 * Pins for I2C comm: GPIO2 (SDA: Serial Data Line) and GPIO3 (SCL: Serial Clock Line)
 */
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <stdint.h>

#define BCM2708_PERI_BASE       0x20000000
#define GDPIO_BASE              BCM2708_PERI_BASE + 0x200000
#define I2C_ADDR                GDPIO_BASE
#define GPIO_LEN                0xF4

u_int16_t WHITE = 0xFFFF;

int main() {
    int fd = open("/dev/mem", O_RDWR | O_SYNC) ;
    
    if(fd < 0) {
        printf("Unable to open /dev/mem: %s\n", strerror(errno));
        return -1;
    }

    uint32_t *ptr = (uint32_t*) mmap(0, GPIO_LEN, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED|MAP_LOCKED, fd, GDPIO_BASE);
    
    if (ptr == MAP_FAILED) {
        perror("Cannot map memory");
        return -1;
    }

    printf("%d\n", ptr[1]);
    ptr[1] = 0x0000;
    printf("%d\n", ptr[1]);

    return 0;
}