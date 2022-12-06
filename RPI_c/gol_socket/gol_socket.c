#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <linux/fb.h>
#include <linux/input.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <poll.h>
#include <string.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define PORT 8080
#define UP 103
#define LEFT 105
#define DOWN 108
#define RIGHT 106
#define PRESS 28

/*
keyboard       joystick                    code
----------------------------------------------------
<right arrow>  toward ethernet             106  0x6a
<up arrow>     toward GPIO                 103  0x67
<left arrow>   toward camera connector     105  0x69
<down arrow>   toward nearest board edge   108  0x6c
<enter>        press down                   28  0x1c
*/

struct pos_t {
    unsigned int x;
    unsigned int y;
};

struct game_of_life_t {
    unsigned char grid[64];
};

struct game_session_t {
    unsigned int game_started;
    unsigned int cell_lim;
    unsigned int cell_counter;
    unsigned int FPS;
    struct pos_t cursor_pos;
    struct game_of_life_t gol;
    int fbfd;
    int jfd;
    struct fb_var_screeninfo vinfo;
};

struct game_session_t session;

/* Colors definition */
u_int16_t WHITE = 0xFFFF;
u_int16_t BLACK = 0x0000;
u_int16_t RED = 0xF000;

void delay(int t);
void move_cursor(int x, int y);
void handle_events(int evfd);
void draw_scene();
void restart();
void life();

char buffer[1024];
int server_fd, new_socket, valread;
struct sockaddr_in address;
int opt;
int addrlen;
char* hello;

int main() {
    /* =============================================================== */
    /* Socket server configuration */
	opt = 1;
	addrlen = sizeof(address);
    hello = (char*) malloc(1024*sizeof(char));
	strcpy(hello, "ack from server");

    // Creating socket file descriptor
	if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket failed");
		exit(EXIT_FAILURE);
	}

	// Forcefully attaching socket to the port 8080
	if (setsockopt(server_fd, SOL_SOCKET,
				SO_REUSEADDR | SO_REUSEPORT, &opt,
				sizeof(opt))) {
		perror("setsockopt");
		exit(EXIT_FAILURE);
	}
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = INADDR_ANY;
	address.sin_port = htons(PORT);

    int k = bind(server_fd, (struct sockaddr*)&address,
			sizeof(address));

	if (k < 0) {
		perror("bind failed");
		exit(EXIT_FAILURE);
	}
	if (listen(server_fd, 3) < 0) {
		perror("listen");
		exit(EXIT_FAILURE);
	}

    /* =============================================================== */
    /* Setup Game Session */
    session.FPS = 5;
    session.cell_counter = 0;
    session.cell_lim = 4;

    struct input_event ev;
    
    /* Open LED (fb0) and Joystick (event1) file descriptors */
    char* fbdev = "/dev/fb0";
    char* jevent = "/dev/input/event2";
    session.fbfd = open(fbdev, O_RDWR);
    session.jfd = open(jevent, O_RDONLY);

    /* Check if file descriptors */
    if(session.fbfd < 0) {
        perror("Failed to open LED frame buffer");
        exit(1);
    }
    if(session.jfd < 0) {
        perror("Failed to open Joystick event device");
        exit(1);
    }

    struct pollfd evpoll = {
		.events = POLLIN
	};
    // evpoll.fd = session.jfd;
    evpoll.fd = server_fd;

    /* Get LED frame buffer info */
    ioctl(session.fbfd, FBIOGET_VSCREENINFO, &(session.vinfo));

    unsigned int frame_time = 1000/session.FPS;
    while(1) {
        while (poll(&evpoll, 1, 0) > 0)
			handle_events(evpoll.fd);

        draw_scene();

        delay(frame_time);
    }

    return 0;
}

void restart() {
    session.game_started = 0;
    session.cell_counter = 0;
    session.cursor_pos.x = 0;
    session.cursor_pos.y = 0;
    memset(session.gol.grid, 0, 64*sizeof(unsigned char));
}

void delay(int t) {
    usleep(t * 1000);
}

void move_cursor(int x, int y) {
    struct pos_t cursor_pos = session.cursor_pos;
    cursor_pos.x += x;
    cursor_pos.y += y;

    if(cursor_pos.x < 0) {
        cursor_pos.x *= -1;
        cursor_pos.x = 8 - cursor_pos.x;
    }
    cursor_pos.x %= 8; 

    if(cursor_pos.y < 0) {
        cursor_pos.y *= -1;
        cursor_pos.y = 8 - cursor_pos.y;
    }
    cursor_pos.y %= 8; 

    session.cursor_pos = cursor_pos;

    // printf("%d %d\n", cursor_pos.x, cursor_pos.y);
}

