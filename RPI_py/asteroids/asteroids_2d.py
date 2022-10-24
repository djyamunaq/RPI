from formatter import NullFormatter
from math import trunc
from turtle import pos
from sense_hat import SenseHat
from time import sleep
from random import randint, choice
import pygame 
import sys

# --------------------------------------------------------------------------------------------------------------------
# Game Setup
sense = SenseHat()

# Define colours
r = (255, 0, 0)
g = (0, 255, 0)
b = (0, 0, 255)
w = (255, 255, 255)
z = (0, 0, 0)

sense.clear(w)

base_grid = [
    w, w, w, w, w, w, w, w,
    w, z, z, z, z, z, z, w,
    w, z, z, z, z, z, z, w,
    w, z, z, z, z, z, z, w,
    w, z, z, z, z, z, z, w,
    w, z, z, z, z, z, z, w,
    w, z, z, z, z, z, z, w,
    w, w, w, w, w, w, w, w
]

sense.set_pixels(base_grid)

FPS = 10
clock = pygame.time.Clock()

class Asteroid:
    def __init__(self, pos=[], dir=[]):
        self.pos = pos
        self.dir = dir

class Game:
    def __init__(self, player_pos=[], asteroids=[]):
        self.player_pos = player_pos
        self.asteroids = asteroids

    def move_player(self, key):
        p_x = self.player_pos[0]
        p_y = self.player_pos[1]

        if key == 'up':
            if p_y > 1:
                p_y -= 1
        elif key == 'left':
            if p_x > 1:
                p_x -= 1 
        elif key == 'down':
            if p_y < 6:
                p_y += 1 
        elif key == 'right':
            if p_x < 6:
                p_x += 1 

        self.player_pos = (p_x, p_y)

        return self.player_pos

    def generate_ast(self):
        edges = [1, 6]
        x = choice(edges)
        y = choice(edges)
        dir = None

        coin = randint(0, 1)
        if coin == 1:
            y = randint(1, 6)
            if x == 1:
                dir = (1, 0)
            else:
                dir = (-1, 0)
        else:
            x = randint(1, 6)

            if y == 1:
                dir = (0, 1)
            else:
                dir = (0, -1)

        self.asteroids.append(Asteroid([x, y], dir))

    def draw_scene(self):
        sense.set_pixels(base_grid)
        sense.set_pixel(self.player_pos[0], self.player_pos[1],  r)

        temp = []

        while len(self.asteroids) > 0:
            asteroid = self.asteroids.pop()
            ast_x = asteroid.pos[0] + (1/FPS)*asteroid.dir[0]
            ast_y = asteroid.pos[1] + (1/FPS)*asteroid.dir[1]

            if (ast_x >= 1 and ast_x <= 6) and (ast_y >= 1 and ast_y <= 6):
                sense.set_pixel(trunc(ast_x), trunc(ast_y), b)
                asteroid.pos[0] = ast_x
                asteroid.pos[1] = ast_y
                temp.append(asteroid)
        self.asteroids = temp

        self.detect_collisions()

    def detect_collisions(self):
        for asteroid in self.asteroids:
            if self.player_pos[0] == trunc(asteroid.pos[0]) and self.player_pos[1] == trunc(asteroid.pos[1]):
                self.game_over()

    def game_over(self):
        sense.show_message('GAME OVER!')
        sense.clear(w)
        sys.exit(0)

    def start(self):
        sense.set_pixels(base_grid)
        sense.set_pixel(self.player_pos[0], self.player_pos[1],  r)
        

# --------------------------------------------------------------------------------------------------------------------
# Game Loop
game = Game(player_pos=[1, 1], asteroids=[])
game.start()

ast_count = 0

while True:
    ast_count += 1

    if ast_count == 6:
        game.generate_ast()
        ast_count = 0

    for event in sense.stick.get_events():
        if event.action == 'pressed':
            player_pos = game.move_player(event.direction)

    game.draw_scene()
    clock.tick(FPS)
