CLS
RANDOMIZE TIMER
N = INT(RND * 100) + 1

PRINT "GUESS THE NUMBER!"
PRINT "I picked a number from 1 to 100."
PRINT "https://github.com/CatsWorking/fun-qbasic-stuff"

DO
    INPUT "Your guess"; G

    IF G < N THEN PRINT "Too low!"
    IF G > N THEN PRINT "Too high!"
    IF G = N THEN PRINT "YOU WIN!"
LOOP UNTIL G = N
