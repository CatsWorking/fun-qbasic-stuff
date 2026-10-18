' ==========================================
' TERMINAL DRIFT - B&W WIREFRAME EDITION
' ==========================================
SCREEN _NEWIMAGE(640, 480, 32)
_TITLE "drift"

' Structures for Map and Particles
TYPE Obstacle
    rx AS SINGLE
    ry AS SINGLE
    rw AS SINGLE
    rh AS SINGLE
END TYPE

TYPE Particle
    x AS SINGLE
    y AS SINGLE
    life AS SINGLE
END TYPE

' Game Variables
DIM SHARED x AS SINGLE, y AS SINGLE
DIM SHARED vx AS SINGLE, vy AS SINGLE
DIM SHARED speed AS SINGLE, angle AS SINGLE
DIM SHARED camX AS SINGLE, camY AS SINGLE
DIM SHARED fx AS SINGLE, fy AS SINGLE
DIM SHARED targetVx AS SINGLE, targetVy AS SINGLE
DIM SHARED grip AS SINGLE
DIM SHARED nx AS SINGLE, ny AS SINGLE
DIM SHARED lateralVel AS SINGLE
DIM SHARED carFrontX AS SINGLE, carFrontY AS SINGLE
DIM SHARED carRearX AS SINGLE, carRearY AS SINGLE
DIM SHARED px AS SINGLE, py AS SINGLE
DIM SHARED ox1 AS SINGLE, oy1 AS SINGLE, ox2 AS SINGLE, oy2 AS SINGLE
DIM SHARED pxs AS SINGLE, pys AS SINGLE, sz AS INTEGER
DIM SHARED i AS INTEGER

' Map and Particle configuration
CONST MAX_OBS = 22
DIM SHARED obstacles(MAX_OBS) AS Obstacle

CONST MAX_PARTS = 60
DIM SHARED particles(MAX_PARTS) AS Particle
DIM SHARED pIndex AS INTEGER

x = 800
y = 600
angle = 0
speed = 0
pIndex = 1

' Procedurally generate random map obstacles (buildings/walls forming roads)
RANDOMIZE TIMER
FOR i = 1 TO MAX_OBS
    obstacles(i).rx = INT(RND * 1300) + 100
    obstacles(i).ry = INT(RND * 900) + 100
    obstacles(i).rw = INT(RND * 140) + 70
    obstacles(i).rh = INT(RND * 140) + 70
NEXT i

