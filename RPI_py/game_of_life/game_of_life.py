from formatter import NullFormatter
from math import trunc
from turtle import pos
from xmlrpc.client import FastParser
from sense_hat import SenseHat
from time import sleep
from random import randint, choice
import pygame 
import sys

sense = SenseHat()

r = (255, 0, 0)
g = (0, 255, 0)
b = (0, 0, 255)
w = (255, 255, 255)
z = (0, 0, 0)

class Game:
    def __init__(self):
        self.curr_grid = [
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z
        ]
        self.next_grid = [
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z,
            z, z, z, z, z, z, z, z
        ]
        self.cur_pos = [1, 1]
        self.internal_counter = 0
        self.cells_lim = 7
        self.game_started = False
        
    def restart(self):
        self.__init__()

    def move_cursor(self, key):

        c_x = self.cur_pos[0]
        c_y = self.cur_pos[1]

        if key == 'middle':
            if self.game_started:
                self.restart()
                return
            if self.next_grid[8*c_y + c_x] == z:
                self.next_grid[8*c_y + c_x] = w
                self.internal_counter += 1

                if self.internal_counter == self.cells_lim:
                    self.game_started = True

            else:    
                self.next_grid[8*c_y + c_x] = z
                self.internal_counter -= 1

        elif key == 'up':
            if c_y > 0:
                c_y -= 1
        elif key == 'left':
            if c_x > 0:
                c_x -= 1 
        elif key == 'down':
            if c_y < 7:
                c_y += 1 
        elif key == 'right':
            if c_x < 7:
                c_x += 1 

        self.cur_pos = (c_x, c_y)

        return self.cur_pos

    def draw_scene(self):
        
        self.curr_grid = self.next_grid.copy()

        sense.set_pixels(self.curr_grid)

        if self.game_started:
            self.let_life_happen()

        if self.game_started == False:
            sense.set_pixel(self.cur_pos[0], self.cur_pos[1],  r)

    def let_life_happen(self):
        # key = None

        # while key != 'G' and key != 'R':
        #     key = input('Press G for next generation/R for Restart: ')

        # if key == 'R':
        #     self.next_grid = [
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z,
        #         z, z, z, z, z, z, z, z
        #     ]
        #     self.game_started = False
        #     self.internal_counter = 0
        #     return

        # print(self.curr_grid)

        for j in range(0, 8):
            for i in range(0, 8):
                neighbour_counter = 0

                # print('--- (', i, ', ', j, ') ---')

                if (i > 0 and j > 0) and self.curr_grid[8*(i-1) + (j-1)] == w:
                    # print('UL')
                    neighbour_counter += 1
                if (i > 0) and self.curr_grid[8*(i-1) + j] == w:
                    # print('U')
                    neighbour_counter += 1
                if (j < 7 and i > 0) and self.curr_grid[8*(i-1) + (j+1)] == w:
                    # print('UR')
                    neighbour_counter += 1
                if (j > 0) and self.curr_grid[8*i + (j-1)] == w:
                    # print('L')
                    neighbour_counter += 1
                if (j < 7) and self.curr_grid[8*i + (j+1)] == w:
                    # print('R')
                    neighbour_counter += 1
                if (j > 0 and i < 7) and self.curr_grid[8*(i+1) + (j-1)] == w:
                    # print('DL')
                    neighbour_counter += 1
                if (i < 7) and self.curr_grid[8*(i+1) + j] == w:
                    # print('D')
                    neighbour_counter += 1
                if (i < 7 and j < 7) and self.curr_grid[8*(i+1) + (j+1)] == w:
                    # print('DR')
                    neighbour_counter += 1

                if neighbour_counter < 2 or neighbour_counter > 3:
                     self.next_grid[8*i + j] = z
                elif neighbour_counter == 3:
                     self.next_grid[8*i + j] = w
                elif neighbour_counter == 2 and self.curr_grid[8*i + j] == w:
                     self.next_grid[8*i + j] = w
                    
                # print(neighbour_counter)

FPS = 5
clock = pygame.time.Clock()
game = Game()

while True:
    for event in sense.stick.get_events():
        if event.action == 'pressed':
            cur_pos = game.move_cursor(event.direction)

    game.draw_scene()

    clock.tick(FPS)
