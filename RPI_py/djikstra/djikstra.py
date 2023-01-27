from cmath import inf
from formatter import NullFormatter
from math import trunc
from mimetypes import init
from turtle import pos
from xmlrpc.client import FastParser
from sense_hat import SenseHat
from time import sleep
from random import randint, choice
import pygame 
import sys

sense = SenseHat()

# Set colors
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
        self.cells_lim = 2
        self.game_started = False
        self.coords = []
        self.d_motor = Djikstra()
        self.end_game = False

    def restart(self):
        sense.clear(w)
        self.__init__()

    def move_cursor(self, key):
        c_x = self.cur_pos[0]
        c_y = self.cur_pos[1]

        if key == 'middle':
            if self.end_game:
                self.restart()
                return
            if self.next_grid[8*c_y + c_x] == z:
                self.next_grid[8*c_y + c_x] = w
                self.internal_counter += 1
                self.coords.append((c_x, c_y))

                if self.internal_counter == self.cells_lim:
                    self.game_started = True
                    self.d_motor.setup(self.coords[0], self.coords[1]) 
            else:    
                self.next_grid[8*c_y + c_x] = z
                self.internal_counter -= 1

        elif key == 'up':
            if c_y > 0:
                c_y -= 1
            else:
                c_y -= 1
                c_y %= 7
                c_y += 1
        elif key == 'left':
            if c_x > 0:
                c_x -= 1 
            else:
                c_x -= 1
                c_x %= 7
                c_x += 1
        elif key == 'down':
            if c_y < 7:
                c_y += 1
            else:
                c_y -= 1
                c_y %= 7
                c_y += 1 
        elif key == 'right':
            if c_x < 7:
                c_x += 1
            else:
                c_x -= 1
                c_x %= 7
                c_x += 1 

        self.cur_pos = (c_x, c_y)

        return self.cur_pos

    def draw_scene(self):
        
        if self.game_started and not self.end_game:
            self.end_game = self.d_motor.search()

            for i in range(0, 8):
                for j in range(0, 8):
                    if (self.d_motor.visited[i][j])[0] == 1:
                        self.next_grid[8*i + j] = w

            if self.end_game:
                print(self.d_motor.path)
                for v in self.d_motor.path:
                            self.next_grid[v[1]*8 + v[0]] = r
                
        self.curr_grid = self.next_grid.copy()

        sense.set_pixels(self.curr_grid)            

        if self.game_started == False:
            sense.set_pixel(self.cur_pos[0], self.cur_pos[1],  r)

class Djikstra:
    def __init__(self, start=[], goal=[]):
        self.start = start
        self.goal = goal
        self.visited = [
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]],
            [[0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None], [0, 255, None]]
        ]
        self.p_queue = []
        self.path = []

    def setup(self, start_v, goal_v):
        self.start = start_v
        self.goal = goal_v
        (self.visited[start_v[1]][start_v[0]])[1] = 0
        self.p_queue.append(self.start)

    def search(self):
        (j, i) = self.p_queue.pop(0)
        
        if (self.visited[i][j])[0] == 1:
            return False

        (self.visited[i][j])[0] = 1 

        if (j, i) == self.goal:
            curr = self.goal
            while curr != self.start:
                
                self.path.append(curr)
                curr = (self.visited[curr[1]][curr[0]])[2]

            self.path.append(self.start)

            return True

        if j > 0 and i > 0 and (self.visited[i-1][j-1])[0] == 0:
            if (self.visited[i-1][j-1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i-1][j-1])[1] = (self.visited[i][j])[1] + 1
                (self.visited[i-1][j-1])[2] = (j, i)
                self.p_queue.append((j-1, i-1))
        if i > 0 and (self.visited[i-1][j])[0] == 0:
            if (self.visited[i-1][j])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i-1][j])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i-1][j])[2] = (j, i)
                self.p_queue.append((j, i-1))
        if j < 7 and i > 0 and (self.visited[i-1][j+1])[0] == 0:
            if (self.visited[i-1][j+1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i-1][j+1])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i-1][j+1])[2] = (j, i)
                self.p_queue.append((j+1, i-1))
        if j > 0 and (self.visited[i][j-1])[0] == 0:
            if (self.visited[i][j-1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i][j-1])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i][j-1])[2] = (j, i)
                self.p_queue.append((j-1, i))
        if j < 7 and (self.visited[i][j+1])[0] == 0:
            if (self.visited[i][j+1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i][j+1])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i][j+1])[2] = (j, i)
                self.p_queue.append((j+1, i))
        if j > 0 and i < 7 and (self.visited[i+1][j-1])[0] == 0:
            if (self.visited[i+1][j-1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i+1][j-1])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i+1][j-1])[2] = (j, i)
                self.p_queue.append((j-1, i+1))
        if i < 7 and (self.visited[i+1][j])[0] == 0:
            if (self.visited[i+1][j])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i+1][j])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i+1][j])[2] = (j, i)
                self.p_queue.append((j, i+1))
        if i < 7 and j < 7 and (self.visited[i+1][j+1])[0] == 0:
            if (self.visited[i+1][j+1])[1] > (self.visited[i][j])[1] + 1:
                (self.visited[i+1][j+1])[1] = (self.visited[i][j])[1] + 1 
                (self.visited[i+1][j+1])[2] = (j, i)
                self.p_queue.append((j+1, i+1))

        self.sort_queue()

        return False

    def sort_queue(self):
        for i in range(0, len(self.p_queue)):        
            for j in range(0, len(self.p_queue)):
                v_a = self.p_queue[i]
                v_b = self.p_queue[j]

                if (self.visited[v_a[1]][v_a[0]])[1] < (self.visited[v_b[1]][v_b[0]])[1]:
                    temp = tuple(self.p_queue[i])
                    self.p_queue[i] = tuple(self.p_queue[j])
                    self.p_queue[j] = tuple(temp)

FPS = 20
clock = pygame.time.Clock()
game = Game()

while True:
    for event in sense.stick.get_events():
        if event.action == 'pressed':
            cur_pos = game.move_cursor(event.direction)

    game.draw_scene()
    clock.tick(FPS)