DO
    CLS
    
    ' --- Input Handling ---
    IF _KEYDOWN(18432) THEN 
        speed = speed + 0.25
    ELSEIF _KEYDOWN(20480) THEN 
        speed = speed - 0.2
    ELSE
        speed = speed * 0.97
    END IF
    
    IF speed > 8.5 THEN speed = 8.5
    IF speed < -3 THEN speed = -3
    
    IF ABS(speed) > 0.4 THEN
        IF _KEYDOWN(19200) THEN angle = angle - 0.06 * (speed / 6)
        IF _KEYDOWN(19712) THEN angle = angle + 0.06 * (speed / 6)
    END IF
    
    ' --- Drift Physics Engine ---
    fx = COS(angle)
    fy = SIN(angle)
    
    targetVx = fx * speed
    targetVy = fy * speed
    
    grip = 0.03
    vx = vx + (targetVx - vx) * grip
    vy = vy + (targetVy - vy) * grip
    
    nx = x + vx
    ny = y + vy
    
    ' --- World Bounds Collision (1600x1200 world) ---
    IF nx < 40 OR nx > 1560 THEN vx = -vx * 0.5: nx = x
    IF ny < 40 OR ny > 1160 THEN vy = -vy * 0.5: ny = y
    
    ' --- Obstacle Collisions ---
    FOR i = 1 TO MAX_OBS
        IF nx > obstacles(i).rx AND nx < obstacles(i).rx + obstacles(i).rw AND _
           ny > obstacles(i).ry AND ny < obstacles(i).ry + obstacles(i).rh THEN
            vx = -vx * 0.5
            vy = -vy * 0.5
            nx = x
            ny = y
            EXIT FOR
        END IF
    NEXT i
    
    x = nx
    y = ny
    
    ' --- Smoke Particle Generation (Triggered on high slip/drift) ---
    lateralVel = ABS(-fy * vx + fx * vy)
    IF lateralVel > 1.2 AND ABS(speed) > 2 THEN
        particles(pIndex).x = x - fx * 14
        particles(pIndex).y = y - fy * 14
        particles(pIndex).life = 25
        pIndex = pIndex + 1
        IF pIndex > MAX_PARTS THEN pIndex = 1
    END IF
    
    FOR i = 1 TO MAX_PARTS
        IF particles(i).life > 0 THEN particles(i).life = particles(i).life - 1
    NEXT i
    
    ' --- Smooth Camera Follow ---
    camX = camX + (x - 320 - camX) * 0.1
    camY = camY + (y - 240 - camY) * 0.1
    
    ' ==========================================
    ' DRAWING (Terminal B&W Wireframe Style)
    ' ==========================================
    
    ' World Outer Border
    LINE (40 - camX, 40 - camY)-(1560 - camX, 1160 - camY), _RGB32(255, 255, 255), B
    
    ' Draw Obstacles / Buildings (Wireframe with dark interior grids)
    FOR i = 1 TO MAX_OBS
        ox1 = obstacles(i).rx - camX
        oy1 = obstacles(i).ry - camY
        ox2 = obstacles(i).rx + obstacles(i).rw - camX
        oy2 = obstacles(i).ry + obstacles(i).rh - camY
        
        ' Screen culling
        IF ox2 > -50 AND ox1 < 690 AND oy2 > -50 AND oy1 < 530 THEN
            LINE (ox1, oy1)-(ox2, oy2), _RGB32(255, 255, 255), B
            LINE (ox1 + 6, oy1 + 6)-(ox2 - 6, oy2 - 6), _RGB32(50, 50, 50), B
        END IF
    NEXT i
    
    ' Draw Smoke Particles (Expanding white wireframe boxes)
    FOR i = 1 TO MAX_PARTS
        IF particles(i).life > 0 THEN
            pxs = particles(i).x - camX
            pys = particles(i).y - camY
            IF pxs >= -10 AND pxs <= 650 AND pys >= -10 AND pys <= 490 THEN
                sz = INT((25 - particles(i).life) / 5) + 1
                LINE (pxs - sz, pys - sz)-(pxs + sz, pys + sz), _RGB32(255, 255, 255), B
            END IF
        END IF
    NEXT i
    
    ' Draw Car Wireframe
    carFrontX = x + fx * 16 - camX
    carFrontY = y + fy * 16 - camY
    carRearX = x - fx * 16 - camX
    carRearY = y - fy * 16 - camY
    
    px = -fy * 7
    py = fx * 7
    
    LINE (carRearX, carRearY)-(carFrontX, carFrontY), _RGB32(255, 255, 255)
    LINE (carRearX + px, carRearY + py)-(carFrontX + px, carFrontY + py), _RGB32(255, 255, 255)
    LINE (carRearX - px, carRearY - py)-(carFrontX - px, carFrontY - py), _RGB32(255, 255, 255)
    LINE (carRearX + px, carRearY + py)-(carRearX - px, carRearY - py), _RGB32(255, 255, 255)
    LINE (carFrontX + px, carFrontY + py)-(carFrontX - px, carFrontY - py), _RGB32(255, 255, 255)
    
    ' --- HUD (Fixed on screen) ---
    COLOR _RGB32(255, 255, 255)
    LOCATE 2, 3: PRINT "drift [code is at: https://github.com/CatsWorking/fun-qbasic-stuff]"
    LOCATE 3, 3: PRINT "SPEED: "; INT(SQR(vx * vx + vy * vy) * 10); " KM/H"
    LOCATE 4, 3: PRINT "if u spawned inside a box and cant move refresh the code"
    LOCATE 28, 3: PRINT "CONTROLS: ARROWS TO DRIVE/STEER | ESC TO EXIT"
    
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)
