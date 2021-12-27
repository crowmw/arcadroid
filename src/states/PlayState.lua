--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[self.health + 1].dx = 200
    -- self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('space') and self.health > 0 then
            self.balls[self.health] = Ball()
            self.balls[self.health].skin = math.random(7)
            self.balls[self.health].x = self.paddle.x + self.paddle.width + 1
            self.balls[self.health].y = self.paddle.y + self.paddle.height / 2 - self.balls[self.health].height / 2
            self.balls[self.health].dx = 200
            if(self.health > 0) then
                self.health = self.health - 1
            end
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.x = self.paddle.x + self.paddle.width + ball.width
            ball.dx = -ball.dx
    
            --
            -- tweak angle of bounce based on where it hits the paddle
            --
    
            -- if we hit the paddle on its left side while moving left...
            if ball.y < self.paddle.y + (self.paddle.height / 2) and self.paddle.dy < 0 then
                ball.dy = -50 + -(8 * (self.paddle.y + self.paddle.height / 2 - ball.y))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.y > self.paddle.y + (self.paddle.height / 2) and self.paddle.dy > 0 then
                ball.dy = 50 + (8 * math.abs(self.paddle.y + self.paddle.height / 2 - ball.y))
            end
    
            gSounds['paddle-hit']:play()
        end

        if k == 1 then
            if self.balls[2] ~= nil then
                if ball:collides(self.balls[2]) then
                    ball.dx = -ball.dx
                    ball.dy = -ball.dy
                    self.balls[2].dx = -self.balls[2].dx
                    self.balls[2].dy = -self.balls[2].dy
                end
            end
            if self.balls[3] ~= nil then
            if ball:collides(self.balls[3]) then
                ball.dx = -ball.dx
                ball.dy = -ball.dy
                self.balls[3].dx = -self.balls[3].dx
                self.balls[3].dy = -self.balls[3].dy
            end
        end
        end

        if k == 2 then
            if self.balls[1] ~= nil then
            if ball:collides(self.balls[1]) then
                ball.dx = -ball.dx
                ball.dy = -ball.dy
                self.balls[1].dx = -self.balls[1].dx
                self.balls[1].dy = -self.balls[1].dy
            end
        end
        if self.balls[3] ~= nil then
            if ball:collides(self.balls[3]) then
                ball.dx = -ball.dx
                ball.dy = -ball.dy
                self.balls[3].dx = -self.balls[3].dx
                self.balls[3].dy = -self.balls[3].dy
            end
        end
        end

        if k == 3 then
            if self.balls[1] ~= nil then
            if ball:collides(self.balls[1]) then
                ball.dx = -ball.dx
                ball.dy = -ball.dy
                self.balls[1].dx = -self.balls[1].dx
                self.balls[1].dy = -self.balls[1].dy
            end
        end
        if self.balls[3] ~= nil then
            if ball:collides(self.balls[3]) then
                ball.dx = -ball.dx
                ball.dy = -ball.dy
                self.balls[3].dx = -self.balls[3].dx
                self.balls[3].dy = -self.balls[3].dy
            end
        end
        end
        

        for b, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
    
                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
    
                -- trigger the brick's hit function, which removes it from play
                brick:hit()
    
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
    
                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end
    
                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
    
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        balls = self.balls,
                        recoverPoints = self.recoverPoints
                    })
                end
    
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --
    
                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end
    
                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end
    
                -- only allow colliding with one brick, for corners
                break
            end
        end

        if ball.x <= 0 then
            self.balls[k] = nil
            gSounds['hurt']:play()
    
            if self.balls[1] == nil and self.balls[2] == nil and self.balls[3] == nil then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end 
    -- self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end