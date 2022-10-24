#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <linux/fb.h>
#include <linux/input.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

void delay(int);

int main() {
    char* fbdev = "/dev/fb0";
    char* jevent = "/dev/input/event2";
    int fbfd = open(fbdev, O_RDWR);
    int jfd = open(jevent, O_RDONLY);

    if(fbfd < 0) {
        perror("Failed to open LED frame buffer");
        exit(1);
    }

    if(jfd < 0) {
        perror("Failed to open Joystick event device");
        exit(1);
    }

    struct fb_var_screeninfo vinfo;

    ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo);

    int fb_width = vinfo.xres;
    int fb_height = vinfo.yres;
    int fb_bpp = vinfo.bits_per_pixel;
    int fb_bytespp = vinfo.bits_per_pixel/8;
    int fb_data_size = fb_width * fb_height * fb_bytespp;

    printf("x: %d\n", fb_width);
    printf("y: %d\n", fb_height);
    printf("b: %d\n", fb_bpp);
    printf("B: %d\n", fb_bytespp);
    printf("D: %d\n", fb_data_size);

    u_int16_t white = 0xFFFF;
    u_int16_t black = 0x0000;

    struct input_event ev;

    while(1) {
        int rd = read(jfd, &ev, sizeof(struct input_event));

        printf("Type: %d\n", ev.type);
        printf("Code: %d\n", ev.code);
        printf("Value: %d\n\n", ev.value);
    }

    for(int i=0; i<fb_height; i++) {
        for(int j=0; j<fb_width; j++) {
            printf("%d\n", fbfd);
            // int nB = pwrite(fbfd, &white, 2, (i*fb_height+j)*2);
            int nB = pwrite(fbfd, &black, 2, (i*fb_height+j)*2);
            printf("%d\n", nB);
            delay(100);
        }
    }

    close(fbfd);

    return 0;
}

void delay(int t) {
    usleep(t * 1000);
}