void handle_events(int evfd) {
    if((new_socket = accept(server_fd, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0) {
    	perror("accept");
    	exit(EXIT_FAILURE);
    }
    int valread = read(new_socket, buffer, 1024);
    // printf("%s\n", buffer);

    if(strcmp(buffer, "up") == 0) {
        move_cursor(0, -1);
    } else if(strcmp(buffer, "down") == 0) {
        move_cursor(0, 1);
    } else if(strcmp(buffer, "right") == 0) {
        move_cursor(1, 0);
    } else if(strcmp(buffer, "left") == 0) {
        move_cursor(-1, 0);
    } else if(strcmp(buffer, "enter") == 0) {
        if(!session.game_started) {
            const int fb_height = session.vinfo.yres;

            session.cell_counter -= session.gol.grid[session.cursor_pos.y*fb_height + session.cursor_pos.x];

            session.gol.grid[session.cursor_pos.y*fb_height + session.cursor_pos.x]++;
            session.gol.grid[session.cursor_pos.y*fb_height + session.cursor_pos.x] %= 2;

            session.cell_counter += session.gol.grid[session.cursor_pos.y*fb_height + session.cursor_pos.x];

            if(session.cell_counter == session.cell_lim) {
                session.game_started = 1;
            }
        } else {
            restart();
        }
    }

    memset(&buffer, 0, sizeof(buffer));
}

void life() {
    const int fbfd = session.fbfd;
    const struct fb_var_screeninfo vinfo = session.vinfo;
    const int fb_width = vinfo.xres;
    const int fb_height = vinfo.yres;
    const int fb_bpp = vinfo.bits_per_pixel;
    const int fb_bytespp = vinfo.bits_per_pixel/8;
    const int fb_data_size = fb_width * fb_height * fb_bytespp;
    unsigned char grid[64] = {};

    for(int i=0; i<fb_height; i++) {
        for(int j=0; j<fb_width; j++) {
            unsigned int num_neigh = 0;

            if(i > 0 && j > 0 && session.gol.grid[(i-1)*fb_height + (j-1)]) {
                num_neigh += session.gol.grid[(i-1)*fb_height + (j-1)];
            }
            if(i > 0 && session.gol.grid[(i-1)*fb_height + j]) {
                num_neigh += session.gol.grid[(i-1)*fb_height + j];
            }
            if(i > 0 && j < 7 && session.gol.grid[(i-1)*fb_height + (j+1)]) {
                num_neigh += session.gol.grid[(i-1)*fb_height + (j+1)];
            }
            if(j > 0 && session.gol.grid[i*fb_height + (j-1)]) {
                num_neigh += session.gol.grid[i*fb_height + (j-1)];
            }
            if(j < 7 && session.gol.grid[i*fb_height + (j+1)]) {
                num_neigh += session.gol.grid[i*fb_height + (j+1)];
            }
            if(i < 7 && j > 0 && session.gol.grid[(i+1)*fb_height + (j-1)]) {
                num_neigh += session.gol.grid[(i+1)*fb_height + (j-1)];
            }
            if(i < 7 && session.gol.grid[(i+1)*fb_height + j]) {
                num_neigh += session.gol.grid[(i+1)*fb_height + j];
            }
            if(i < 7 && j < 7 && session.gol.grid[(i+1)*fb_height + (j+1)]) {
                num_neigh += session.gol.grid[(i+1)*fb_height + (j+1)];
            }
            
            grid[i*fb_height + j] = ( (num_neigh == 3) || (num_neigh == 2 && session.gol.grid[i*fb_height + j]) );
        }
    }

    for(int i=0; i<64; i++) {
        session.gol.grid[i] = grid[i];
    }
}

void draw_scene() {
    const int fbfd = session.fbfd;
    const struct fb_var_screeninfo vinfo = session.vinfo;
    const int fb_width = vinfo.xres;
    const int fb_height = vinfo.yres;
    const int fb_bpp = vinfo.bits_per_pixel;
    const int fb_bytespp = vinfo.bits_per_pixel/8;
    const int fb_data_size = fb_width * fb_height * fb_bytespp;
    const unsigned char* grid = session.gol.grid;

    if(session.game_started)
        life();

    for(int i=0; i<fb_height; i++) {
        for(int j=0; j<fb_width; j++) {
            if(grid[i*fb_height + j])
                pwrite(fbfd, &WHITE, 2, (i*fb_height+j)*2);
            else
                pwrite(fbfd, &BLACK, 2, (i*fb_height+j)*2);
        }
    }

    if(!session.game_started)
        pwrite(fbfd, &RED, 2, (session.cursor_pos.y*fb_height + session.cursor_pos.x)*2);
}